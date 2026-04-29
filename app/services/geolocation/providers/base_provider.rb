module Geolocation
  module Providers
    class BaseProvider
      def fetch(_ip_address)
        raise NotImplementedError, "Providers must implement #fetch"
      end
    end
  end
end
