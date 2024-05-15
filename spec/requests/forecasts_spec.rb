require 'rails_helper'

RSpec.describe 'Forecasts API', type: :request do
  describe 'GET /forecast' do
    let(:coordinates) { [40.7484, 73.9857] }
    let(:forecast_data) do
      {
        temperature: 22.5,
        high: 25.0,
        low: 18.0,
        cached: false
      }
    end

    context 'when geocoding is successful' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:coordinates).and_return(coordinates)
        allow_any_instance_of(WeatherForecastService).to receive(:fetch_forecast).and_return(forecast_data)
        allow(Rails.cache).to receive(:exist?).with(coordinates).and_return(false)
      end

      context 'returns the forecast data' do
        before { get '/forecast', params: { address: '20 W 34th St., New York, NY, 10001' } }
        
        specify { expect(response).to have_http_status(:ok) }
        specify { expect(json_response['temperature']).to eq(22.5) }
        specify { expect(json_response['high']).to eq(25.0) }
        specify { expect(json_response['low']).to eq(18.0) }
        specify { expect(json_response['cached']).to be(false) }
      end
    end

    context 'when geocoding fails' do
      before do
        allow_any_instance_of(GeocodingService).to receive(:coordinates).and_raise(StandardError.new('Geocoding failed'))
      end

      context 'returns an error message' do
        before { get '/forecast', params: { address: 'Invalid Address' } }

        specify { expect(response).to have_http_status(:bad_request) }
        specify { expect(json_response['error']).to eq('Geocoding failed') }
      end
    end
  end
end