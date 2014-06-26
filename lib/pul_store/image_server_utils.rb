require File.expand_path('../../../config/application', __FILE__)
require 'fileutils'

module PulStore
  class ImageServerUtils
    def self.stream_content_to_image_server(content, pid, suffix='jp2')
      root = PUL_STORE_CONFIG['image_server_store']
      local = pid_to_path(pid)
      path = "#{File.join(root,local)}.#{suffix}"
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb') { |o| o.write content }
    end

    def self.build_iiif_request(pid, params={})
      server = PUL_STORE_CONFIG['image_server_base']#.sub(/\/$/, '')
      id = pid_to_iiif_id(pid)
      region = params.fetch(:region, 'full').tr('/', '')
      size = params.fetch(:size, 'full').tr('/', '')
      rotation = params.fetch(:rotation, '0').tr('/', '')
      quality = params.fetch(:quality, 'native').tr('/', '')
      format = params.fetch(:format, 'jpg').tr('/', '')
      "#{server}/#{id}.jp2/#{region}/#{size}/#{rotation}/#{quality}.#{format}"
    end

    protected
    def self.pid_to_path(pid)
      path = []
      ns, noid = pid.split(':')
      path << ns
      noid.split(//).each { |c| path << c }
      path.join('/')
    end

    def self.pid_to_iiif_id(pid)
      path = []
      ns, noid = pid.split(':')
      path << ns
      noid.split(//).each { |c| path << c }
      path.join('%2F')
    end

  end
end
