module Api
  module Errors
    # Define Missing Params Error
    class UserNotFoundError < StandardError
      attr_reader :http_code, :info, :message

      def initialize
        super
        @http_code = 403
        @message = 'User not found'
        @info = @message
      end
    end
  end
end
