require 'open-uri'
require 'zip'
require 'fileutils'

final_dir = Rails.root.join(PUL_STORE_CONFIG['fits_dir'])

open(PUL_STORE_CONFIG['fits_download'], 'rb') do |tmp|
  Zip::File.open(tmp.path) do |zipfile|
    unzip_root = nil
    zipfile.each do |e| # e is a Zip::Entry
      fpath = File.join("/tmp", e.to_s)
      unzip_root = fpath if unzip_root.nil?
      FileUtils.mkdir_p(File.dirname(fpath))
      zipfile.extract(e, fpath){ true }
    end
    FileUtils.mv(unzip_root, final_dir)
  end
end
