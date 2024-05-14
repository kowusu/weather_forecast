require 'rails_helper'

RSpec.describe WeatherForecastService do
  let(:coordinates) { [37.4221, -122.0841] }
  let(:service) { described_class.new(coordinates: coordinates) }
  let(:cache_key) { "weather_forecast/#{coordinates}" }
  let(:forecast_response) do
    {
      temperature: 22.5,
      high: 25.0,
      low: 18.0
    }
  end
  let(:api_response) do
    {
      'main' => {
        'temp' => 22.5,
        'temp_max' => 25.0,
        'temp_min' => 18.0
      }
    }
  end

  describe '#fetch_forecast' do
    context 'when data is cached' do
      before do
        allow(Rails.cache).to receive(:exist?).with("weather_forecast/#{coordinates}").and_return(true)
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes).and_return(forecast_response)
      end

      it 'returns the cached forecast data with cache indicator' do
        forecast = service.fetch_forecast
        expect(forecast[:temperature]).to eq(22.5)
        expect(forecast[:high]).to eq(25.0)
        expect(forecast[:low]).to eq(18.0)
        expect(forecast[:cached]).to be(true)
      end
    end

    context 'when data is not cached' do
      before do
        allow(Rails.cache).to receive(:exist?).with("weather_forecast/#{coordinates}").and_return(false)
        allow(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 30.minutes).and_call_original
        allow(OpenWeather::CurrentWeather).to receive(:by_coords).with(coords: coordinates).and_return(api_response)
      end

      it 'fetches the forecast data from the API and caches it' do
        forecast = service.fetch_forecast
        expect(forecast[:temperature]).to eq(22.5)
        expect(forecast[:high]).to eq(25.0)
        expect(forecast[:low]).to eq(18.0)
        expect(forecast[:cached]).to be(false)
      end
    end

    context 'when the API returns an error' do
      before do
        allow(OpenWeather::CurrentWeather).to receive(:by_coords).with(coords: coordinates).and_return(nil)
      end

      it 'raises an error' do
        expect { service.fetch_forecast }.to raise_error("Error fetching weather data")
      end
    end
  end
end