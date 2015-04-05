require 'spec_helper'

describe RemoteTorrent do

  context '#id' do
    let(:hash) { 'ABCDef01' * 5 }

    it 'is extracted from magnet link' do
      r = described_class.new(
        magnet: "magnet:?xt=urn:btih:#{hash}&dn=shame+of+frowns+s05e00+a+day+in+the+life+hdtv+x264+batv+eztv&tr=udp%3A%2F%2Fopen.leghost.com%3A1337%2Fannounce"
      )
      r.id.should == hash
    end
  end

end
