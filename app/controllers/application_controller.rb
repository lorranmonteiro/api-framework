class ApplicationController < ActionController::API

  def render_success(data = {}, status: :ok)
    render status: status, json: { success: true, data: data }
  end

  def render_error(message, status: :bad_request)
    render status: status, json: { success: false, error: message }
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error("Record not found: #{e.message}", status: :not_found)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render_error(e.record.errors.full_messages, status: :unprocessable_entity)
  end
end
