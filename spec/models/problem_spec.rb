require 'rails_helper'

describe Problem do
  before do
    @problem = Problem.new(:title => "Problem", :statement => "Test Problem")
  end

  subject { @problem }

  it { should respond_to :title }
  it { should respond_to :statement }
  it { should respond_to :visibility }

  it { should respond_to :setter }
  it { should respond_to :tasks }
  it { should respond_to :contests }
  it { should respond_to :solvers }

  describe "when title is empty" do
    before { @problem.title = "" }
    it { should_not be_valid }
  end

  describe "when statement is empty" do
    before { @problem.statement = "" }
    it { should_not be_valid }
  end

  describe "when visibility is valid" do
    it "should be valid" do
      Problem.possible_visibilities.each_key do |visibility|
        @problem.visibility = visibility.to_s
        expect(@problem).to be_valid
      end
    end
  end

  describe "when visibility is invalid" do
    it "should be invalid" do
      [nil, "bla"].each do |visibility|
        @problem.visibility = visibility
        expect(@problem).not_to be_valid
      end
    end
  end
end
