class ForecastsController < ApplicationController
  def index
    coordinates = fetch_coordinates
    if coordinates.nil?
      render json: { error: 'Unable to fetch coordinates. Please provide valid address information.' }, status: :unprocessable_entity
      return
    end 
    
    if cached?(coordinates)
      render_cached_forcast(coordinates)
      return
    end
    
    forecast = fetch_forecast(coordinates)
    render json: forecast
  rescue StandardError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def fetch_coordinates
    GeocodingService.new(
      address: params[:address],
      street: params[:street],
      city: params[:city],
      state: params[:state],
      zip: params[:zip],
      latitude: params[:lat],
      longitude: params[:lon]
    ).coordinates
  end

  def fetch_forecast(coordinates)
    WeatherForecastService.new(coordinates: coordinates).fetch_forecast
  end

  def cached?(coordinates)
    Rails.cache.exist?(coordinates)
  end

  def render_cached_forcast(coordinates)
    cached_forecast = Rails.cache.read(coordinates)
    render json: cached_forecast
  end
end