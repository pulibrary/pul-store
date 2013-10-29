module TestTemps
  class CharacterizationDouble
    include Characterization
  end
end

describe Characterization do
  context "when included in a class" do
    it_behaves_like "supports characterization"
  end
end
