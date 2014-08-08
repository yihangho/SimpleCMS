require 'rails_helper'

describe Task do
  before do
    @problem = create(:problem)
    @task    = create(:task, :problem => @problem)
  end

  subject { @task }

  it { should respond_to :input }
  it { should respond_to :output }
  it { should respond_to :point }
  it { should respond_to :tokens }

  it { should respond_to :problem }
  it { should respond_to :submissions }
  it { should respond_to :solvers }

  it { should respond_to :submissions_left_for }

  context "validations" do
    describe "when problem is nil" do
      before { @task.problem = nil }
      it { should_not be_valid }
    end

    describe "when point is negative" do
      before { @task.point = -1 }
      it { should_not be_valid }
    end

    describe "when point is not an integer" do
      before { @task.point = 1.5 }
      it { should_not be_valid }
    end

    describe "when tokens is negative" do
      before { @task.tokens = -1 }
      it { should_not be_valid }
    end

    describe "when tokens is not an integer" do
      before { @task.tokens = 1.5 }
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

  describe "#submissions_left_for and #allowed_to_submit?" do
    before do
      @contest = create(:contest, :problems => [@problem])

      @participant = create(:user, :participated_contests => [@contest])
      @user = create(:user)
    end

    describe "task belonging to non-contest-only problem set to non-0" do
      before do
        @problem.update_attribute(:contest_only, false)
        @task.update_attribute(:tokens, 5)
      end

      it "should return :unlimited to everyone" do
        expect(@task.submissions_left_for(@user)).to eq :unlimited
        expect(@task.submissions_left_for(@participant)).to eq :unlimited
      end

      it "should return truthy for everyone" do
        expect(@task.allowed_to_submit?(@user)).to be_truthy
        expect(@task.allowed_to_submit?(@participant)).to be_truthy
      end
    end

    describe "task belonging to contest-only problem" do
      before { @problem.update_attribute(:contest_only, true) }

      it "should return :not_allowed for non-participant" do
        expect(@task.submissions_left_for(@user)).to eq :not_allowed
      end

      it "should return falsy for non-participant" do
        expect(@task.allowed_to_submit?(@user)).to be_falsy
      end

      describe "task with tokens set to 0" do
        before { @task.tokens = 0 }
        it "should always return :unlimited for participants" do
          expect(@task.submissions_left_for(@participant)).to eq :unlimited
          create(:submission, :user => @participant, :task => @task)
          expect(@task.submissions_left_for(@participant)).to eq :unlimited
        end

        it "should return truthy for participants" do
          expect(@task.allowed_to_submit?(@participant)).to be_truthy
        end
      end

      describe "task with tokens not set to 0" do
        before { @task.tokens = 5 }

        describe "before the contest" do
          before do
            @contest.start = 1.day.from_now
            @contest.end   = 2.days.from_now
            @contest.save
          end
          it "should return the correct number" do
            expect(@task.submissions_left_for(@participant)).to eq :not_allowed
          end
          it "should return falsy" do
            expect(@task.allowed_to_submit?(@participant)).to be_falsy
          end
        end

        describe "during the contest" do
          before do
            @contest.start = 1.day.ago
            @contest.end   = 1.day.from_now
            @contest.save
          end
          it "should return the correct number" do
            expect(@task.submissions_left_for(@participant)).to eq 5
            create(:submission, :user => @participant, :task => @task)
            expect(@task.submissions_left_for(@participant)).to eq 4
          end
          it "should return truthy" do
            expect(@task.allowed_to_submit?(@participant)).to be_truthy
          end
        end

        describe "after the contest" do
          before do
            @contest.start = 2.days.ago
            @contest.end   = 1.day.ago
            @contest.save
          end
          it "should always return :unlimited" do
            expect(@task.submissions_left_for(@participant)).to eq :unlimited
            create(:submission, :user => @participant, :task => @task)
            expect(@task.submissions_left_for(@participant)).to eq :unlimited
          end
          it "should return truthy" do
            expect(@task.allowed_to_submit?(@participant)).to be_truthy
          end
        end
      end
    end
  end
end
