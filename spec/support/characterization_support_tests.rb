shared_examples "supports characterization" do

  it "can find the fits executable" do
    PUL_STORE_CONFIG.keys.include?('fits_sh').should be_true
  end

end
