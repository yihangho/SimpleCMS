class Task < ActiveRecord::Base
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_tasks", :validate => false
  has_many :seeds

  validates :problem_id, :presence => true
  validates :point, :tokens, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }

  after_initialize do
    self.point ||= 0
  end

  def raw_input(user)
    return nil unless user && !user.new_record?

    seed = Seed.find_by(:task_id => id, :user_id => user.id)
    unless seed
      seed = seeds.create(:user_id => user.id, :seed => Random.new_seed)
    end

    eval(input_generator)
    generate_input(seed.seed.to_i)
  end

  def solved_by?(user)
    solvers.include?(user)
  end

  def solved_between_by?(time1, time2, user)
    user.submissions.for(self).correct_answer.where(:created_at => (time1..time2)).any?
  end

  def attempted_by?(user)
    user && user.submissions.for(self).any?
  end

  def grade(answer, user)
    eval(grader)
    grade_answer(raw_input(user), answer)
  end

  def regrade
    submissions.each do |submission|
      submission.regrade
    end

    update_solvers
    problem.update_solvers
  end

  def submissions_left_for(user)
    user ||= User.new

    if problem.contest_only?
      if problem.contests.participated_by(user).any?
        if tokens == 0 || problem.contests.ended.participated_by(user).any?
          :unlimited
        elsif problem.contests.ongoing.participated_by(user).any?
          [0, tokens - user.submissions.for(self).count].max
        else
          :not_allowed
        end
      else
        :not_allowed
      end
    else
      :unlimited
    end
  end

  def allowed_to_submit?(user)
    ![0, :not_allowed].include?(submissions_left_for(user))
  end

  def update_solvers
    self.solvers = User.select do |user|
      user.submissions.for(self).correct_answer.any?
    end
  end

  def to_h(user = User.new)
    hash = attributes.dup
    hash.delete("input_generator") unless user.admin?
    hash.delete("grader") unless user.admin?
    begin
      hash[:input] = InputEncoder::Python.encode(raw_input(user))
    rescue
    end
    hash[:submission] = user.submissions.for(self).last
    hash[:submissions_left] = submissions_left_for(user)
    hash[:submission_allowed] = allowed_to_submit?(user)
    hash[:attempted] = attempted_by?(user)
    hash[:solved] = solved_by?(user)
    hash
  end
end
