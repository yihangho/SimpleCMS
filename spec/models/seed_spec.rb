require 'rails_helper'

describe Seed do
  before { @seed = create(:seed) }

  subject { @seed }

  it { should respond_to :seed }
  it { should respond_to :user }
  it { should respond_to :task }
end
