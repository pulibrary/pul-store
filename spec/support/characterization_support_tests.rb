module TestTemps
  class CharacterizationSupportDouble
    include CharacterizationSupport
  end
end

# This is a little wierd, but it does what we need for now.

shared_examples "supports characterization" do

  it "has a property for the location of the fits script" do
    PUL_STORE_CONFIG.keys.include?('fits_sh').should be_true
  end

  it "points to a fits script that exists" do
    File.exists?(PUL_STORE_CONFIG['fits_sh']).should be_true
  end

  it "points to a script that is executable" do
    File.executable?(PUL_STORE_CONFIG['fits_sh']).should be_true
  end

  it 'can characterize an image' do
    fp = RSpec.configuration.fixture_path + "/files/00000001.tif"
    TestTemps::CharacterizationSupportDouble.characterize(fp)
  end

end
