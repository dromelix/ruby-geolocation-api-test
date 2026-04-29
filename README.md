# Geolocation API (Ruby)

RESTful API for storing, retrieving, and deleting geolocation data by `ip_address` or `url`.

## Stack

- Ruby + Sinatra
- ActiveRecord + SQLite
- Provider abstraction (`Geolocation::Providers::BaseProvider`) with `ipstack` implementation
- RSpec + Rack::Test + WebMock
- Docker / Docker Compose

## Security

All endpoints require bearer token authentication:

- Header: `Authorization: Bearer <API_AUTH_TOKEN>`
- Missing or invalid token returns `401`.

## Setup (local)

1. Install dependencies:
   - `bundle install`
2. Configure env:
   - `cp .env.example .env` and fill values
3. Prepare DB:
   - `bundle exec rake db:migrate`
4. Start API:
   - `bundle exec rackup -p 9292`

## Setup (Docker)

1. Configure env:
   - `cp .env.example .env`
2. Start:
   - `docker compose up --build`

API becomes available at `http://localhost:9292`.

## API Endpoints (JSON API style)

Base path: `/api/v1/geolocations`

### Create geolocation

`POST /api/v1/geolocations`

Body:

```json
{
  "data": {
    "attributes": {
      "ip_address": "8.8.8.8"
    }
  }
}
```

or

```json
{
  "data": {
    "attributes": {
      "url": "example.com"
    }
  }
}
```

Returns `201` with stored geolocation record.

### Get geolocation by lookup

`GET /api/v1/geolocations?ip_address=8.8.8.8`

or

`GET /api/v1/geolocations?url=example.com`

Returns `200`, or `404` if not found.

### Delete geolocation by lookup

`DELETE /api/v1/geolocations?ip_address=8.8.8.8`

or

`DELETE /api/v1/geolocations?url=example.com`

Returns `204`, or `404` if not found.

## Error handling

Error responses follow JSON API error shape:

```json
{
  "errors": [
    {
      "status": "422",
      "code": "invalid_ip_address",
      "detail": "Invalid IP address format"
    }
  ]
}
```

Covered edge cases:

- malformed JSON
- missing lookup parameters
- both `ip_address` and `url` provided
- invalid URL/IP formats
- unresolvable URL host
- external provider failures/timeouts/rejections
- missing auth and missing server configuration

## Run tests

`bundle exec rspec`