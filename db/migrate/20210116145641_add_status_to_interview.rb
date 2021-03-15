class AddStatusToInterview < ActiveRecord::Migration[5.2]
  def change
    add_column :interviews, :status, :integer, default: 0, null: false

    add_index :interviews, :status
  end
end
