class User < ApplicationRecord
  has_many :interviews
  has_many :interview_slots
end
