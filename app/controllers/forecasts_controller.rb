class ForecastsController < ApplicationController
  def index
    coordinates = fetch_coordinates
    return if coordinates.nil?
    cached = cache_exist?(coordinates)
    forecast = fetch_forecast(coordinates)
    
    render json: forecast
  end

  private

  def fetch_coordinates
    geocoding_service = GeocodingService.new(
      address: params[:address],
      street: params[:street],
      city: params[:city],
      state: params[:state],
      zip: params[:zip],
      latitude: params[:lat],
      longitude: params[:lon]
    )

    geocoding_service.coordinates
  rescue StandardError => e
    render json: { error: e.message }, status: :bad_request
    nil
  end

  def fetch_forecast(coordinates)
    return if coordinates.nil?

    WeatherForecastService.new(coordinates: coordinates).fetch_forecast
  end

  def cache_exist?(coordinates)
    Rails.cache.exist?(coordinates)
  end
end