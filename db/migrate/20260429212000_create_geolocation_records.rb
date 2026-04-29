class CreateGeolocationRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :geolocation_records do |t|
      t.string :lookup_type, null: false
      t.string :lookup_value, null: false
      t.string :resolved_ip, null: false
      t.string :provider_name, null: false
      t.json :payload, null: false, default: {}
      t.timestamps
    end

    add_index :geolocation_records, :lookup_value, unique: true
  end
end
