class CreateInterviewSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :interview_slots do |t|
      t.integer :interviewer_id, null: false
      t.integer :status, default: 0, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end

    add_index :interview_slots, :interviewer_id
    add_index :interview_slots, :status
    add_index :interview_slots, :start_time
    add_index :interview_slots, :end_time
  end
end
