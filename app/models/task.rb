class Task < ActiveRecord::Base
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_many :seeds

  validates :input_generator, :grader, :presence => true
  validates :point, :tokens, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }

  validate :working_input_generator_and_grader

  after_initialize do
    self.point ||= 0
  end

  after_destroy do
    # Remove related results from solve_status and contest_result
    problem.solve_statuses.each do |status|
      status.tasks.delete(id.to_s)
      status.save
    end

    problem.contests.each do |contest|
      contest.contest_results.each do |result|
        result.scores[problem.id.to_s].delete(id.to_s)
        result.save
      end
    end
  end

  def raw_input(user)
    return nil unless user && !user.new_record?

    seed = Seed.find_by(:task_id => id, :user_id => user.id)
    unless seed
      seed = seeds.create(:user_id => user.id, :seed => Random.new_seed)
    end

    Timeout::timeout(1) do
      namespace = Class.new
      namespace.class_eval(input_generator)
      namespace.new.generate_input(seed.seed.to_i)
    end
  end

  def solved_by?(user)
    solve_status = user.solve_statuses.where(:problem_id => problem).first
    solve_status && solve_status.tasks[id.to_s]
  end

  def solved_between_by?(time1, time2, user)
    Submission.where(:id => solved_by?(user)).where(:created_at => (time1..time2)).any?
  end

  def attempted_by?(user)
    user && user.submissions.for(self).any?
  end

  def grade(answer, user)
    namespace = Class.new
    namespace.class_eval(grader)
    namespace.new.grade_answer(raw_input(user), answer.to_s)
  end

  def regrade
    submissions.each do |submission|
      submission.grade
      submission.save
    end
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

  private

  def working_input_generator_and_grader
    begin
      namespace = Class.new
      namespace.class_eval(input_generator)
      input = namespace.new.generate_input(0)
    rescue Exception => e
      return errors.add(:input_generator, "is not working: #{e.message}")
    end

    return errors.add(:input_generator, "is not returning Array - got #{input.class}.") unless input.is_a? Array

    return errors.add(:input_generator, "is not returning Array of Hashes") unless input.all? { |h| h.is_a? Hash }

    begin
      namespace = Class.new
      namespace.class_eval(grader)
      namespace.new.grade_answer(input, "")
    rescue Exception => e
      errors.add(:grader, "is not working: #{e.message}")
    end
  end
end
