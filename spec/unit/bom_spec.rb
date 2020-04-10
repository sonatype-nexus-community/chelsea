require 'chelsea/bom'
require 'chelsea/deps'
require 'ox'
require 'spec_helper'

RSpec.describe Chelsea::Bom do
  before do
     @deps = get_test_dependencies
  end

  it "can render dependencies as xml" do
    bom = Chelsea::Bom.new(@deps)
    expect(bom.xml.class).to eq(Ox::Document)
    expect(bom.to_s.class).to eq(String)
  end
end