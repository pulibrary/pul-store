module CharacterizationSupport
  extend ActiveSupport::Concern


  # included do

  #   TODO: delegate stuff to techMetadata. See Timestamp for example.

  # end


  module ClassMethods
    def characterize(path)
      n = File.basename(path)
      Hydra::FileCharacterization.characterize(File.read(path).read, n, :fits)
    end
  end

end
