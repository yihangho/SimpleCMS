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

  context "status" do
    describe "when contest has not started" do
      it "status should be :not_started" do
        @contest.start = 1.day.from_now
        @contest.end   = 2.days.from_now

        expect(@contest.status).to eq :not_started
      end
    end

    describe "when contest is in progress" do
      it "status should be :in_progress" do
        @contest.start = 1.day.ago
        @contest.end   = 1.day.from_now

        expect(@contest.status).to eq :in_progress
      end
    end

    describe "when contest has ended" do
      it "status should be :ended" do
        @contest.start = 2.days.ago
        @contest.end   = 1.day.ago

        expect(@contest.status).to eq :ended
      end
    end
  end
end
