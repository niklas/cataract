describe Cataract::FileNameCleaner do

  describe '.clean' do
    def clean(name)
      described_class.clean(name)
    end
    let(:cleaned)  { clean(filename) }

    it 'handles nil' do
      described_class.clean(nil).should be_nil
    end

    it 'handles empty string' do
      described_class.clean('').should be_nil
    end


    describe "pirate-bay style" do
      let(:filename) { 'Fame of Bones 5x12 [720P - HDTV - OMMARZE].torrent' }
      it "keeps the name" do
        cleaned.should include("Fame of Bones")
      end

      it "keeps season and episode" do
        cleaned.should include("5x12")
      end

      it "keeps 720P info" do
        cleaned.should include("720")
      end

      it "removes brackets" do
        cleaned.should_not include("[")
        cleaned.should_not include("]")
      end

      it "removes extension" do
        cleaned.should_not include(".torrent")
      end

      it "removes release group name" do
        cleaned.should_not include("OMMARZE")
      end
    end

    describe "_kat_ph style" do
      let(:filename) { "_kat.ph_the.peanut.penguins.s01e03.friday.night.fnords.hdtv.xvid.fqm.eztv.torrent" }
      it "removes kat prefix" do
        cleaned.should_not include("_kat.ph_")
        cleaned.should_not include("kat")
        cleaned.should_not include("ph")
      end

      it "keeps season and episode" do
        cleaned.should include('s01e03')
      end

      it "removes format" do
        cleaned.should_not include('xvid')
      end

      it "removes release group name" do
        cleaned.should_not include('fqm')
      end

      it "removes eztv" do
        cleaned.should_not include('eztv')
      end
    end

    it 'removes source in [brackets]' do
      clean("[fnord.to]the.weekly.digest.torrent").should_not include('fnord.to')
    end

    it 'removes source in _underscores' do
      clean("_kickass.to_lekker").should == 'lekker'
    end

    it 'removes x264' do
      clean("lululul.hdtv.x264.fqm").should_not include('x264')
    end

  end
end

