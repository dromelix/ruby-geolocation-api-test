class GeolocationAPI < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  before do
    content_type :json
    authenticate!
  end

  error ApiError do
    e = env["sinatra.error"]
    halt e.status, json_api_error(status: e.status, code: e.code, detail: e.detail)
  end

  error ActiveRecord::RecordInvalid do
    e = env["sinatra.error"]
    detail = e.record.errors.full_messages.join(", ")
    halt 422, json_api_error(status: 422, code: "validation_error", detail: detail)
  end

  error ActiveRecord::RecordNotFound do
    halt 404, json_api_error(status: 404, code: "not_found", detail: "Record was not found")
  end

  error do
    e = env["sinatra.error"]
    halt 500, json_api_error(status: 500, code: "internal_error", detail: e.message)
  end

  post "/api/v1/geolocations" do
    payload = parsed_body.dig("data", "attributes") || {}
    record = Geolocation::FetchAndStore.new.call(
      ip_address: payload["ip_address"],
      url: payload["url"]
    )

    status 201
    json_api_data(record)
  end

  get "/api/v1/geolocations" do
    normalized = Geolocation::Normalizer.normalize(
      ip_address: params["ip_address"],
      url: params["url"]
    )
    record = GeolocationRecord.find_by!(lookup_value: normalized[:value])
    json_api_data(record)
  end

  delete "/api/v1/geolocations" do
    normalized = Geolocation::Normalizer.normalize(
      ip_address: params["ip_address"],
      url: params["url"]
    )
    record = GeolocationRecord.find_by!(lookup_value: normalized[:value])
    record.destroy!
    status 204
  end

  private

  def parsed_body
    body = request.body
    body.rewind if body.respond_to?(:rewind)
    raw = body.read
    return {} if raw.to_s.strip.empty?

    JSON.parse(raw)
  rescue JSON::ParserError => e
    raise ApiError.new(status: 400, code: "invalid_json", detail: "Request body is not valid JSON: #{e.message}")
  end

  def authenticate!
    expected_token = ENV.fetch("API_AUTH_TOKEN", nil)
    raise ApiError.new(status: 500, code: "missing_auth_configuration", detail: "API_AUTH_TOKEN is not configured") if expected_token.to_s.empty?

    auth_header = request.env["HTTP_AUTHORIZATION"].to_s
    provided_token = auth_header.start_with?("Bearer ") ? auth_header.split(" ", 2).last : nil
    return if provided_token == expected_token

    halt 401, json_api_error(status: 401, code: "unauthorized", detail: "Missing or invalid bearer token")
  end

  def json_api_data(record)
    {
      data: {
        type: "geolocations",
        id: record.id.to_s,
        attributes: {
          lookup_type: record.lookup_type,
          lookup_value: record.lookup_value,
          resolved_ip: record.resolved_ip,
          provider_name: record.provider_name,
          geolocation: record.payload,
          created_at: record.created_at&.iso8601,
          updated_at: record.updated_at&.iso8601
        }
      }
    }.to_json
  end

  def json_api_error(status:, code:, detail:)
    {
      errors: [
        {
          status: status.to_s,
          code: code,
          detail: detail
        }
      ]
    }.to_json
  end
end
