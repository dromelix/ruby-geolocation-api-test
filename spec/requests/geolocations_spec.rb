require "spec_helper"

RSpec.describe "Geolocations API" do
  let(:auth_header) { { "HTTP_AUTHORIZATION" => "Bearer test-token" } }

  def parsed_response
    JSON.parse(last_response.body)
  end

  def stub_ipstack_success(ip: "134.201.250.155")
    stub_request(:get, "http://api.ipstack.com/#{ip}")
      .with(query: hash_including("access_key" => "test-ipstack-key"))
      .to_return(
        status: 200,
        body: {
          ip: ip,
          country_code: "US",
          country_name: "United States",
          region_name: "California",
          city: "Los Angeles",
          zip: "90013",
          latitude: 34.0453,
          longitude: -118.2413
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  it "rejects unauthorized requests" do
    get "/api/v1/geolocations", { ip_address: "8.8.8.8" }
    expect(last_response.status).to eq(401)
    expect(parsed_response["errors"].first["code"]).to eq("unauthorized")
  end

  it "creates and retrieves geolocation by ip address" do
    stub_ipstack_success(ip: "8.8.8.8")

    post "/api/v1/geolocations",
         { data: { attributes: { ip_address: "8.8.8.8" } } }.to_json,
         auth_header.merge("CONTENT_TYPE" => "application/json")
    expect(last_response.status).to eq(201)
    id = parsed_response.dig("data", "id")
    expect(id).not_to be_nil

    get "/api/v1/geolocations", { ip_address: "8.8.8.8" }, auth_header
    expect(last_response.status).to eq(200)
    expect(parsed_response.dig("data", "attributes", "lookup_value")).to eq("8.8.8.8")
    expect(parsed_response.dig("data", "attributes", "geolocation", "country_name")).to eq("United States")
  end

  it "creates, deletes and returns not found afterwards" do
    stub_ipstack_success(ip: "8.8.4.4")
    post "/api/v1/geolocations",
         { data: { attributes: { ip_address: "8.8.4.4" } } }.to_json,
         auth_header.merge("CONTENT_TYPE" => "application/json")
    expect(last_response.status).to eq(201)

    delete "/api/v1/geolocations", { ip_address: "8.8.4.4" }, auth_header
    expect(last_response.status).to eq(204)

    get "/api/v1/geolocations", { ip_address: "8.8.4.4" }, auth_header
    expect(last_response.status).to eq(404)
    expect(parsed_response.dig("errors", 0, "code")).to eq("not_found")
  end

  it "returns 422 for invalid lookup payload" do
    post "/api/v1/geolocations",
         { data: { attributes: { ip_address: "999.1.1.1" } } }.to_json,
         auth_header.merge("CONTENT_TYPE" => "application/json")

    expect(last_response.status).to eq(422)
    expect(parsed_response.dig("errors", 0, "code")).to eq("invalid_ip_address")
  end

  it "returns 422 when both url and ip are provided" do
    post "/api/v1/geolocations",
         { data: { attributes: { ip_address: "8.8.8.8", url: "example.com" } } }.to_json,
         auth_header.merge("CONTENT_TYPE" => "application/json")

    expect(last_response.status).to eq(422)
    expect(parsed_response.dig("errors", 0, "code")).to eq("invalid_lookup")
  end

  it "returns provider error when upstream rejects lookup" do
    stub_request(:get, "http://api.ipstack.com/8.8.8.8")
      .with(query: hash_including("access_key" => "test-ipstack-key"))
      .to_return(
        status: 200,
        body: {
          success: false,
          error: {
            code: 301,
            type: "missing_access_key",
            info: "You have not supplied an API Access Key."
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    post "/api/v1/geolocations",
         { data: { attributes: { ip_address: "8.8.8.8" } } }.to_json,
         auth_header.merge("CONTENT_TYPE" => "application/json")

    expect(last_response.status).to eq(422)
    expect(parsed_response.dig("errors", 0, "code")).to eq("provider_rejected_lookup")
  end
end
