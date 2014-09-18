json.(@problem, :id, :title, :statement, :stub, :contest_only)

if @problem.permalink
  json.permalink_attributes @problem.permalink, :url
end

json.tasks_attributes @problem.tasks, :id, :input_generator, :grader, :point, :tokens, :label, :order

if @problem.errors.any?
  json.errors @problem.errors.full_messages
end
