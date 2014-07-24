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
      @admin = User.create(:name => "admin", :email => "admin@example.com", :password => "12345", :password_confirmation => "12345")
      @user  = User.new(:name => "user", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")
      @participant = User.new(:name => "participant", :email => "participant@example.com", :password => "12345", :password_confirmation => "12345")

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

  context "#solved_between_by?" do
    before do
      @problem.save
      @user = User.create(:name => "test", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")
      @task1 = @problem.tasks.create(:input => "12345", :output => "12345")
      @task2 = @problem.tasks.create(:input => "54321", :output => "54321")

      @submission1 = Submission.create(:input => @task1.output, :user_id => @user.id, :task_id => @task1.id)
      @submission2 = Submission.create(:input => @task2.output, :user_id => @user.id, :task_id => @task2.id)

      @start = 2.days.ago
      @end   = 1.day.from_now
    end

    describe "both submissions happen between the given interval" do
      before do
        @submission1.update_attribute(:created_at, 1.day.ago)
        @submission2.update_attribute(:created_at, 1.day.ago)
      end

      it "should return truthy" do
        expect(@problem.solved_between_by?(@start, @end, @user)).to be_truthy
      end

      describe "but one of the submissions is wrong" do
        before do
          @submission1.update_attribute(:input, @submission1.input + "bla")
        end

        it "should return falsy" do
          expect(@problem.solved_between_by?(@start, @end, @user)).to be_falsy
        end
      end
    end

    describe "when one of the submissions happens outside the given interval" do
      it "should return falsy" do
        @submission1.update_attribute(:created_at, 3.days.ago)
        expect(@problem.solved_between_by?(@start, @end, @user)).to be_falsy

        @submission1.update_attribute(:created_at, 2.days.from_now)
        expect(@problem.solved_between_by?(@start, @end, @user)).to be_falsy
      end
    end
  end
end
