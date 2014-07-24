require 'rails_helper'

describe Task do
  before { @task = Task.new }

  subject { @task }

  it { should respond_to :input }
  it { should respond_to :output }

  it { should respond_to :problem }
  it { should respond_to :submissions }
  it { should respond_to :solvers }

  context "#solved_between_by?" do
    before do
      @user = User.create(:name => "Test", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")
      @task = Task.create(:input => "1234", :output => "1234")
      @submission = Submission.create(:input => @task.output, :task_id => @task.id, :user_id => @user.id)
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
end
