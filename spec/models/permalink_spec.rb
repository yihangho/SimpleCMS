require 'rails_helper'

describe Permalink do
  before do
    @permalink = Permalink.new(:url => "123")
  end

  subject { @permalink }

  it { should respond_to :url }

  it { should respond_to :linkable }

  context "validations" do
    describe "URL must be present" do
      before { @permalink.url = "" }
      it { should_not be_valid }
    end

    describe "URL must be unique" do
      before { Permalink.create(:url => @permalink.url.upcase) }
      it { should_not be_valid }
    end
  end
end
