# frozen_string_literal: true

# Service to find out available interview slots for a student
# on the basis of start and end datetime
class InterviewSlotsService
  attr_reader :uncancelled_interviews, :config, :start_datetime, :end_datetime,
              :response, :user_id

  # @param [Integer] studentId User_id of the student
  # @param [String] startDateTime preferred starting time for interview
  # @param [String] endDateTime ending time for interview
  def initialize(params)
    @user_id = params['studentId'].to_i
    @uncancelled_interviews = Interview.of_interviewee(@user_id)
                                       .not_cancelled
    @config = INTERVIEW_SLOTS_CONFIG['free_mock_interview']
    @start_datetime = Time.zone.parse(params['startDateTime'].to_s)
    @end_datetime = Time.zone.parse(params['endDateTime'].to_s)
    @response = { slots: [], message: '' }
  end

  # @return [Hash] {slots, message} returns available slots
  # In case slots are unavailable, returns failure message.
  def fetch
    return response if cannot_take_more_mocks?

    previous_interviewer_ids = find_previous_interviewer_ids
    find_and_filter_available_slots(previous_interviewer_ids)
    response
  end

  private

  # Constraints to verify before scheduling more interviews
  def cannot_take_more_mocks?
    already_took_all_mocks? || previous_interviews_below_average?
  end

  def already_took_all_mocks?
    return false if uncancelled_interviews.length < @config['limit']

    response[:message] = I18n.t :free_limit_exhausted, scope: [:interview_slots, :unavailable]
    true
  end

  def previous_interviews_below_average?
    no_of_past_interviews = config['no_of_latest_interviews_to_check']
    past_interviews = Interview.of_interviewee(user_id)
                               .completed
                               .limit(no_of_past_interviews)
                               .order('id desc')

    below_average_interview_count = past_interviews.select do |interview|
      interview.grade <= @config['below_average_grade_value']
    end.count

    return false if below_average_interview_count < no_of_past_interviews

    response[:message] = I18n.t :less_grade, scope: [:interview_slots, :unavailable]
    true
  end

  def find_previous_interviewer_ids
    uncancelled_interviews.map do |interview|
      interview.interview_slot.interviewer_id
    end.uniq
  end

  def find_and_filter_available_slots(previous_interviewer_ids)
    available_slots = find_available_slots(previous_interviewer_ids)
    if available_slots.blank?
      response[:message] = I18n.t :no_slot_found, scope: [:interview_slots, :unavailable]
      return response
    end

    already_scheduled_interviews = find_scheduled_interviews
    if already_scheduled_interviews.blank?
      response[:slots] = available_slots
      return response
    end

    filter_available_slots(available_slots, already_scheduled_interviews)
  end

  def find_available_slots(previous_interviewer_ids)
    InterviewSlot.available_excluding_interviewers(
      previous_interviewer_ids,
      start_datetime,
      end_datetime
    )
  end

  def find_scheduled_interviews
    interview_slot_ids = Interview.of_interviewee(user_id).scheduled.pluck(:interview_slot_id)
    return [] if interview_slot_ids.blank?

    InterviewSlot.with_ids(interview_slot_ids)
                 .between_start_and_end_datetime(start_datetime, end_datetime)
  end

  # Remove the slots during which student has already scheduled an interview
  def filter_available_slots(available_slots, already_scheduled_interviews)
    available_slots.each do |available_slot|
      flag = true
      already_scheduled_interviews.each do |scheduled_slot|
        next if interview_during_different_time?(available_slot, scheduled_slot)

        flag = false
        break
      end
      response[:slots] << available_slot if flag
    end
  end

  def interview_during_different_time?(available_slot, scheduled_slot)
    available_slot.start_datetime >= scheduled_slot.end_datetime ||
      available_slot.end_datetime <= scheduled_slot.start_datetime
  end
end
