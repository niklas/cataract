describe Cataract::TitleFinder do
  let(:found_title) { subject.find_title(torrent) }

  context 'for Torrent without title' do
    let(:attrs)   { {} }
    let(:torrent) { instance_double 'Torrent', attrs.merge(title: nil).reverse_merge(persisted?: false) }

    context "with filename present" do
      let(:attrs) {{ filename: 'milch.torrent' }}
      it "is build by filename" do
        found_title.should == 'milch'
      end
    end

    context "with no filename, but url present" do
      let(:attrs) {{ filename: nil, title: nil, url: 'http://blubb.de/Spinat.torrent' }}
      it "is build by last part of url" do
        found_title.should == 'Spinat'
      end
    end

    context "without filename and url present" do
      let(:attrs) {{ filename: nil, title: nil, url: nil }}
      context "unsaved" do
        it "just says 'new'" do
          found_title.should == 'new Torrent'
        end
      end
      context "saved" do
        # may not even valid, but may already exist (legacy)
        it "is build by id" do
          torrent.stub(:persisted?).and_return(true)
          torrent.stub(:id).and_return(2342)
          found_title.should == "Torrent #2342"
        end
      end
    end

  end

end

