class SetDefaultPointForTasks < ActiveRecord::Migration
  class Task < ActiveRecord::Base
  end

  def up
    change_column_default(:tasks, :point, 0)
    Task.reset_column_information
    Task.update_all(:point => 0)
  end

  def down
    change_column_default(:tasks, :point, nil)
  end
end
