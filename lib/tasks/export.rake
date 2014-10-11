task :export, [:id, :path] => :environment do |t, args|
  problem = Problem.find(args[:id])

  problem.codes.each do |code|
    next if code.code.strip.empty?

    filename = File.join(args[:path], code.user.username + "_code.py")
    File.open(filename, "w") do |f|
      f << code.code
    end
  end

  problem.submissions.each do |submission|
    next if submission.code.strip.empty?

    filename = File.join(args[:path], "#{submission.user.username}_#{submission.task.id}_#{submission.id}.py")
    File.open(filename, "w") do |f|
      f << submission.code
    end
  end
end
