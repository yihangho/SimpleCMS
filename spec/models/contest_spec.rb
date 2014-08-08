require 'rails_helper'

describe Contest do
  before do
    @contest = build(:contest)
  end

  subject { @contest }

  it { should respond_to :title }
  it { should respond_to :instructions }
  it { should respond_to :start }
  it { should respond_to :end }
  it { should respond_to :visibility }
  it { should respond_to :participation }

  it { should respond_to :permalink }
  it { should respond_to :problems }
  it { should respond_to :creator }
  it { should respond_to :invited_users }
  it { should respond_to :participants }
  it { should respond_to :announcements }

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

  context "permalink" do
    describe "creating permalink" do
      before { @contest.save }

      it "should increase the number of permalinks" do
        expect { @contest.create_permalink(:url => "test") }.to change { Permalink.count }.by(1)
      end
    end

    describe "destroying the contest" do
      before do
        @contest.save
        @contest.create_permalink(:url => "test")
      end

      it "should free up its permalink" do
        expect { @contest.destroy }.to change { Permalink.count }.by(-1)
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
      @admin = create(:admin)
      @user = build(:user)
      @invited_user = build(:user)

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

      @user = create(:user)

      @problem1 = create(:problem, :contests => [@contest])
      @problem2 = create(:problem, :contests => [@contest])

      @task1 = create(:task, :problem => @problem1)
      @task2 = create(:task, :problem => @problem2)

      @submission2 = create(:submission, :user => @user, :task => @task2)
    end

    describe "when both problems are solved" do
      describe "and are solved before contest ends" do
        before { @submission1 = create(:submission, :user => @user, :task => @task1) }
        it "should return 2" do
          expect(@contest.num_problems_solved_by(@user)).to eq 2
        end
      end

      describe "when one of the problems is solved before the contest started" do
        before do
          @submission1 = create(:submission, :user => @user, :task => @task1, :created_at => 1.day.until(@contest.start))
        end

        it "should return 2" do
          expect(@contest.num_problems_solved_by(@user)).to eq 2
        end
      end

      describe "when one of the problems is solved after the contest ended" do
        before do
          @submission1 = create(:submission, :user => @user, :task => @task1, :created_at => 1.day.since(@contest.end))
        end

        it "should return 1" do
          expect(@contest.num_problems_solved_by(@user)).to eq 1
        end
      end
    end

    describe "when one of the problems is not solved" do
      before do
        @submission1 = create(:incorrect_submission, :user => @user, :task => @task1)
      end

      it "should return 1" do
        expect(@contest.num_problems_solved_by(@user)).to eq 1
      end
    end
  end

  describe "leaderboard" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
      @user3 = create(:user)

      @contest.participants = [@user1, @user2, @user3]
      @contest.save

      @problem1 = create(:problem, :contests => [@contest])
      @problem2 = create(:problem, :contests => [@contest])

      @task1 = create(:task, :problem => @problem1, :point => 10)
      @task2 = create(:task, :problem => @problem2, :point => 20)

      @submission11 = create(:submission, :user => @user1, :task => @task1)
      @submission12 = create(:submission, :user => @user1, :task => @task2)
      @submission21 = create(:submission, :user => @user2, :task => @task1)
    end

    it "should return correct leaderboard" do
      expected_output = [
        {
          :points   => 30,
          :user     => @user1,
          :problems => {
            @problem1.id => 10,
            @problem2.id => 20
          }
        }, {
          :points   => 10,
          :user     => @user2,
          :problems => {
            @problem1.id => 10,
            @problem2.id => 0
          }
        }, {
          :points   => 0,
          :user     => @user3,
          :problems => {
            @problem1.id => 0,
            @problem2.id => 0
          }
        }
      ]
      expect(@contest.leaderboard).to eq expected_output
    end
  end

  context "#can_access_problems_list?" do
    before do
      @contest.save
      @admin = create(:admin)
      @user = create(:user)
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
      @contest1 = create(:contest)
      @contest2 = create(:contest)

      @user = create(:user)

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
      @contest1 = create(:contest, :start => 1.days.ago, :end => 1.day.from_now)
      @contest2 = create(:contest, :start => 1.day.from_now, :end => 2.days.from_now)
      @contest3 = create(:contest, :start => 2.days.ago, :end => 1.day.ago)
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
