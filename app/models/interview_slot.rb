# InterviewSlot model
class InterviewSlot < ApplicationRecord
  belongs_to :interviewer, class_name: 'User'

  enum status: [:available, :scheduled, :in_progress, :completed, :cancelled]

  scope :of_interviewers, ->(user_ids) { where(interviewer_id: user_ids) }
  scope :not_of_interviewers, lambda { |user_ids|
    where.not(interviewer_id: user_ids)
  }
  scope :with_statuses, ->(statuses) { where(status: statuses) }
  scope :available, -> { with_statuses(InterviewSlot.statuses[:available]) }
  scope :between_start_and_end_datetime, lambda { |start_datetime, end_datetime|
    where('((:start_datetime < start_datetime AND :end_datetime > start_datetime) OR '\
           '(:start_datetime < end_datetime AND :end_datetime > end_datetime) OR '\
           '(:start_datetime < start_datetime AND :end_datetime > end_datetime) OR '\
           '(:start_datetime >= start_datetime AND :end_datetime <= end_datetime))',
          start_datetime: start_datetime, end_datetime: end_datetime)
  }
  scope :with_ids, ->(ids) { where(id: ids) }

  def self.available_excluding_interviewers(interviewer_ids, start_datetime, end_datetime)
    InterviewSlot.not_of_interviewers(interviewer_ids).available
                 .between_start_and_end_datetime(start_datetime, end_datetime)
  end
end
