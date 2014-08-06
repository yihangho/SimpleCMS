require 'rails_helper'

describe Submission do
  before do
    @problem = create(:problem)
    @task1 = create(:task, :problem => @problem)
    @task2 = create(:task, :problem => @problem)
    @user1 = create(:user)
    @submission = create(:submission, :user => @user1, :task => @task1)
  end

  subject { @submission }

  it { should respond_to :input }
  it { should respond_to :accepted? }
  it { should respond_to :code_link }

  context "validations" do
    describe "when user is nil" do
      before { @submission.user = nil }
      it { should_not be_valid }
    end

    describe "when task is nil" do
      before { @submission.task = nil }
      it { should_not be_valid }
    end
  end

  describe "when answer is incorrect" do
    before do
      @submission = create(:incorrect_submission)
    end

    it "#correct_input? should be falsy" do
      expect(@submission.correct_input?).to be_falsy
    end

    it "#accepted should be falsy" do
      expect(@submission.accepted).to be_falsy
    end

    it "should not solve the task" do
      expect(@submission.task.solved_by?(@submission.user)).to be_falsy
    end

    it "should not solve the problem" do
      expect(@submission.task.problem.solved_by?(@submission.user)).to be_falsy
    end
  end

  describe "when answer is correct" do
    it "#correct_input? should be truthy" do
      expect(@submission.correct_input?).to be_truthy
    end

    it "#accepted should be truthy" do
      expect(@submission.accepted).to be_truthy
    end

    it "should solve the task" do
      expect(@submission.task.solved_by?(@submission.user)).to be_truthy
    end

    describe "then a new submission is sent with incorrect answer" do
      before do
        @incorrect_submission = create(:incorrect_submission, :user => @user1, :task => @task1)
      end

      it "should be a wrong submission" do
        expect(@incorrect_submission.accepted?).to be_falsy
      end

      it "should still solve the task" do
        expect(@incorrect_submission.task.solved_by?(@incorrect_submission.user)).to be_truthy
      end

      it "should not solve the problem" do
        expect(@submission.task.problem.solved_by?(@submission.user)).to be_falsy
      end
    end
  end

  describe "when correct submissions are sent for all tasks" do
    before do
      @submission2 = create(:submission, :task => @task2, :user => @user1)
    end

    it "should solve both tasks" do
      expect(@task1.solved_by?(@user1)).to be_truthy
      expect(@task2.solved_by?(@user1)).to be_truthy
    end

    it "should solve the problem" do
      expect(@problem.solved_by?(@user1)).to be_truthy
    end

    it "should not solve the problem for other user" do
      user2 = create(:user)
      expect(@problem.solved_by?(user2)).to be_falsy
    end

    describe "then a wrong submission is sent" do
      before do
        @incorrect_submission = create(:incorrect_submission)
      end

      it "should not unsolve the problem" do
        expect(@problem.solved_by?(@user1)).to be_truthy
      end
    end
  end
end
