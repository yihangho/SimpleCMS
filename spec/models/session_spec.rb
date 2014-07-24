require 'rails_helper'

describe Session do
  before do
    @user = User.create(:name => "user", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")
    @session = @user.sessions.create(:remember_token => "12345", :user_agent => "12345")
  end

  subject { @session }

  it { should respond_to :remember_token }
  it { should respond_to :user_agent }
  it { should respond_to :user }
end
