require 'spec_helper'

module PulStore
  module Lae
    describe JhoveAuditUtilities do
      subject { PulStore::Lae::JhoveAuditUtilities }
      before(:all) do
        @fixtures_dir = File.expand_path('../../../../fixtures/files/lae_test_img', __FILE__)
        @sample_audit = File.join(@fixtures_dir, '32101075851483.jhove.xml')

        @win_ex_path = 'G:\32101075851483\32101075851434\0001.tif' # These go
        @unix_ex_path = '32101075851483/32101075851434/0001.tif'   # togther.
        @a_tiff_path = File.join(@fixtures_dir, '32101075851483/32101075851434/0002.tif') # These go
        @an_xml_path = File.join(@fixtures_dir, '32101075851483/32101075851434/0002.xml') # togther.
        @tiff_correct_icc = File.join(@fixtures_dir, '32101075851483/32101075851434/0001.tif')
        @tiff_gray = File.join(@fixtures_dir, '32101075851483/32101075851459/0001.tif')
        @ex_box_barcode = '32101075851483'
        @ex_folder_barcodes = ['32101075851434','32101075851459']
        @fake_barcode = '32101075851488' # may not be valid..shouldn't matter
      end
      # Rake tasks depend on this too, so testing those, as described here:
      # http://robots.thoughtbot.com/test-rake-tasks-like-a-boss
      # might not be a bad idea.
      describe 'has a set of fixtures' do
        it 'a jhove sample' do
          expect(File.exist? @sample_audit).to be_truthy
        end
      end

      describe 'self#parse_audit' do
        it 'can turn the audit XML it into an array' do
          audit = subject.parse_audit(@sample_audit)
          expect(audit.class).to be Array
          expect(audit.all? { |h| h.class == Hash }).to be_truthy
          expect(audit.length).to be 10
        end

        describe 'parses the path into the params we need' do
          before(:all) do
            @audit = PulStore::Lae::JhoveAuditUtilities.parse_audit(@sample_audit)
          end

          it 'gets the box barcode' do
            expect(@audit.all? { |f| f[:box_barcode] == @ex_box_barcode }).to be_truthy
          end

          it 'gets the expected folder barcodes' do
            barcodes = @audit.map{|f| f[:folder_barcode]}
            expect(@ex_folder_barcodes.sort).to eq barcodes.uniq.sort
          end

          it 'gets the data we need' do
            folder = @audit.select{ |f| f[:path] == @a_tiff_path }.pop
            expect(folder[:path]).to eq @a_tiff_path
            expect(folder[:file_name]).to eq '0002.tif'
            expect(folder[:sort]).to eq 2
            expect(folder[:mime]).to eq 'image/tiff'
            expect(folder[:status]).to eq 'valid'
            expect(folder[:md5]).to eq '31371948fe3e34cd8438922e643406f5'
            expect(folder[:ok_to_ingest?]).to eq true
          end


        end
      end


      describe 'self#validate_audit_for_breakers' do
        before(:all) do
          PulStore::Lae::Box.delete_all
          @audit = PulStore::Lae::JhoveAuditUtilities.parse_audit(@sample_audit)
          @box = FactoryGirl.create(:lae_box, barcode: @ex_box_barcode)
        end

        it 'returns an array with error messages when something is wrong' do
          audit_copy = Marshal.load(Marshal.dump(@audit))
          image = audit_copy.select{ |f| f[:path] == @a_tiff_path }.pop
          image[:box_barcode] = '32101075851486'
          errors = subject.validate_audit_for_breakers(audit_copy)
          expect(errors.length).to eq 1
        end

        describe 'self#only_one_box?' do
          it 'is true when there is only one box barcode' do
            only_one = subject.only_one_box?(@audit)
            expect(only_one).to be_truthy
          end

          it 'is false when there is more than one box barcode' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            image = audit_copy.select{ |f| f[:path] == @a_tiff_path }.pop
            image[:box_barcode] = '32101075851486'
            only_one = subject.only_one_box?(audit_copy)
            expect(only_one).to be_falsey
          end
        end

        describe 'self#check_for_missing_files' do
          it 'will have one file on the list when one is missing' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            fake = File.join(@fixtures_dir, @ex_box_barcode, @ex_folder_barcodes[0], '0042.tif')
            audit_copy << { path: fake }
            expect(subject.check_for_missing_files(audit_copy).length).to eq 1
          end

          it 'returns an empty list when everything is accounted for' do
            expect(subject.check_for_missing_files(@audit).length).to eq 0
          end
        end

        describe 'self#box_exists_in_repo?' do
          it 'is true if the box exists' do
            expect(subject.box_exists_in_repo?(@audit)).to be_truthy
          end

          it 'is false if the box doesn\'t exist' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            audit_copy.each { |f| f[:box_barcode] = @fake_barcode }
            expect(subject.box_exists_in_repo?(audit_copy)).to be_falsey
          end

        end

      end

      describe 'self#validate_audit_members' do

        before(:all) do
          @audit = PulStore::Lae::JhoveAuditUtilities.parse_audit(@sample_audit)
        end

        describe 'self#check_ocr_image_match' do

          it 'flags an image missing ocr as not to ingest' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            image = audit_copy.select{ |f| f[:path] == @a_tiff_path }.pop
            image[:folder_barcode] = '321010758514xxx'
            image[:sort] = 42
            do_not_ingest = subject.check_ocr_image_match(audit_copy)
            expect(image[:ok_to_ingest?]).to be_falsey
            expect(do_not_ingest.length).to eq 2
          end

          it 'flags an ocr file missing and image as not to ingest' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            ocr = audit_copy.select{ |f| f[:path] == @an_xml_path }.pop
            ocr[:folder_barcode] = '321010758514xxx'
            ocr[:sort] = 42
            do_not_ingest = subject.check_ocr_image_match(audit_copy)
            expect(ocr[:ok_to_ingest?]).to be_falsey
            expect(do_not_ingest.length).to eq 2
          end
        end

        describe 'self#check_for_acceptable_status' do
          it 'flags an image with a status that is not \'valid\' as not to ingest' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            image = audit_copy.select{ |f| f[:path] == @a_tiff_path }.pop
            image[:status] = 'something-else'
            do_not_ingest = subject.check_for_acceptable_status(audit_copy)
            expect(image[:ok_to_ingest?]).to be_falsey
            expect(do_not_ingest.length).to eq 1
          end
          it 'flags an OCR XML with a status that is not \'well-formed\' as not to ingest' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            ocr = audit_copy.select{ |f| f[:path] == @an_xml_path }.pop
            ocr[:status] = 'something-else'
            do_not_ingest = subject.check_for_acceptable_status(audit_copy)
            expect(ocr[:ok_to_ingest?]).to be_falsey
            expect(do_not_ingest.length).to eq 1
          end 
        end

        describe 'self#verify_checksums' do
          it 'flags any file with a mismatched md5 as not to ingest' do
            audit_copy =  Marshal.load(Marshal.dump(@audit))
            f = audit_copy.select{ |f| f[:path] == @a_tiff_path }.pop
            expect(f[:ok_to_ingest?]).to be_truthy
            f[:md5] = 'xxx'

            do_not_ingest = subject.verify_checksums(audit_copy)
            expect(f[:ok_to_ingest?]).to be_falsey
            expect(do_not_ingest.length).to eq 1
          end
        end

        describe 'self#verify_color_profile' do
          before :all do
            @audit_copy =  Marshal.load(Marshal.dump(@audit))
          end

          it 'flags any non images w/o an Adobe 1998 icc profile as not to inagest' do
            wrong_icc = @audit_copy.select{ |f| f[:path] == @a_tiff_path }.pop
            do_not_ingest = subject.verify_color_profile(@audit_copy)
            expect(wrong_icc[:ok_to_ingest?]).to be_falsey
            expect(do_not_ingest.length).to eq 3 # 3 tiffs have the wrong profile
          end
          it 'tiffs with Adobe 1998 are OK' do
            good_icc = @audit_copy.select{ |f| f[:path] == @tiff_correct_icc }.pop
            expect(good_icc[:ok_to_ingest?]).to be_truthy
            subject.verify_color_profile(@audit_copy)
            expect(good_icc[:ok_to_ingest?]).to be_truthy
          end
          it 'Grayscale tiffs OK' do
            good_icc = @audit_copy.select{ |f| f[:path] == @tiff_gray }.pop
            expect(good_icc[:ok_to_ingest?]).to be_truthy
            subject.verify_color_profile(@audit_copy)
            expect(good_icc[:ok_to_ingest?]).to be_truthy
          end
        end
      end

      describe 'self#normalize_windows_path' do
        it 'converts a Windows path to a Unix path' do
          expect(subject.normalize_windows_path(@win_ex_path)).to eq(@unix_ex_path)
        end
        it 'won\'t break a path that is already Unix style' do
          expect(subject.normalize_windows_path(@unix_ex_path)).to eq(@unix_ex_path)
        end
      end

      describe 'self#confirm_corresponding_files_ok' do
        it 'marks an OCR file as not to ingest if the image has a problem' do
          fake_audit = [
            {
              path: "does/not/matter/here/0002.xml", 
              folder_barcode: "32101075851459",
              status: "well-formed",
              mime: "text/xml", 
              ok_to_ingest?: true,
              sort: 2 
            }, {
              path: "does/not/matter/here/0002.tif", 
              folder_barcode: "32101075851459",
              status: "valid",
              mime: "image/tiff",
              ok_to_ingest?: false,
              sort: 2
            }
          ]

          expected = [
            {
              path: "does/not/matter/here/0002.xml", 
              folder_barcode: "32101075851459",
              status: "well-formed",
              mime: "text/xml", 
              ok_to_ingest?: false,
              sort: 2 
            }
          ]
          expect(subject.confirm_corresponding_files_ok(fake_audit)).to eq expected
        end

        it 'marks an image file as not to ingest if the OCR has a problem' do
          fake_audit = [
            {
              path: "does/not/matter/here/0002.xml", 
              folder_barcode: "32101075851459",
              status: "well-formed",
              mime: "text/xml", 
              ok_to_ingest?: false,
              sort: 2 
            }, {
              path: "does/not/matter/here/0002.tif", 
              folder_barcode: "32101075851459",
              status: "valid",
              mime: "image/tiff",
              ok_to_ingest?: true,
              sort: 2
            }
          ]

          expected = [
            {
              path: "does/not/matter/here/0002.tif", 
              folder_barcode: "32101075851459",
              status: "valid",
              mime: "image/tiff",
              ok_to_ingest?: false,
              sort: 2
            }
          ]
          expect(subject.confirm_corresponding_files_ok(fake_audit)).to eq expected
        end
      end

      describe 'self#group_images_and_ocr' do
        it 'does' do
          fake_audit = [
            {
              path: "does/not/matter/here/0002.xml", 
              folder_barcode: "32101075851459", 
              mime: "text/xml", 
              ok_to_ingest?: true,
              sort: 2 
            }, {
              path: "does/not/matter/here/0002.tif", 
              folder_barcode: "32101075851459", 
              mime: "image/tiff", 
              ok_to_ingest?: true,
              sort: 2 
            },{
              path: "does/not/matter/here/0001.xml", 
              folder_barcode: "32101075851459", 
              mime: "text/xml", 
              ok_to_ingest?: true,
              sort: 1 
            }, {
              path: "does/not/matter/here/0001.tif", 
              folder_barcode: "32101075851459", 
              mime: "image/tiff", 
              ok_to_ingest?: true,
              sort: 1 
            }
          ]
          expected = [
            {
              ocr_path: "does/not/matter/here/0002.xml", 
              tiff_path: "does/not/matter/here/0002.tif", 
              folder_barcode: "32101075851459", 
              sort_order: 2, 
            },{
              ocr_path: "does/not/matter/here/0001.xml", 
              tiff_path: "does/not/matter/here/0001.tif", 
              folder_barcode: "32101075851459", 
              sort_order: 1, 
            }
          ]
          expect(subject.filter_and_group_images_and_ocr(fake_audit)).to eq expected

        end
      end
      
    end
  end
end




