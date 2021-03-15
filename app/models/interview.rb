class Interview < ApplicationRecord
  belongs_to :interview_slot
  belongs_to :interviewee, class_name: 'User'

  enum status: [:scheduled, :in_progress, :completed, :cancelled]

  scope :of_interviewee, ->(user_ids) { where(interviewee_id: user_ids) }
  scope :excluding_statuses, ->(statuses) { where.not(status: statuses) }
  scope :not_cancelled, -> { excluding_statuses(Interview.statuses[:cancelled]) }
  scope :with_statuses, ->(statuses) { where(status: statuses) }
  scope :completed, -> { with_statuses(Interview.statuses[:completed]) }
  scope :scheduled, -> { with_statuses(Interview.statuses[:scheduled]) }
  scope :for_interview_slots, lambda { |interview_slot_ids|
    where(interview_slot_id: interview_slot_ids)
  }
end
