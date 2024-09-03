require_relative '../lib/inline_svg'

describe InlineSvg::WebpackAssetFinder do
  context "when Shakapacker is defined" do
    it "uses the new spelling" do
      stub_const('Rails', double('Rails').as_null_object)
      stub_const('Shakapacker', double('Shakapacker').as_null_object)
      expect(::Shakapacker.manifest).to receive(:lookup).with('some-file').and_return(nil)

      expect(described_class.find_asset('some-file').pathname).to be_nil
    end
  end
end
