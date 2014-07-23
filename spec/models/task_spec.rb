require 'rails_helper'

describe Task do
  before { @task = Task.new }

  subject { @task }

  it { should respond_to :input }
  it { should respond_to :output }

  it { should respond_to :problem }
  it { should respond_to :submissions }
  it { should respond_to :solvers }
end
