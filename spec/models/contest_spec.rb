require 'rails_helper'

describe Contest do
  before do
    @contest = Contest.new(:title => "Contest", :start => 1.day.ago, :end => 1.day.from_now, :visibility => "public", :participation => "public")
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

  context "access control" do
    before do
      @admin = User.create(:email => "admin@example.com", :password => "12345", :password_confirmation => "12345")
      @user  = User.new(:email => "test@example.com", :password => "12345", :password_confirmation => "12345")
      @invited_user = User.new(:email => "invited@example.com", :password => "12345", :password_confirmation => "12345")

      @contest.creator = @admin
      @contest.invited_users = [@invited_user]
      @contest.save
    end

    context "contests list" do
      describe "public contest" do
        before do
          @contest.visibility = "public"
          @contest.save
        end

        it "should be listed to everyone" do
          [@admin, @user, @invited_user].each do |user|
            expect(@contest.listed_to?(user)).to be_truthy
          end
        end
      end

      describe "unlisted contest" do
        before do
          @contest.visibility = "unlisted"
          @contest.save
        end

        it "should be listed to its creator" do
          expect(@contest.listed_to?(@admin)).to be_truthy
        end

        it "should be listed to invited users" do
          expect(@contest.listed_to?(@invited_user)).to be_truthy
        end

        it "should not be listed to others" do
          expect(@contest.listed_to?(@user)).to be_falsy
        end
      end

      describe "invite-only contest" do
        before do
          @contest.visibility = "invite_only"
          @contest.save
        end

        it "should be listed to its creator" do
          expect(@contest.listed_to?(@admin)).to be_truthy
        end

        it "should be listed to invited users" do
          expect(@contest.listed_to?(@invited_user)).to be_truthy
        end

        it "should not be listed to others" do
          expect(@contest.listed_to?(@user)).to be_falsy
        end
      end
    end

    context "visibility" do
      describe "public contest" do
        before do
          @contest.visibility = "public"
          @contest.save
        end

        it "should be listed to everyone" do
          [@admin, @user, @invited_user].each do |user|
            expect(@contest.visible_to?(user)).to be_truthy
          end
        end
      end

      describe "unlisted contest" do
        before do
          @contest.visibility = "unlisted"
          @contest.save
        end

        it "should be listed to everyone" do
          [@admin, @user, @invited_user].each do |user|
            expect(@contest.visible_to?(user)).to be_truthy
          end
        end
      end

      describe "invite-only contest" do
        before do
          @contest.visibility = "invite_only"
          @contest.save
        end

        it "should be listed to its creator" do
          expect(@contest.listed_to?(@admin)).to be_truthy
        end

        it "should be listed to invited users" do
          expect(@contest.listed_to?(@invited_user)).to be_truthy
        end

        it "should not be listed to others" do
          expect(@contest.listed_to?(@user)).to be_falsy
        end
      end
    end

    context "participation" do
      describe "public" do
        before do
          @contest.participation = "public"
          @contest.save
        end

        it "should be able to be participated by everyone" do
          [@admin, @user, @invited_user].each do |user|
            expect(@contest.can_participate_by?(user)).to be_truthy
          end
        end
      end

      describe "invite-only" do
        before do
          @contest.participation = "invite_only"
          @contest.save
        end

        it "should be able to be participated by invited users only" do
          expect(@contest.can_participate_by?(@invited_user)).to be_truthy
          [@admin, @user].each do |user|
            expect(@contest.can_participate_by?(user)).to be_falsy
          end
        end
      end
    end
  end

  context "#num_problems_solved_by" do
    before do
      @contest.save

      @user = User.create(:name => "test", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")

      @problem1 = @contest.problems.create(:title => "P1", :statement => "P1", :visibility => "public")
      @problem2 = @contest.problems.create(:title => "P2", :statement => "P2", :visibility => "public")

      @task1 = @problem1.tasks.create(:input => "12345", :output => "12345")
      @task2 = @problem2.tasks.create(:input => "54321", :output => "54321")

      @submission1 = @user.submissions.create(:input => @task1.output, :task_id => @task1.id)
      @submission2 = @user.submissions.create(:input => @task2.output, :task_id => @task2.id)
    end

    describe "when both problems are solved" do
      describe "and are solved before contest ends" do
        it "should return 2" do
          expect(@contest.num_problems_solved_by(@user)).to eq 2
        end
      end

      describe "when one of the problems is solved before the contest started" do
        before do
          @submission1.update_attribute(:created_at, 1.day.until(@contest.start))
        end

        it "should return 2" do
          expect(@contest.num_problems_solved_by(@user)).to eq 2
        end
      end

      describe "when one of the problems is solved after the contest ended" do
        before do
          @submission1.update_attribute(:created_at, 1.day.since(@contest.end))
        end

        it "should return 1" do
          expect(@contest.num_problems_solved_by(@user)).to eq 1
        end
      end
    end

    describe "when one of the problems is not solved" do
      before do
        @submission1.update_attribute(:input, @submission1.task.output + "bla")
      end

      it "should return 1" do
        expect(@contest.num_problems_solved_by(@user)).to eq 1
      end
    end
  end

  describe "leaderboard" do
    before do
      @user1 = User.create(:name => "test1", :email => "test1@example.com", :password => "12345", :password_confirmation => "12345")
      @user2 = User.create(:name => "test2", :email => "test2@example.com", :password => "12345", :password_confirmation => "12345")
      @user3 = User.create(:name => "test3", :email => "test3@example.com", :password => "12345", :password_confirmation => "12345")

      @contest.participants = [@user1, @user2, @user3]
      @contest.save

      @problem1 = @contest.problems.create(:title => "P1", :statement => "P1", :visibility => "public")
      @problem2 = @contest.problems.create(:title => "P2", :statement => "P2", :visibility => "public")

      @task1 = @problem1.tasks.create(:input => "12345", :output => "12345")
      @task2 = @problem2.tasks.create(:input => "54321", :output => "54321")

      @submission11 = @user1.submissions.create(:input => @task1.output, :task_id => @task1.id)
      @submission12 = @user1.submissions.create(:input => @task2.output, :task_id => @task2.id)

      @submission21 = @user2.submissions.create(:input => @task1.output, :task_id => @task1.id)
    end

    it "should return correct leaderboard" do
      expected_output = [
        {
          :num_solved => 2,
          :user       => @user1,
          :problems   => {
            @task1.id => true,
            @task2.id => true
          }
        }, {
          :num_solved => 1,
          :user       => @user2,
          :problems   => {
            @task1.id => true,
            @task2.id => false
          }
        }, {
          :num_solved => 0,
          :user       => @user3,
          :problems   => {
            @task1.id => false,
            @task2.id => false
          }
        }
      ]
      expect(@contest.leaderboard).to eq expected_output
    end
  end

  context "#can_access_problems_list?" do
    before do
      @contest.save
      @admin = User.create(:name => "Admin", :email => "admin@example.com", :password => "12345", :password_confirmation => "12345", :admin => true)
      @user  = User.create(:name => "User", :email => "user@example.com", :password => "12345", :password_confirmation => "12345")
    end

    describe "before contest starts" do
      before do
        @contest.update_attributes(:start => 1.day.from_now, :end => 2.days.from_now)
      end

      it "should return falsy for user" do
        expect(@contest.can_access_problems_list?(@user)).to be_falsy
      end

      it "should return truthy for admin" do
        expect(@contest.can_access_problems_list?(@admin)).to be_truthy
      end
    end

    describe "during the contest" do
      before do
        @contest.update_attributes(:start => 1.day.ago, :end => 1.day.from_now)
      end

      it "should return truthy for user" do
        expect(@contest.can_access_problems_list?(@user)).to be_truthy
      end

      it "should return truthy for admin" do
        expect(@contest.can_access_problems_list?(@admin)).to be_truthy
      end
    end

    describe "after the contest" do
      before do
        @contest.update_attributes(:start => 2.days.ago, :end => 1.day.ago)
      end

      it "should return truthy for user" do
        expect(@contest.can_access_problems_list?(@user)).to be_truthy
      end

      it "should return truthy for admin" do
        expect(@contest.can_access_problems_list?(@admin)).to be_truthy
      end
    end
  end

  describe "::invited_but_not_participated_by" do
    before do
      @contest1 = Contest.create(:title => "Contest 1", :start => 1.day.ago, :end => 1.day.from_now, :visibility => "public", :participation => "public")
      @contest2 = Contest.create(:title => "Contest 2", :start => 1.day.ago, :end => 1.day.from_now, :visibility => "public", :participation => "public")

      @user = User.create(:name => "Test", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")

      @contest1.invited_users = [@user]
      @contest2.invited_users = [@user]
      @contest2.participants = [@user]
    end

    it "should return correct contests" do
      expect(Contest.invited_but_not_participated_by(@user)).to eq [@contest1]
    end
  end

  context "::upcoming and ::ongoing" do
    before do
      @contest1 = Contest.create(:title => "Contest 1", :start => 1.days.ago, :end => 1.day.from_now, :visibility => "public", :participation => "public")
      @contest2 = Contest.create(:title => "Contest 2", :start => 1.day.from_now, :end => 2.days.from_now, :visibility => "public", :participation => "public")
      @contest3 = Contest.create(:title => "Contest 3", :start => 2.days.ago, :end => 1.day.ago, :visibility => "public", :participation => "public")
    end

    describe "::upcoming" do
      it "should return correct contests" do
        expect(Contest.upcoming).to eq [@contest2]
      end
    end

    describe "::ongoing" do
      it "should return correct contests" do
        expect(Contest.ongoing).to eq [@contest1]
      end
    end
  end
end
