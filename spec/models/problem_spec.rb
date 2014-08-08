require 'rails_helper'

describe Problem do
  before do
    @problem = build(:problem)
  end

  subject { @problem }

  it { should respond_to :title }
  it { should respond_to :statement }
  it { should respond_to :contest_only? }

  it { should respond_to :permalink }
  it { should respond_to :setter }
  it { should respond_to :tasks }
  it { should respond_to :contests }
  it { should respond_to :solvers }

  it { should respond_to :attempted_by? }
  it { should respond_to :last_submissions_by }
  it { should respond_to :total_points }
  it { should respond_to :points_for }
  it { should respond_to :points_for_between }

  context "validations" do
    describe "when title is empty" do
      before { @problem.title = "" }
      it { should_not be_valid }
    end

    describe "when statement is empty" do
      before { @problem.statement = "" }
      it { should_not be_valid }
    end
  end

  context "permalink" do
    describe "creating permalink" do
      before { @problem.save }

      it "should increase the number of permalinks" do
        expect { @problem.create_permalink(:url => "test") }.to change { Permalink.count }.by(1)
      end
    end

    describe "destroying the contest" do
      before do
        @problem.save
        @problem.create_permalink(:url => "test")
      end

      it "should free up its permalink" do
        expect { @problem.destroy }.to change { Permalink.count }.by(-1)
      end
    end
  end

  context "access control" do
    before do
      @admin = @problem.setter
      @user = build(:user)
      @participant = create(:user)

      @contest = create(:contest)
      @contest.participants = [@participant]
      @contest.problems     = [@problem]
      @contest.save

      @problem.setter = @admin
      @problem.save
    end

    describe "non-contest-only problem" do
      before do
        @problem.update_attribute(:contest_only, false)
      end

      it "should be visible to everyone" do
        [@admin, @user, @participant].each do |user|
          expect(@problem.visible_to?(user)).to be_truthy
        end
      end
    end

    describe "contest-only problem" do
      before do
        @problem.update_attribute(:contest_only, true)
      end

      it "should be visible to admin" do
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

      @user = create(:user)
      @task1 = @problem.tasks.create(:input => "12345", :output => "12345")
      @task2 = @problem.tasks.create(:input => "54321", :output => "54321")

      @start = 2.days.ago
      @end   = 1.day.from_now
    end

    describe "both submissions happen between the given interval" do
      before do
        @submission1 = create(:submission, :task => @task2, :user => @user, :created_at => 1.day.ago)
      end

      describe "with correct answers" do
        before do
          @submission1 = create(:submission, :task => @task1, :user => @user, :created_at => 1.day.ago)
        end

        it "should return truthy" do
          expect(@problem.solved_between_by?(@start, @end, @user)).to be_truthy
        end
      end

      describe "one of the submissions is wrong" do
        before do
          @submission1 = create(:incorrect_submission, :task => @task1, :user => @user, :created_at => 1.day.ago)
        end

        it "should return falsy" do
          expect(@problem.solved_between_by?(@start, @end, @user)).to be_falsy
        end
      end
    end

    describe "when one of the submissions happens outside the given interval" do
      before do
        @submission1 = create(:submission, :task => @task1, :user => @user)
        @submission2 = create(:submission, :task => @task2, :user => @user)
      end

      it "should return falsy" do
        @submission1.update_attribute(:created_at, 3.days.ago)
        expect(@problem.solved_between_by?(@start, @end, @user)).to be_falsy

        @submission1.update_attribute(:created_at, 2.days.from_now)
        expect(@problem.solved_between_by?(@start, @end, @user)).to be_falsy
      end
    end
  end

  context "#update_solvers" do
    before do
      @problem.save

      @task1 = @problem.tasks.create(:input => "12345", :output => "12345")
      @task2 = @problem.tasks.create(:input => "54321", :output => "54321")

      @user1 = create(:user)
      @user2 = create(:user)

      @submission11 = @user1.submissions.create(:input => "12345", :task_id => @task1.id)
      @submission12 = @user1.submissions.create(:input => "12345", :task_id => @task2.id)

      @submission21 = @user2.submissions.create(:input => "12345", :task_id => @task1.id)
      @submission22 = @user2.submissions.create(:input => "54321", :task_id => @task2.id)
    end

    describe "before updating" do
      it "should have correct solvers" do
        expect(@problem.solvers).to eq [@user2]
      end
    end

    describe "after editing, regrading and updating" do
      before do
        @task2.update_attribute(:output, "12345")
        @task2.regrade
        @problem.update_solvers
      end

      it "should have correct_solvers" do
        expect(@problem.solvers).to eq [@user1]
      end
    end
  end

  describe "#last_submissions_by" do
    before do
      @problem.save

      @task1 = create(:task, :problem => @problem)
      @task2 = create(:task, :problem => @problem)
      @task3 = create(:task, :problem => @problem)

      @user1 = create(:user)
      @user2 = create(:user)

      @submission111 = create(:submission, :task => @task1, :user => @user1)
      @submission112 = create(:submission, :task => @task1, :user => @user1)
      @submission121 = create(:submission, :task => @task2, :user => @user1)

      @submission211 = create(:submission, :task => @task1, :user => @user2)
      @submission221 = create(:submission, :task => @task2, :user => @user2)
      @submission231 = create(:submission, :task => @task3, :user => @user2)
    end

    it "should return correct array" do
      expected_output = {
        @task1.id => @submission112,
        @task2.id => @submission121,
        @task3.id => nil
      }
      expect(@problem.last_submissions_by(@user1)).to eq expected_output
    end
  end

  describe "#total_points" do
    before do
      @problem.save

      @task1 = create(:task, :problem => @problem, :point => 10)
      @task2 = create(:task, :problem => @problem, :point => 20)
    end

    it "should return correct total points" do
      expect(@problem.total_points).to eq 30
    end
  end

  describe "#points_for" do
    before do
      @problem.save

      @task1 = create(:task, :problem => @problem, :point => 10)
      @task2 = create(:task, :problem => @problem, :point => 20)

      @user = create(:user)

      create(:incorrect_submission, :user => @user, :task => @task1)
      create(:submission, :user => @user, :task => @task1)
      create(:incorrect_submission, :user => @user, :task => @task2)
    end

    it "should return correct points" do
      expect(@problem.points_for(@user)).to eq 10
    end
  end

  describe "#points_for_between" do
    before do
      @problem.save

      @task1 = create(:task, :problem => @problem, :point => 10)
      @task2 = create(:task, :problem => @problem, :point => 20)

      @user = create(:user)

      create(:submission, :user => @user, :task => @task1)
      create(:incorrect_submission, :user => @user, :task => @task2)
    end

    it "should count submission that happens inside the interval" do
      expect(@problem.points_for_between(@user, 1.day.ago, 1.day.from_now)).to eq 10
    end

    it "should not count submission that happens outside the interval" do
      expect(@problem.points_for_between(@user, 2.days.ago, 1.day.ago)).to eq 0
      expect(@problem.points_for_between(@user, 1.day.from_now, 2.days.from_now)).to eq 0
    end
  end

  describe "#attempted_by?" do
    before do
      @problem.save

      @task1 = create(:task, :problem => @problem)
      @task2 = create(:task, :problem => @problem)
      @task3 = create(:task, :problem => @problem)

      @user = create(:user)
    end

    describe "before submitting" do
      it "should return falsy" do
        expect(@problem.attempted_by?(@user)).to be_falsy
      end
    end

    describe "after submitting" do
      before do
        create(:submission, :user => @user, :task => @task1)
        create(:submission, :user => @user, :task => @task2)
      end

      it "should return truthy" do
        expect(@problem.attempted_by?(@user)).to be_truthy
      end
    end
  end
end
