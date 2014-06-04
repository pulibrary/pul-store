require 'spec_helper'
require File.expand_path('../../../../config/application', __FILE__)

module PulStore
  describe ImageServerUtils do
    subject { PulStore::ImageServerUtils }
    before(:all) do
      @fake_pid = 'puls:my42pid'
      @fake_pid_as_path = 'puls/m/y/4/2/p/i/d'
      @image_server_store = PUL_STORE_CONFIG['image_server_store']
      # @tiff_path = File.join(RSpec.configuration.fixture_path, 'files/00000001.tif')
      @tiff_path = '/home/jstroop/workspace/pul-store/spec/fixtures/files/lae_test_img/32101075851483/32101075851459/0001.tif'
    end

    describe '#pid_to_path' do
      it 'turns a ns:noid string into a path as expected' do
        expect(subject.pid_to_path(@fake_pid)).to eq @fake_pid_as_path
      end
    end

    describe '#stream_content_to_image_server' do
      it 'writes the stream to the expected place', unless: ENV['TRAVIS'] == 'true' do
        expected_path = "#{File.join(@image_server_store, @fake_pid_as_path)}.jp2"
        page = FactoryGirl.create(:page, project: FactoryGirl.create(:project))
        page.master_image = @tiff_path
        page.save
        page.create_derivatives
        page.save
        jp2_content = page.deliverable_image
        subject.stream_content_to_image_server(jp2_content, @fake_pid)
        expect(File.exists?(expected_path)).to be_true
      end
    end
    
  end
end
