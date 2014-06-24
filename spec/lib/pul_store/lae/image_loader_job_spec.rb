require 'spec_helper'

module PulStore
  module Lae
    describe ImageLoaderJob do
      subject { PulStore::Lae::ImageLoaderJob.new }
      before(:all) do
        fixtures_dir = File.join(RSpec.configuration.fixture_path, 'files/lae_test_img')
        @box_barcode = '32101075851483'
        @folder_barcode = '32101075851434'
        @tiff_path = File.join(fixtures_dir, @box_barcode, @folder_barcode, '0002.tif')
        @ocr_path = File.join(fixtures_dir, @box_barcode, @folder_barcode, '0002.xml')
        @sort = 2

        PulStore::Lae::Box.delete_all
        PulStore::Lae::Folder.delete_all
        @box = FactoryGirl.create(:lae_box, barcode: @box_barcode, project: PulStore::Lae::Provenance::PROJECT)
        @folder = FactoryGirl.create(:lae_folder, barcode: @folder_barcode, box: @box, project: PulStore::Lae::Provenance::PROJECT)
      end

      describe 'folder_id_from_barcode' do
        it 'gets the correct folder based on the barcode' do
          pid = subject.folder_id_from_barcode(@folder_barcode)
          expect(pid).to eq @folder.pid
        end
      end

      describe 'build_page' do
        it 'does' do
          fits = PulStore::Page.characterize(@tiff_path)
          page = subject.build_page(@tiff_path, fits, @ocr_path, @folder.pid, @sort)
          @folder.reload
          expect(page.valid?).to be_truthy
          expect(page.sort_order.to_i).to eq @sort # to_i can go in AF 7
          expect(page.folder).to eq @folder
        end
      end

      describe 'make_jp2' do
        it 'does', unless: ENV['TRAVIS'] == 'true' do
          page = FactoryGirl.create(:lae_page, folder: @folder, project: PulStore::Lae::Provenance::PROJECT)
          page.master_image = @tiff_path
          page.save
          jp2 = subject.make_jp2(page)
          expect(page.deliverableImage.content).to eq jp2
          expect(page.valid?).to be_truthy
          expect(page.datastreams['deliverableImage']).to have_content
          expect(page.datastreams['deliverableImage'].mimeType).to eq('image/jp2')
        end
      end


    end
  end
end
