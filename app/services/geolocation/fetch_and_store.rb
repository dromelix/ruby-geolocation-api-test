module Geolocation
  class FetchAndStore
    def initialize(provider: Geolocation::ProviderFactory.build)
      @provider = provider
    end

    def call(ip_address: nil, url: nil)
      normalized = Geolocation::Normalizer.normalize(ip_address: ip_address, url: url)
      geo = @provider.fetch(normalized[:ip])

      record = GeolocationRecord.find_or_initialize_by(lookup_value: normalized[:value])
      record.lookup_type = normalized[:type]
      record.resolved_ip = normalized[:ip]
      record.provider_name = provider_name
      record.payload = geo
      record.save!
      record
    end

    private

    def provider_name
      @provider.class.name.split("::").last
    end
  end
end
