module Geolocation
  class Normalizer
    IPV4_REGEX = /\A(?:(?:25[0-5]|2[0-4]\d|[01]?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d?\d)\z/
    IPV6_REGEX = /\A(?:[0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}\z/

    def self.normalize(ip_address: nil, url: nil)
      if present?(ip_address) && present?(url)
        raise ApiError.new(status: 422, code: "invalid_lookup", detail: "Provide either ip_address or url, not both")
      end

      if present?(ip_address)
        normalized_ip = ip_address.strip
        validate_ip!(normalized_ip)
        return { type: "ip_address", value: normalized_ip, ip: normalized_ip }
      end

      if present?(url)
        normalized_url = url.strip
        uri = parse_uri(normalized_url)
        host = uri.host
        raise ApiError.new(status: 422, code: "invalid_url", detail: "URL host is missing") if host.to_s.empty?

        resolved_ip = Resolv.getaddress(host)
        return { type: "url", value: normalized_url, ip: resolved_ip }
      end

      raise ApiError.new(status: 422, code: "missing_lookup", detail: "Provide ip_address or url")
    rescue Resolv::ResolvError => e
      raise ApiError.new(status: 422, code: "url_unresolvable", detail: "Could not resolve URL host: #{e.message}")
    rescue URI::InvalidURIError => e
      raise ApiError.new(status: 422, code: "invalid_url", detail: "Invalid URL: #{e.message}")
    end

    def self.parse_uri(url)
      with_scheme = url[%r{\Ahttps?://}] ? url : "http://#{url}"
      URI.parse(with_scheme)
    end

    def self.validate_ip!(value)
      return if value.match?(IPV4_REGEX) || value.match?(IPV6_REGEX)

      raise ApiError.new(status: 422, code: "invalid_ip_address", detail: "Invalid IP address format")
    end

    def self.present?(value)
      !value.to_s.strip.empty?
    end
  end
end
