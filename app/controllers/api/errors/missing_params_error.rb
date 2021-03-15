module Api
  module Errors
    # Define Missing Params Error
    class MissingParamsError < StandardError
      attr_reader :http_code, :info, :message

      def initialize(missing_params_list)
        super
        @http_code = 422
        @message = "Required params #{missing_params_list.join(', ')} are missing"
        @info = @message
      end
    end
  end
end
