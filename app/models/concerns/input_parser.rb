module InputParser
  extend ActiveSupport::Concern

  def self.normalize_input input , space_sensitive = false
    unless space_sensitive
      input ||= ""
      # remove all carriage returns and backspace and tab first
      arr_of_lines = input.gsub(/[\r\b\t]+/ , "").split("\n").map! { |line| line.gsub(/\s+/ , " ").strip }
      arr_of_lines.reject! { |line| line.empty? }
      arr_of_lines.join("\n") << "\n"
    end
  end
end
