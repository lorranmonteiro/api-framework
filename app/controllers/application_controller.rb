class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_server_error unless Rails.env.development?
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

  def render_success(data = {}, status: :ok)
    render status: status, json: data
  end

  def render_errors(errors:, status:)
    body = {
      errors: errors,
      metadata: {
        requestId: request.request_id || SecureRandom.uuid,
        occurredAt: Time.current.utc.iso8601,
        path: request.fullpath
      }
    }

    render status: status, json: body
  end

  private

  def handle_not_found(_exception)
    render_errors(
      status: :not_found,
      errors: [
        {
          errorType: ErrorTypes::NOT_FOUND,
          message: Constants::RECORD_NOT_FOUND_MESSAGE
        }
      ]
    )
  end

  def handle_validation_error(exception)
    errors = exception.record.errors.map do |error|
      {
        errorType: ErrorTypes::FIELD_VALIDATION,
        message: error.full_message
      }
    end

    render_errors(
      status: :unprocessable_content,
      errors: errors
    )
  end

  def handle_internal_server_error(exception)
    Rails.logger.error(exception.class.name)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.join("\n"))

    render_errors(
      status: :internal_server_error,
      errors: [
        {
          errorType: ErrorTypes::INTERNAL_SERVER_ERROR,
          message: Constants::INTERNAL_SERVER_ERROR_MESSAGE
        }
      ]
    )
  end
end
