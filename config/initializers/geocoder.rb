Geocoder.configure(
  lookup: :geoapify,
  api_key: ENV['GEOAPIFY_API_KEY'],
  timeout: 3,
  units: :km
)