class AddIndexesToSubmissions < ActiveRecord::Migration
  def change
    # LOL, not sure which index to use, why not just create all?
    # https://img0.etsystatic.com/000/0/6499878/il_fullxfull.268019698.jpg
    #
    # But seriously, when we have more data on the production site, we should
    # really decide which (possibly composite) index to use.

    add_index :submissions, :created_at
    add_index :submissions, :user_id
    add_index :submissions, :task_id
    add_index :submissions, :accepted
  end
end
