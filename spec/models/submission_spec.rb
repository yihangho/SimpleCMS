require 'rails_helper'

describe Submission do
  before { @submission = Submission.new }

  subject { @submission }

  it { should respond_to :input }
  it { should respond_to :accepted? }
  it { should respond_to :code_link }
end
