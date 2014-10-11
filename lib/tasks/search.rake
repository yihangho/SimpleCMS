task :search, [:id, :regex] => :environment do |t, args|
  id = args[:id].to_i
  pattern = Regexp.new(args[:regex])
  puts args[:regex]
  puts "Matching against #{pattern.inspect}"

  match = Hash.new([])

  Problem.find(id).codes.each do |code|
    if pattern =~ code.code
      match[code.user.username] = (match[code.user.username] << code.code)
    end
  end

  Problem.find(id).submissions.each do |submission|
    if pattern =~ submission.code
      match[submission.user.username] = (match[submission.user.username] << submission.code)
    end
  end

  if match.length > 0
    puts "Users:"
    puts match.keys
  end

  match.each do |user, arr|
    puts "*" * 80
    puts "*" + user
    puts
    arr.each do |code|
      puts "-" * 80
      puts code
    end
  end
end
