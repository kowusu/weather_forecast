class WeatherForecastService
  def initialize(coordinates: )
    @coordinates = coordinates
  end

  def fetch_forecast
    cached = cache_exist?(@coordinates)
    fetch_forecast_from_cache.merge(
      cached: cached
    )
  end

  private

  def cache_key
    "weather_forecast/#{@coordinates}"
  end

  def fetch_forecast_from_cache
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      fetch_forecast_from_api
    end
  end

  def fetch_forecast_from_api
    response = OpenWeather::CurrentWeather.by_coords(coords: @coordinates)

    if response.present?
      {
        temperature: response['main']['temp'],
        high: response['main']['temp_max'],
        low: response['main']['temp_min']
      }
    else
      raise "Error fetching weather data"
    end
  end

  def cache_exist?(coordinates)
    Rails.cache.exist?(cache_key)
  end
end