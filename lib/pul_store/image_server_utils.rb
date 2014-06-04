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

    protected
    def self.pid_to_path(pid)
      path = []
      ns, noid = pid.split(':')
      path << ns
      noid.split(//).each { |c| path << c }
      path.join('/')
    end

  end
end
