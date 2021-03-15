class CreateInterviews < ActiveRecord::Migration[5.2]
  def change
    create_table :interviews do |t|
      t.integer :interviewee_id, null: false
      t.integer :interview_slot_id, null: false
      t.integer :grade

      t.timestamps
    end

    add_index :interviews, :interviewee_id
    add_index :interviews, [:interviewee_id, :grade]
  end
end
