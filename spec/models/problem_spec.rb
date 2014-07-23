require 'rails_helper'

describe Problem do
  before do
    @problem = Problem.new(:title => "Problem", :statement => "Test Problem", :visibility => "public")
  end

  subject { @problem }

  it { should respond_to :title }
  it { should respond_to :statement }
  it { should respond_to :visibility }

  it { should respond_to :setter }
  it { should respond_to :tasks }
  it { should respond_to :contests }
  it { should respond_to :solvers }

  context "validations" do
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

  context "access control" do
    before do
      @admin = User.create(:email => "admin@example.com", :password => "12345", :password_confirmation => "12345")
      @user  = User.new(:email => "test@example.com", :password => "12345", :password_confirmation => "12345")
      @participant = User.new(:email => "participant@example.com", :password => "12345", :password_confirmation => "12345")

      @contest = Contest.create(:title => "Test contest", :start => 1.day.ago, :end => 1.day.from_now, :visibility => "public", :participation => "public")
      @contest.participants = [@participant]
      @contest.problems     = [@problem]
      @contest.save

      @problem.setter = @admin
      @problem.save
    end

    describe "public problem" do
      before do
        @problem.visibility = "public"
        @problem.save
      end

      it "should be listed to everyone" do
        [@admin, @user, @participant].each do |user|
          expect(@problem.listed_to?(user)).to be_truthy
        end
      end

      it "should be visible to everyone" do
        [@admin, @user, @participant].each do |user|
          expect(@problem.visible_to?(user)).to be_truthy
        end
      end
    end

    describe "unlisted problem" do
      before do
        @problem.visibility = "unlisted"
        @problem.save
      end

      it "should be listed to its setter" do
        expect(@problem.listed_to?(@admin)).to be_truthy
      end

      it "should not be listed to everyone else" do
        [@user, @participant].each do |user|
          expect(@problem.listed_to?(user)).to be_falsy
        end
      end

      it "should be visible to everyone" do
        [@admin, @user, @participant].each do |user|
          expect(@problem.visible_to?(user)).to be_truthy
        end
      end
    end

    describe "contest-only problem" do
      before do
        @problem.visibility = "contest_only"
        @problem.save
      end

      it "should be listed to its setter" do
        expect(@problem.listed_to?(@admin)).to be_truthy
      end

      it "should not be listed to everyone else" do
        [@user, @participant].each do |user|
          expect(@problem.listed_to?(user)).to be_falsy
        end
      end

      it "should be visible to its setter" do
        expect(@problem.visible_to?(@admin)).to be_truthy
      end

      it "should not be visible to contestant before the contest starts" do
        @contest.start = 1.day.from_now
        @contest.end   = 2.days.from_now
        @contest.save

        expect(@problem.visible_to?(@participant)).to be_falsy
      end

      it "should be visible to contestant during the contest" do
        @contest.start = 1.day.ago
        @contest.end   = 1.day.from_now
        @contest.save

        expect(@problem.visible_to?(@participant)).to be_truthy
      end

      it "should be visible to contestant after the contest" do
        @contest.start = 2.days.ago
        @contest.end   = 1.day.ago
        @contest.save

        expect(@problem.visible_to?(@participant)).to be_truthy
      end

      it "should not be visible to everyone else" do
        expect(@problem.visible_to?(@user)).to be_falsy
      end
    end
  end
end
