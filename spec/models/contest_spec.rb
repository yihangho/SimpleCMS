require 'rails_helper'

describe Contest do
  before do
    @contest = Contest.new(:title => "Contest", :start => "Jul 20, 2014", :end => "Jul 21, 2014", :visibility => "public", :participation => "public")
  end

  subject { @contest }

  it { should respond_to :title }
  it { should respond_to :start }
  it { should respond_to :end }
  it { should respond_to :visibility }
  it { should respond_to :participation }

  it { should respond_to :problems }
  it { should respond_to :creator }
  it { should respond_to :invited_users }
  it { should respond_to :participants }

  context "validations" do
    describe "when title is empty" do
      before { @contest.title = "" }
      it { should_not be_valid }
    end

    describe "when start is unset" do
      before { @contest.start = nil }
      it { should_not be_valid }
    end

    describe "when end is unset" do
      before { @contest.start = nil }
      it { should_not be_valid }
    end

    describe "when start happens after end" do
      before { @contest.start = 1.day.since(@contest.end) }
      it { should_not be_valid }
    end

    describe "when visibility is valid" do
      it "should be valid" do
        Contest.possible_visibilities.each_key do |visibility|
          @contest.visibility = visibility.to_s
          expect(@contest).to be_valid
        end
      end
    end

    describe "when visibility is invalid" do
      it "should not be valid" do
        [nil, "bla"].each do |visibility|
          @contest.visibility = visibility
          expect(@contest).not_to be_valid
        end
      end
    end

    describe "when participation is valid" do
      it "should be valid" do
        Contest.possible_participations.each_key do |participation|
          @contest.participation = participation.to_s
          expect(@contest).to be_valid
        end
      end
    end

    describe "when participation is invalid" do
      it "should not be valid" do
        [nil, "bla"].each do |participation|
          @contest.participation = participation
          expect(@contest).not_to be_valid
        end
      end
    end
  end
end
