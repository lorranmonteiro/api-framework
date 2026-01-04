class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  rescue_from StandardError, with: :handle_internal_server_error if Rails.env.production?

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

  private

  def handle_not_found(exception)
    render_error(
      "Record not found",
      status: :not_found,
      error_type: ErrorTypes::NOT_FOUND,
      internal_error_code: ErrorCodes::NOT_FOUND
    )
  end

  def handle_validation_error(exception)
    validation_errors = exception.record.errors.map do |error|
      {
        message: error.full_message,
        errorType: ErrorTypes::VALIDATION,
        internalErrorCode: ErrorCodes::VALIDATION_FAILED
      }
    end

    render_error(
      validation_errors.first[:message],
      status: :unprocessable_content,
      error_type: ErrorTypes::VALIDATION,
      internal_error_code: ErrorCodes::VALIDATION_FAILED,
      additional_errors: validation_errors.drop(1).presence
    )
  end

  def handle_internal_server_error(exception)
    Rails.logger.error(exception.class.name)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.join("\n"))

    render_error(
      'An unexpected error occurred while processing the request.',
      status: :internal_server_error,
      internal_error_code: ErrorCodes::INTERNAL_SERVER_ERROR,
      error_type: ErrorTypes::INTERNAL
    )
  end
end
