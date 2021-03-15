class RenameColumnsInInterviewSlots < ActiveRecord::Migration[5.2]
  def change
    remove_index :interview_slots, :start_time
    remove_index :interview_slots, :end_time

    rename_column :interview_slots, :start_time, :start_datetime
    rename_column :interview_slots, :end_time, :end_datetime

    add_index :interview_slots, :start_datetime
    add_index :interview_slots, :end_datetime
  end
end
