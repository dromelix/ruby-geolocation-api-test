class GeolocationRecord < ActiveRecord::Base
  self.table_name = "geolocation_records"

  validates :lookup_type, inclusion: { in: %w[ip_address url] }
  validates :lookup_value, presence: true, uniqueness: true
  validates :resolved_ip, presence: true
  validates :provider_name, presence: true
end
