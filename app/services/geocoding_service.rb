class GeocodingService
  def initialize(address: nil, street: nil, city: nil, state: nil, zip: nil, latitude: nil, longitude: nil)
    @address = address
    @street = street
    @city = city
    @state = state
    @zip = zip
    @latitude = latitude
    @longitude = longitude
  end

  def coordinates
    if @address
      geocode(@address)
    elsif @street && @city && @state
      address = "#{@street}, #{@city}, #{@state}, #{@zip}"
      geocode(address)
    elsif @latitude && @longitude
      [@latitude.to_f, @longitude.to_f]
    elsif @zip
      geocode(@zip)
    else
      raise 'Invalid address format'
    end
  end

  private

  def geocode(query)
    result = Geocoder.search(query).first
    if result
      [result.latitude, result.longitude]
    else
      raise 'Geocoding failed'
    end
  end
end