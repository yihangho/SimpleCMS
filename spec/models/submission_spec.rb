require 'rails_helper'

describe Submission do
  before do
    @problem = Problem.create(:title => "Test", :statement => "Test Problem", :visibility => "public")
    @task1 = @problem.tasks.create(:input => "12345", :output => "12345")
    @task2 = @problem.tasks.create(:input => "54321", :output => "54321")
    @user1 = User.create(:email => "user1@example.com", :password => "12345", :password_confirmation => "12345")
    @submission = @task1.submissions.create
    @submission.user = @user1
    @submission.save
  end

  subject { @submission }

  it { should respond_to :input }
  it { should respond_to :accepted? }
  it { should respond_to :code_link }

  describe "when answer is incorrect" do
    before do
      @submission.input = @submission.task.output + "bla"
      @submission.save
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
    before do
      @submission.input = @submission.task.output
      @submission.save
    end

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
        @incorrect_submission = @task1.submissions.new
        @incorrect_submission.input = @incorrect_submission.task.output + "bla"
        @incorrect_submission.user = @user1
        @incorrect_submission.save
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
      @submission.input = @submission.task.output
      @submission.save

      @submission2 = @task2.submissions.new
      @submission2.input = @submission2.task.output
      @submission2.user  = @user1
      @submission2.save
    end

    it "should solve both tasks" do
      expect(@task1.solved_by?(@user1)).to be_truthy
      expect(@task2.solved_by?(@user1)).to be_truthy
    end

    it "should solve the problem" do
      expect(@problem.solved_by?(@user1)).to be_truthy
    end

    it "should not solve the problem for other user" do
      user2 = User.create(:email => "user2@example.com", :password => "12345", :password_confirmation => "12345")
      expect(@problem.solved_by?(user2)).to be_falsy
    end

    describe "then a wrong submission is sent" do
      before do
        @incorrect_submission = @task1.submissions.new
        @incorrect_submission.input = @incorrect_submission.task.output + "bla"
        @incorrect_submission.user  = @user1
      end

      it "should not unsolve the problem" do
        expect(@problem.solved_by?(@user1)).to be_truthy
      end
    end
  end
end
