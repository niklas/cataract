describe Cataract::Transfer do

  context 'left_seconds' do

    it "calculates on downloading torrent" do
      subject.stub left_bytes: 234, down_rate: 10
      subject.left_seconds.should be_within(0.0001).of(23.4)
    end

    it "returns Infinity when stalled" do
      subject.stub left_bytes: 234, down_rate: 0
      subject.left_seconds.should be_infinite
    end

    it "returns Infinity on unknown down rate" do
      subject.stub left_bytes: 234, down_rate: nil
      subject.left_seconds.should be_infinite
    end

  end

  it 'can be serialized' do
    subject.should respond_to(:read_attribute_for_serialization)
  end

end
