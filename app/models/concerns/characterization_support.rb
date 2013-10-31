module CharacterizationSupport
  extend ActiveSupport::Concern

  # included do
  # end

  module ClassMethods
    # may end up wanting an i/o, but FITS would like to know the file extension
    def characterize(path)
      n = File.basename(path)
      Hydra::FileCharacterization.characterize(File.read(path), n, :fits)
    end
  end

end
