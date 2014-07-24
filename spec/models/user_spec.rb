require 'rails_helper'

describe User do
  before do
    @user = User.new(:name => "Test", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")
  end

  subject { @user }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :email }
  it { should respond_to :password }
  it { should respond_to :password_confirmation }

  it { should respond_to :submissions }
  it { should respond_to :set_problems }
  it { should respond_to :created_contests }
  it { should respond_to :invited_contests }
  it { should respond_to :participated_contests }
  it { should respond_to :solved_problems }
  it { should respond_to :solved_tasks }
  it { should respond_to :sessions }

  context "validations" do
    describe "when email is obviously invalid" do
      before { @user.email = "bla bla" }
      it { should_not be_valid }
    end

    describe "when name is empty" do
      before { @user.name = "" }
      it { should_not be_valid }
    end

    describe "when email is taken" do
      before do
        @doppelganger = User.create(:name => "Faker", :email => @user.email.upcase, :password => "12345", :password_confirmation => "12345")
      end

      it { should_not be_valid }
    end
  end
end
