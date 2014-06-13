require File.expand_path('../jhove_audit_utilities', __FILE__)

module PulStore
  module Lae
    class ImageLoaderJob

      def initialize(args={})
        @folder_id = folder_id_from_barcode(args[:folder_barcode])
        @tiff_path = args[:tiff_path]
        @ocr_path = args[:ocr_path]
        @sort_order = args[:sort_order]
      end

      def run
        fits = PulStore::Page.characterize(@tiff_path)
        page = build_page(@tiff_path, fits, @ocr_path, @folder_id, @sort_order)
        jp2_content = make_jp2(page)
        PulStore::ImageServerUtils.stream_content_to_image_server(jp2_content, page.pid)
      end

      def folder_id_from_barcode(barcode)
        PulStore::Lae::Folder.where(prov_metadata__barcode_tesim: barcode).first.pid
      end

      def build_page(tiff_path, fits, ocr_path, folder_id, sort_order)
        page = PulStore::Page.new
        page.master_image = tiff_path
        page.master_tech_metadata = fits
        page.page_ocr = ocr_path
        page.project = PulStore::Lae::Provenance::PROJECT
        page.folder_id = folder_id
        page.sort_order = sort_order
        page.save
        page
      end

      # Saves to repo and returns the stream
      def make_jp2(page)
        page.create_derivatives
        page.save
        page.deliverable_image
      end

    end

  end

end

