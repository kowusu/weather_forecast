require 'open_weather'
OpenWeather.config do |config|
  config.api_key = ENV['OPEN_WEATHER_API_KEY']
end