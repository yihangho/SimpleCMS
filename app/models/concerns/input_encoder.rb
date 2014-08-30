module InputEncoder
  module Python
    # Should be working for numbers, strings and arrays of working things. (So recursive...)
    def self.encode(input)
      return "" if input.nil?
      output = ""

      input.each do |hash|
        hash.each do |key, value|
          output << "#{key.to_s} = #{value.inspect}\n"
        end
      end

      output
    end
  end
end
