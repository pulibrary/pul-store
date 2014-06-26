require 'spec_helper'
require File.expand_path('../../../../config/application', __FILE__)

module PulStore
  describe ImageServerUtils do
    subject { PulStore::ImageServerUtils }
    let(:fake_pid) { 'puls:my42pid' }
    let(:fake_pid_as_path) { 'puls/m/y/4/2/p/i/d' }
    let(:fake_pid_as_iiif_id) { 'puls%2Fm%2Fy%2F4%2F2%2Fp%2Fi%2Fd' }
    let(:image_server_store) { PUL_STORE_CONFIG['image_server_store'] }
    let(:image_server_base) { PUL_STORE_CONFIG['image_server_base'] }
    let(:tiff_path) { '/home/jstroop/workspace/pul-store/spec/fixtures/files/lae_test_img/32101075851483/32101075851459/0001.tif' }

    describe '#pid_to_path' do
      it 'turns a ns:noid string into a path as expected' do
        expect(subject.pid_to_path(fake_pid)).to eq fake_pid_as_path
      end
    end

    describe '#stream_content_to_image_server' do
      it 'writes the stream to the expected place', unless: ENV['TRAVIS'] == 'true' do
        expected_path = "#{File.join(image_server_store, fake_pid_as_path)}.jp2"
        page = FactoryGirl.create(:page, project: FactoryGirl.create(:project))
        page.master_image = tiff_path
        page.save
        page.create_derivatives
        page.save
        jp2_content = page.deliverable_image
        subject.stream_content_to_image_server(jp2_content, fake_pid)
        expect(File.exists?(expected_path)).to be true
      end
    end

    describe 'self.build_iiif_request' do
      it 'has an expected set of defaults' do
        expected = "#{image_server_base}/#{fake_pid_as_iiif_id}.jp2/full/full/0/native.jpg"
        actual = subject.build_iiif_request(fake_pid)
        expect(actual).to eq expected
      end

      it 'has can take iiif style params' do
        # See http://iiif.io/api/image/1.1/#parameters
        expected = "#{image_server_base}/#{fake_pid_as_iiif_id}.jp2/full/120,/0/color.png"
        actual = subject.build_iiif_request(fake_pid, size: '120,', quality: 'color', format: 'png')
        expect(actual).to eq expected
      end

      it 'provides an info.json file' do
        expected = "#{image_server_base}/#{fake_pid_as_iiif_id}.jp2/info.json"
        actual = subject.build_iiif_info_request(fake_pid)
        expect(actual).to eq expected
      end
    end
  end
end
