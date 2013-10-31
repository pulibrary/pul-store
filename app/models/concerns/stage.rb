module Stage
  extend ActiveSupport::Concern

  # included do
  # end

  module ClassMethods

    def upload_to_stage(io, name)
      # will need some exception handling
      path = File.join(PUL_STORE_CONFIG['stage_root'], SecureRandom.hex, name)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |file|
        file.write(io.read)
      end
      path
    end

  end

end
