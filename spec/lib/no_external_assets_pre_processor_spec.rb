require 'spec_helper'



describe NoExternalAssetsPreProcessor do
  it "replaces Droid font reference" do
    preproc = described_class.new( Rails.root.join('spec/fixtures/bootswatch_external_font.css').to_s )
    filtered = preproc.evaluate(stub,stub)
    filtered.should_not include('googleapis')
  end

end
