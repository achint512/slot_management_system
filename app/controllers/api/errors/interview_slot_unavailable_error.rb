module Api
  module Errors
    # Define Missing Params Error
    class InterviewSlotUnavailableError < StandardError
      attr_reader :http_code, :info, :message

      def initialize(interviewer_slot_id)
        super
        @http_code = 409
        @message = "Interview slot #{interviewer_slot_id} is unavailable. "\
                   'Kindly book another slot'
        @info = @message
      end
    end
  end
end
