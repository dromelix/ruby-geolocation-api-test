module Geolocation
  class ProviderFactory
    def self.build
      provider_name = ENV.fetch("GEOLOCATION_PROVIDER", "ipstack")
      case provider_name
      when "ipstack"
        Geolocation::Providers::IpstackProvider.new
      else
        raise ApiError.new(status: 500, code: "provider_not_supported", detail: "Provider '#{provider_name}' is not supported")
      end
    end
  end
end
