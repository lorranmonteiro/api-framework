class ApplicationController < ActionController::API

  def render_success(data = {}, status: :ok)
    render status: status, json: data
  end

  def render_error(
    message,
    status: :bad_request,
    internal_error_code: nil,
    error_type: nil,
    additional_errors: nil
  )
    body = {
      message: message,
      internalErrorCode: internal_error_code,
      errorType: error_type,
      requestDetails: {
        occurredAt: Time.current.utc.iso8601,
        requestId: request.request_id || SecureRandom.uuid,
        path: request.fullpath
      }
    }

    if additional_errors.present?
      body[:additionalErrors] = additional_errors
    end

    render status: status, json: body
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error(
      "Record not found",
      status: :not_found,
      error_type: "NOT_FOUND"
    )
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    validation_errors = e.record.errors.map do |err|
      {
        message: err.full_message,
        errorType: "VALIDATION_ERROR"
      }
    end

    render_error(
      "Validation failed",
      status: :unprocessable_content,
      error_type: "VALIDATION_ERROR",
      additional_errors: validation_errors
    )
  end
end
