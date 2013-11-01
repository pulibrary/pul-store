module TestTemps
  class CharacterizationSupportDouble
    include CharacterizationSupport
  end
end
# This is a little wierd, but it does what we need for now.

shared_examples "supports characterization" do
  it 'can characterize an image' do
    fp = RSpec.configuration.fixture_path + "/files/00000001.tif"
    TestTemps::CharacterizationSupportDouble.characterize(fp)
  end
end
