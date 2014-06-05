require 'nokogiri'
require 'digest/md5'
require 'RMagick'


module PulStore
  module Lae

    class JhoveAuditUtilities
      include Magick

      ADOBE_1998 = "Adobe RGB (1998)"

      # Parse the audit XML into an array of hashes
      def self.parse_audit(audit_path)
        jhove_audit_to_a(audit_path)
      end

      # Any errors here should cause the process to stop
      def self.validate_audit_for_breakers(audit_hash)
        errors = []
        # Make sure everything belongs to one box
        unless only_one_box?(audit_hash)
          errors << 'Audit contains file from more than one box.'
        end
        # Do all paths exist on the drive?
        missing_files = check_for_missing_files(audit_hash)
        unless  missing_files.length == 0
          errors << "Some files are missing: #{missing_files.join(', ')}."
        end
        # Make sure box exists in repo
        unless box_exists_in_repo?(audit_hash)
          barcode = audit_hash.first[:box_barcode]
          errors << "Box with barcode #{barcode} does not exist in the repository."
        end

        errors
      end

      # Any errors here will mark individual files as not to be ingested, but
      # the intent is that the calling process should continue on. A list of
      # the errors is returned for logging.
      def self.validate_audit_members(audit_hash)
        errors = []
        # Check same number of OCR files as images? (log problems to stderr, mark not to ingest)
        missing_ocr_or_image = check_ocr_image_match(audit_hash)
        missing_ocr_or_image.each do |f|
          errors << "Missing corresponding OCR or TIFF for #{f[:path]}"
        end
        # Make sure manifest says all are well-formed/valid (log problems to stderr, mark not to ingest)
        unacceptable_status = check_for_acceptable_status(audit_hash)
        unacceptable_status.each do |f|
          errors << "File #{f[:path]} has status: #{f[:path]}"
        end
        # Verify Checksums
        mismatches = verify_checksums(audit_hash)
        mismatches.each do |f|
          errors << "File #{f[:path]} checksum does not match"
        end
        # Color Profile
        wrong_color_profile = verify_color_profile(audit_hash)
        wrong_color_profile.each do |f|
          errors << "File #{f[:path]} color profile is not '#{ADOBE_1998}'"
        end
        # OCR w/ broken image || Image with broken ocr
        files_with_broken_partners = confirm_corresponding_files_ok(audit_hash)
        files_with_broken_partners.each do |f|
          m =  "File #{f[:path]} will not be ingested because the corresponding "
          m += "image or OCR has a problem."
          errors << m
        end

        errors
      end

      protected

      ###################
      ## Breaker Checks
      ###################

      def self.only_one_box?(audit)
        barcodes = audit.map { |f| f[:box_barcode] }
        barcodes.uniq.length == 1
      end

      def self.check_for_missing_files(audit)
        missing = []
        audit.each { |f|  missing << f[:path] unless File.exists? f[:path] }
        missing
      end

      def self.box_exists_in_repo?(audit)
        b = audit.first[:box_barcode]
        PulStore::Lae::Box.where(prov_metadata__barcode_tesim: b).to_a.length == 1
      end

      ###########################
      ## File Validation Checks
      ###########################

      # This updates the audit in place AND returns a list of files that won't
      # be ingested (useful for logging).
      def self.check_ocr_image_match(audit)
        ocr_files = audit.select { |f| f[:mime] == 'text/xml' }
        image_files = audit.select { |f| f[:mime] == 'image/tiff' }
        do_not_ingest = []

        image_files.each do |image_file|
          unless ocr_for_image_file?(image_file, ocr_files)
            image_file[:ok_to_ingest?] = false
            do_not_ingest << image_file
          end
        end

        ocr_files.each do |ocr_file|
          unless image_for_ocr_file?(ocr_file, image_files)
            ocr_file[:ok_to_ingest?] = false
            do_not_ingest << ocr_file
          end
        end

        do_not_ingest

      end

      # This updates the audit in place AND returns a list of files that won't
      # be ingested (useful for logging)
      def self.check_for_acceptable_status(audit)
        ocr_files = audit.select { |f| f[:mime] == 'text/xml' }
        image_files = audit.select { |f| f[:mime] == 'image/tiff' }
        do_not_ingest = []

        image_files.each do |image_file|
          unless image_file[:status] == 'valid'
            image_file[:ok_to_ingest?] = false
            do_not_ingest << image_file
          end
        end

        ocr_files.each do |ocr_file|
          unless ocr_file[:status] == 'well-formed'
            ocr_file[:ok_to_ingest?] = false
            do_not_ingest << ocr_file
          end
        end

        do_not_ingest
      end

      # After all other checks, run through this, which will mark OCR as not to
      # ingest if the image has problems, and vice versa.
      def self.confirm_corresponding_files_ok(audit)
        ocr_files = audit.select { |f| f[:mime] == 'text/xml' }
        image_files = audit.select { |f| f[:mime] == 'image/tiff' }
        do_not_ingest = []


        image_files.each do |image_file|
          ocr_file = ocr_for_image_file(image_file, ocr_files)
          unless ocr_file[:ok_to_ingest?] 
            image_file[:ok_to_ingest?] = false
            do_not_ingest << image_file unless do_not_ingest.include?(ocr_file)
          end
        end

        ocr_files.each do |ocr_file|
          image_file = image_for_ocr_file(ocr_file, image_files)
          unless image_file[:ok_to_ingest?]
            ocr_file[:ok_to_ingest?] = false
        # The PROBLEM is that if the image file above was marked as not to 
        # ingest because the OCR wasn't OK, then now the image files that aren't
        # OK have their OCR added to the do_not_ingest list. We want a clean list
        # of files that are excluded for this reason. unless ⌄ is the solution
            do_not_ingest << ocr_file unless do_not_ingest.include?(image_file)
          end
        end

        do_not_ingest
      end

      # This updates the audit in place AND returns a list of files that won't
      # be ingested (useful for logging)
      def self.verify_checksums(audit)
        mismatches = []
        audit.each do |f|
          unless calc_md5(f[:path]) == f[:md5]
            f[:ok_to_ingest?] = false
            mismatches << f
          end
        end
        mismatches
      end

      # This updates the audit in place AND returns a list of files that won't
      # be ingested (useful for logging)
      def self.verify_color_profile(audit)

        wrong_profiles = []
        audit.each do |f|
          if f[:mime] == 'image/tiff'
            im = ImageList.new(f[:path])
            unless im.gray?
              unless read_color_profile_name(im) == ADOBE_1998
                f[:ok_to_ingest?] = false
                wrong_profiles << f
              end
            end
          end
        end
        wrong_profiles
      end

      # note that filtering of stuff not OK to ingest also happens here
      def self.filter_and_group_images_and_ocr(audit)
        pages_job_args = []

        audit.each do |a|
          entry = pages_job_args.select do |p|
            (p[:sort_order] == a[:sort] && p[:folder_barcode] == a[:folder_barcode])
          end
          path_type = a[:mime] == 'text/xml' ? :ocr_path : :tiff_path
          if a[:ok_to_ingest?]
            if entry.empty?
              pages_job_args << { path_type => a[:path], sort_order: a[:sort], folder_barcode: a[:folder_barcode] }
            else
              entry.first[path_type] = a[:path]
            end
          end
        end

        pages_job_args

      end

      #########################
      ## UTILITY METHODS
      #########################
      # Turn the <file> elements from a JHOVE audit into an array of hashes
      def self.jhove_audit_to_a(audit_file_path)
        audit_hashes = []
        File.open(audit_file_path, 'r') do |xmlf|
          root_dir = File.dirname(audit_file_path)
          file_elements = Nokogiri::XML(xmlf).xpath('//xmlns:file').each do |f|
            audit_hashes << file_element_to_h(f, root_dir)
          end
        end
        audit_hashes
      end

      # Turn a JHOVE <file> element into a Hash containing the Box bardcode,
      # Folder barcode, mime type, status, sort order, file name, and original
      # path
      def self.file_element_to_h(file_element, root_dir)
        h = {}
        h[:path] = File.join(root_dir, normalize_windows_path(file_element.content))
        path_elements = h[:path].split('/')
        h[:file_name] = path_elements.pop()
        h[:folder_barcode] = path_elements.pop()
        h[:box_barcode] = path_elements.pop()
        h[:mime] = file_element['mime']
        h[:status] = file_element['status']
        h[:md5] = file_element['md5']
        h[:sort] = File.basename(h[:file_name], ".*").to_i
        h[:ok_to_ingest?] = true
        h
      end

      # Converts, e.g., G:\32101075851483\32101075851459\0002.xml to
      # 32101075851483/32101075851459/0002.xml
      # but won't harm a Unix-style path
      def self.normalize_windows_path(path)
        path.gsub(/^[A-Z]:\\+/, '').gsub(/\\+/, '/')
      end

      def self.calc_md5(file_path)
        md5 = Digest::MD5.new
        File.open(file_path, 'r') { |f| md5 << f.read(1024) until f.eof? }
        md5.hexdigest
      end

      def self.read_color_profile_name(image_list)
        # See http://www.color.org/specification/ICC1v43_2010-12.pdf
        profile = []
        profile_name = nil

        image_list.color_profile.each_byte { |b| profile << b }

        tag_count = profile[128,4].pack("c*").unpack("N").first
        tag_count.times do |i|
          tag_table_row =  (128 + 4) + (12*i) # the header + tag count + 12 bytes for each tag
          tag_signature = profile[tag_table_row,4].pack("c*") # 9.2.41 profileDescriptionTag

          if tag_signature == 'desc'
            desc_offset = profile[tag_table_row+4,4].pack("c*").unpack("N").first
            tag_size = profile[tag_table_row+8,4].pack("c*").unpack("N").first
            tag = profile[desc_offset,tag_size].pack("c*").unpack("Z12 Z*")
            profile_name = tag[1]
            break
          end
        end
        profile_name
      end

      # file(s) are entries in an audit
      def self.ocr_for_image_file(image_file, ocr_files)
        ocr_files = ocr_files.select { |f|
          (f[:folder_barcode] == image_file[:folder_barcode] && f[:sort] == image_file[:sort])
        }.first
      end

      # file(s) are entries in an audit
      def self.ocr_for_image_file?(image_file, ocr_files)
        !ocr_for_image_file(image_file, ocr_files).nil?
      end

      # file(s) are entries in an audit
      def self.image_for_ocr_file(ocr_file, image_files)
        image_files = image_files.select { |f|
          (f[:folder_barcode] == ocr_file[:folder_barcode] && f[:sort] == ocr_file[:sort])
        }.first
      end

      # file(s) are entries in an audit
      def self.image_for_ocr_file?(ocr_file, image_files)
        !image_for_ocr_file(ocr_file, image_files).nil?
      end



    end
  end

end


# We have: {
#   :path=>"spec/fixtures/files/lae_test_img/32101075851483/32101075851459/0002.xml",
#   :file_name=>"0002.xml",
#   :folder_barcode=>"32101075851459",
#   :box_barcode=>"32101075851483",
#   :mime=>"text/xml",
#   :status=>"well-formed",
#   :md5=>"0870b65b66d80c86b29d8706dd2c2455",
#   :sort=>2,
#   :ok_to_ingest?=>true
# }
# We need: folder_barcode, tiff_path, ocr_path, sort_order

