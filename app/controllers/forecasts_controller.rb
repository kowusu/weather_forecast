class ForecastsController < ApplicationController
  def index
    coordinates = fetch_coordinates
    if coordinates.nil?
      logger.warn "Unable to fetch coordinates for params: #{params.inspect}"
      render json: { error: 'Unable to fetch coordinates. Please provide valid address information.' }, status: :unprocessable_entity
      return
    end 
    
    if cached?(coordinates)
      logger.info "Cache hit for coordinates: #{coordinates.inspect}"
      render_cached_forcast(coordinates)
      return
    end
    
    logger.info "Fetching forecast for coordinates: #{coordinates.inspect}"
    forecast = fetch_forecast(coordinates)
    render json: forecast
  rescue StandardError => e
    logger.error "Error occurred: #{e.message}. Backtrace: #{e.backtrace.take(5).join("\n")}"
    render json: { error: e.message }, status: :bad_request
  end

  private

  def fetch_coordinates
    logger.info "Fetching coordinates for params: #{params.inspect}"
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
    cache_exists = Rails.cache.exist?(coordinates)
    logger.info "Cache existence for coordinates #{coordinates.inspect}: #{cache_exists}"
    cache_exists
  end

  def render_cached_forcast(coordinates)
    cached_forecast = Rails.cache.read(coordinates)
    logger.info "Rendering cached forecast for coordinates: #{coordinates.inspect}"
    render json: cached_forecast
  end
end