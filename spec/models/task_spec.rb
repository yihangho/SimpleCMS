require 'rails_helper'

describe Task do
  before do
    @problem = create(:problem)
    @task    = create(:task, :problem => @problem)
  end

  subject { @task }

  it { should respond_to :input }
  it { should respond_to :output }

  it { should respond_to :problem }
  it { should respond_to :submissions }
  it { should respond_to :solvers }

  context "validations" do
    describe "when problem is nil" do
      before { @task.problem = nil }
      it { should_not be_valid }
    end
  end

  context "#solved_between_by?" do
    before do
      @user = create(:user)
      @submission = @task.submissions.create(:input => @task.output, :user_id => @user.id)
    end

    describe "solved before the starting time" do
      it "should return falsy" do
        start_time = 1.day.since(@submission.created_at)
        end_time   = 2.days.since(@submission.created_at)
        expect(@task.solved_between_by?(start_time, end_time, @user)).to be_falsy
      end
    end

    describe "solved after the ending time" do
      it "should return falsy" do
        start_time = 2.days.until(@submission.created_at)
        end_time   = 1.day.until(@submission.created_at)
        expect(@task.solved_between_by?(start_time, end_time, @user)).to be_falsy
      end
    end

    describe "solved between the starting and ending time" do
      it "should return truthy" do
        start_time = 1.day.until(@submission.created_at)
        end_time   = 1.day.since(@submission.created_at)
        expect(@task.solved_between_by?(start_time, end_time, @user)).to be_truthy
      end
    end

    describe "solved at the starting or ending time" do
      it "should return truthy" do
        start_time = @submission.created_at
        end_time   = 1.day.since(@submission.created_at)
        expect(@task.solved_between_by?(start_time, end_time, @user)).to be_truthy

        start_time = 1.day.until(@submission.created_at)
        end_time   = @submission.created_at
        expect(@task.solved_between_by?(start_time, end_time, @user)).to be_truthy
      end
    end
  end

  context "#regrade" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
      @submission1 = create(:submission, :user => @user1, :task => @task)
      @submission2 = create(:incorrect_submission, :user => @user2, :task => @task)
    end

    describe "before regrading" do
      it "should have correct solvers" do
        expect(@task.solvers).to eq [@user1]
      end

      it "problem should have correct solvers" do
        expect(@task.problem.solvers).to eq [@user1]
      end

      it "submissions should have correct accepted status" do
        expect(@submission1.accepted).to be_truthy
        expect(@submission2.accepted).to be_falsy
      end
    end

    describe "after editing and regrading" do
      before do
        @task.update_attribute(:output, @submission2.input)
        @task.regrade
        @submission1.reload
        @submission2.reload
      end

      it "should have correct solvers" do
        expect(@task.solvers).to eq [@user2]
      end

      it "problem should have correct solvers" do
        expect(@task.problem.solvers).to eq [@user2]
      end

      it "submissions should have correct accepted status" do
        expect(@submission1.accepted).to be_falsy
        expect(@submission2.accepted).to be_truthy
      end
    end
  end
end
