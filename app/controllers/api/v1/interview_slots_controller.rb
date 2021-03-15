module Api
  module V1
    # This controller handles all CRUD operations related to interview slots.
    class InterviewSlotsController < ApiController
      before_action :validate_params!
      before_action :validate_student!

      # @param [Integer] studentId User_id of the student
      # @param [String] startDateTime preferred starting time for interview
      # @param [String] endDateTime ending time for interview
      def index
        response = InterviewSlotsService.new(params).fetch
        @slots = response[:slots]
        @message = response[:message]
      rescue StandardError => e
        responder(e)
      end

      # @param [Integer] studentId User_id of the student
      # @param [Integer] interviewSlotId InterviewSlot_id
      def create
        slot_id = params['interviewSlotId'].to_i
        slot = InterviewSlot.with_ids(slot_id).available.first
        validate_slot!(slot, slot_id)

        ActiveRecord::Base.transaction do
          slot.lock!
          validate_slot!(slot, slot_id)
          Interview.create!(
            interviewee_id: params['studentId'],
            interview_slot_id: slot_id
          )
          slot.update_attributes!(status: InterviewSlot.statuses[:scheduled])
        end
        responder(t(:interview_slots)[:success], 201)
      rescue StandardError => e
        responder(e)
      end

      private

      def validate_params!
        required_keys = INTERVIEW_SLOTS_CONFIG['validate_params'][action_name]
        absent_keys = []
        required_keys.each do |key|
          absent_keys << key if params[key].blank?
        end

        return if absent_keys.blank?

        raise Api::Errors::MissingParamsError.new(absent_keys)
      end

      def validate_student!
        return if User.exists?(id: params[:studentId])

        raise Api::Errors::UserNotFoundError.new
      end

      def validate_slot!(slot, slot_id)
        return if slot.present? && slot.available?

        raise Api::Errors::InterviewSlotUnavailableError.new(slot_id)
      end
    end
  end
end
