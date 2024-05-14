require 'rails_helper'

RSpec.describe GeocodingService do
  let(:valid_address) { '20 W 34th St., New York, NY, 10001' }
  let(:valid_coordinates) { [40.7484, 73.9857] }
  let(:geocode_result) do
    double('Geocoder::Result', latitude: 40.7484, longitude: 73.9857)
  end

  describe '#coordinates' do
  before { allow(Geocoder).to receive(:search).with(valid_address).and_return([geocode_result]) }
    context 'when given a full address' do
      it 'returns the correct coordinates' do
        service = GeocodingService.new(address: valid_address)
        expect(service.coordinates).to eq(valid_coordinates)
      end
    end

    context 'when given separate address components' do
      it 'returns the correct coordinates' do
        service = GeocodingService.new(street: '20 W 34th St.', city: 'New York', state: 'NY', zip: '10001')
        expect(service.coordinates).to eq(valid_coordinates)
      end
    end

    context 'when given latitude and longitude' do
      it 'returns the provided coordinates' do
        service = GeocodingService.new(latitude: 40.7484, longitude: 73.9857)
        expect(service.coordinates).to eq(valid_coordinates)
      end
    end

    context 'when given a postal code' do
      before { allow(Geocoder).to receive(:search).with('10001').and_return([geocode_result]) }
      it 'returns the correct coordinates' do
        service = GeocodingService.new(zip: '10001')
        expect(service.coordinates).to eq(valid_coordinates)
      end
    end

    context 'when no valid input is provided' do
      it 'raises an error' do
        service = GeocodingService.new
        expect { service.coordinates }.to raise_error('Invalid address format')
      end
    end

    context 'when geocoding fails' do
      it 'raises an error' do
        allow(Geocoder).to receive(:search).and_return([])
        service = GeocodingService.new(address: 'Invalid Address')
        expect { service.coordinates }.to raise_error('Geocoding failed')
      end
    end
  end
end