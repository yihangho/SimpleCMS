require 'rails_helper'

class String
  def last
    self[self.size()-1]
  end
end

describe InputParser do

  describe "the normalize_input(arg) method" do
    let(:overall_test_string){ "this is funny         \nlol  a  a         \t crap crap     i love dinosaurs \n\t\t\t\t\t\t\t\t\t\t\na s d    f     \nthis is\n" }
    let(:expected_test_string_output){ "this is funny\nlol a a crap crap i love dinosaurs\na s d f\nthis is\n" }

    it "should return a string" do
      expect(InputParser.normalize_input("haha").class).to eq String
    end

    it "should ignore all \\b characters" do
      expect(InputParser.normalize_input("\b")).to eq "\n"
    end

    it "should end with a new line character" do
      expect(InputParser.normalize_input("").last).to eq "\n"
    end

    it "should perform all functions with ease" do
      expect(InputParser.normalize_input(overall_test_string)).to eq expected_test_string_output
    end

    it "should strip leading spaces of every line" do
      expect(InputParser.normalize_input("   1\n 2\n")).to eq "1\n2\n"
    end
    
    it "should strip ending spaces of every line" do
      expect(InputParser.normalize_input("1   \n2   \n")).to eq "1\n2\n"
    end

    describe "during edges cases" do
      it "should return the number of non-emptynewlines + 1 given a string of new lines" do
        expect(InputParser.normalize_input("\n\n\n\n\n\n").last).to eq "\n" 
      end

      it "should return an new line character given a string full of white space characters" do
        expect(InputParser.normalize_input("\n\n\n\t\t\t\t\t\r\b\n\n\n").last).to eq "\n"
      end
    end
  end
end


