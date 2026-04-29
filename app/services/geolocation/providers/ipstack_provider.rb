module Geolocation
  module Providers
    class IpstackProvider < BaseProvider
      BASE_URL = "http://api.ipstack.com"

      def initialize(access_key: ENV["IPSTACK_API_KEY"])
        @access_key = access_key
      end

      def fetch(ip_address)
        raise ApiError.new(status: 500, code: "provider_unconfigured", detail: "IP provider is not configured") if @access_key.to_s.strip.empty?

        response = HTTParty.get("#{BASE_URL}/#{ip_address}", query: { access_key: @access_key }, timeout: 10)
        parse_response!(response)
      rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
        raise ApiError.new(status: 502, code: "provider_unavailable", detail: "Geolocation provider unavailable: #{e.message}")
      end

      private

      def parse_response!(response)
        body = response.parsed_response
        if !response.success?
          raise ApiError.new(status: 502, code: "provider_error", detail: "Geolocation provider returned HTTP #{response.code}")
        end

        if body["success"] == false
          provider_detail = body.dig("error", "info") || "Unknown provider error"
          raise ApiError.new(status: 422, code: "provider_rejected_lookup", detail: provider_detail)
        end

        {
          ip: body["ip"],
          country_code: body["country_code"],
          country_name: body["country_name"],
          region_name: body["region_name"],
          city: body["city"],
          zip: body["zip"],
          latitude: body["latitude"],
          longitude: body["longitude"]
        }
      end
    end
  end
end
