require File.expand_path('../jhove_audit_utilities', __FILE__)

module PulStore
  module Lae
    class ImageLoaderJob

      @@logger = Logger.new("#{Rails.root}/log/lae_ingest_#{Date.today.strftime('%Y-%m-%d')}.log")

      def initialize(args={})
        @folder_id = folder_id_from_barcode(args[:folder_barcode])
        @folder_barcode = args[:folder_barcode]
        @tiff_path = args[:tiff_path]
        @ocr_path = args[:ocr_path]
        @sort_order = args[:sort_order]
        # @logger = Logger.new("#{Rails.root}/log/lae_ingest_#{Date.today.strftime('%Y-%m-%d')}.log")
      end

      def to_hash
        hash = {}
        hash["folder_id"] = @folder_id
        hash["folder_barcode"] = @folder_barcode
        hash["tiff_path"] = @tiff_path
        hash["ocr_path"] = @ocr_path
        hash["sort_order"] = @sort_order
        hash
      end

      def run
        # Do not duplicate pages!
        unless page_exists?
          fits = PulStore::Page.characterize(@tiff_path)
          page = build_page(@tiff_path, fits, @ocr_path, @folder_id, @sort_order)
          jp2_content = make_jp2(page)
          PulStore::ImageServerUtils.stream_content_to_image_server(jp2_content, page.pid)
        else
          @@logger.warn("Folder #{@folder_barcode} (pid: #{@folder_id}), page #{@sort_order} already exists!")
        end
      end

      def folder_id_from_barcode(barcode)
        PulStore::Lae::Folder.where(prov_metadata__barcode_tesi: barcode).first.pid
      end

      def page_exists?
        folder = PulStore::Lae::Folder.find(@folder_id)
        folder.pages.any? { |p| p.sort_order == @sort_order }
      end

      def build_page(tiff_path, fits, ocr_path, folder_id, sort_order)
        page = PulStore::Page.new
        page.master_image = tiff_path
        page.master_tech_metadata = fits
        page.page_ocr = ocr_path
        page.project = PulStore::Lae::Provenance::PROJECT
        page.folder_id = folder_id
        page.sort_order = sort_order
        page.label = "Image #{sort_order}"
        page.save
        PulStore::Lae::Folder.find(folder_id).save
        page
      rescue => e
        @@logger.error("Something went wrong building a page")
        @@logger.error("tiff_path: #{tiff_path}")
        @@logger.error("ocr_path: #{ocr_path}")
        @@logger.error("folder_id: #{folder_id}")
        @@logger.error("folder_barcode: #{@folder_barcode}")
        @@logger.error("sort_order: #{sort_order}")
        @@logger.error(e.message)
        @@logger.error(e.backtrace)
      end

      # Saves to repo and returns the stream
      def make_jp2(page)
        page.create_derivatives
        page.save
        page.deliverable_image
      rescue => e
        @@logger.error("Something went wrong making a JP2 for #{page.pid}")
        @@logger.error(e.message)
        @@logger.error(e.backtrace)
      end

    end

  end

end
