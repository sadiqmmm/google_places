require 'spec_helper'

describe GooglePlaces::Client do
  let(:client) { GooglePlaces::Client.new(api_key) }
  let(:fake_spot) { Object.new }

  before do
    allow(fake_spot).to receive(:place_id) { 1 }
  end

  it 'should initialize with an api_key' do
    expect(client.api_key).to eq(api_key)
  end

  describe '::spots' do
    let(:lat) { '-33.8670522' }
    let(:lng) { '151.1957362' }
    it 'should request spots' do
      expect(GooglePlaces::Spot).to receive(:list).with(lat, lng, api_key, {})
      client.spots(lat, lng)
    end

    it 'does not call find on GooglePlces::Spot' do
      allow(GooglePlaces::Spot).to receive(:list) { [fake_spot] }
      expect(GooglePlaces::Spot).not_to receive(:find)
      client.spots(lat, lng)
    end

    context 'with detail set to true' do
      it 'calls find on GooglePlaces::Spot' do
        allow(GooglePlaces::Spot).to receive(:list) { [fake_spot] }
        expect(GooglePlaces::Spot).to receive(:find)
        client.spots(lat, lng, detail: true)
      end
    end
  end

  describe '::spot' do
    let(:place_id) { 'ChIJu46S-ZZhLxMROG5lkwZ3D7k' }
    it 'should request a single spot by place_id' do
      expect(GooglePlaces::Spot).to receive(:find).with(place_id, api_key, {})
      client.spot(place_id)
    end
  end

  describe '::spots_by_query' do
    let(:query) { 'Statue of liberty, New York' }
    it 'should request spots by query' do
      expect(GooglePlaces::Spot).to receive(:list_by_query).with(
        query,
        api_key,
        {}
      )
      client.spots_by_query(query)
    end

    it 'does not call find on GooglePlces::Spot' do
      allow(GooglePlaces::Spot).to receive(:list_by_query) { [fake_spot] }
      expect(GooglePlaces::Spot).not_to receive(:find)
      client.spots_by_query(query)
    end

    context 'with detail set to true' do
      it 'calls find on GooglePlaces::Spot' do
        allow(GooglePlaces::Spot).to receive(:list_by_query) { [fake_spot] }
        expect(GooglePlaces::Spot).to receive(:find)
        client.spots_by_query(query, detail: true)
      end
    end
  end

  describe '::spots_by_bounds' do
    let(:query) { 'pizza' }
    let(:bounds) do
      {
        start_point: { lat: '36.06686213257888', lng: '-86.94168090820312' },
        end_point: { lat: '36.268635800737876', lng: '-86.66152954101562' }
      }
    end

    it 'should request spots by bounds' do
      expect(GooglePlaces::Spot).to receive(:list_by_bounds).with(
        bounds, api_key,
        query: query
      )
      client.spots_by_bounds(bounds, query: query)
    end

    it 'does not call find on GooglePlces::Spot' do
      allow(GooglePlaces::Spot).to receive(:list_by_bounds) { [fake_spot] }
      expect(GooglePlaces::Spot).not_to receive(:find)
      client.spots_by_bounds(bounds, query: query)
    end

    context 'with detail set to true' do
      it 'calls find on GooglePlaces::Spot' do
        allow(GooglePlaces::Spot).to receive(:list_by_bounds) { [fake_spot] }
        expect(GooglePlaces::Spot).to receive(:find)
        client.spots_by_bounds(bounds, query: query, detail: true)
      end
    end
  end

  describe '::spots_by_radar' do
    let(:keywords) { 'landmarks' }
    let(:lat) { '51.511627' }
    let(:lng) { '-0.183778' }
    let(:radius) { 5000 }

    it 'should request spots by radar' do
      expect(GooglePlaces::Spot).to receive(:list_by_radar).with(
        lat,
        lng,
        api_key,
        radius: radius,
        keyword: keywords
      )
      client.spots_by_radar(lat, lng, radius: radius, keyword: keywords)
    end

    it 'does not call find on GooglePlces::Spot' do
      allow(GooglePlaces::Spot).to receive(:list_by_radar) { [fake_spot] }
      expect(GooglePlaces::Spot).not_to receive(:find)
      client.spots_by_radar(lat, lng, radius: radius, keyword: keywords)
    end

    context 'with detail set to true' do
      it 'calls find on GooglePlaces::Spot' do
        allow(GooglePlaces::Spot).to receive(:list_by_radar) { [fake_spot] }
        expect(GooglePlaces::Spot).to receive(:find)
        client.spots_by_radar(
          lat,
          lng,
          radius: radius,
          keyword: keywords,
          detail: true
        )
      end
    end
  end

  describe '::predictions_by_input' do
    let(:input) { 'Atlanta' }

    it 'should request predictions by input' do
      expect(GooglePlaces::Prediction).to receive(:list_by_input).with(
        input,
        api_key,
        {}
      )
      client.predictions_by_input(input)
    end
  end

  describe 'detailed spots', vcr: { cassette_name: 'list_spots_with_detail' } do
    let(:lat) { '28.3852377' }
    let(:lng) { '-81.566068' }
    it 'should return spots with detail information' do
      spots = client.spots(lat, lng, detail: true)
      expect(spots).to_not be_nil

      spots.each do |spot|
        expect(spot.address_components).not_to be_nil
        expect(spot.city).not_to be_nil
        expect(spot.country).not_to be_nil
        expect(spot.formatted_address).not_to be_nil
        expect(spot.region).not_to be_nil
        expect(spot.url).not_to be_nil
      end
    end
  end
end
