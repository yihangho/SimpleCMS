require 'rails_helper'

describe Announcement do
  before do
    @announcement = Announcement.new
  end

  subject { @announcement }

  it { should respond_to :title }
  it { should respond_to :message }

  it { should respond_to :sender }
  it { should respond_to :contest }
end
