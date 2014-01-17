require 'spec_helper'

feature "uploading pages" do

  scenario "uploads file" do
    visit new_pul_store_text_path

    within('form#fileupload') do
      attach_file('pul_store_text_pages', File.join(Rails.root, 'spec/fixtures/files/00000001.tif'))
      click_on('upload')
    end

  end

end
