# Define methods that any api can use here
class ApiController < ActionController::Base
  rescue_from StandardError do |error|
    responder(error)
  end

  def responder(response, http_code = 200)
    if response.is_a?(Exception)
      respond_with_error(response)
    else
      respond_with_success(response, http_code)
    end
  end

  def respond_with_error(error)
    render status: error.try(:http_code) || 422, json: {
      success: false,
      exception: error.try(:message),
      info: error.try(:info)
    }
  end

  def respond_with_success(data, http_code)
    render status: http_code, json: {
      success: true,
      exception: '',
      info: '',
      data: data
    }
  end
end
