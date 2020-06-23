# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations API", type: :request do
  let(:registration) { create(:registration, renew_token: "renew_token") }

  before do
    allow(WasteCarriersEngine::FeatureToggle).to receive(:active?).with(:api).and_return(true)
  end

  describe "GET /bo/api/registrations/:reg_identifier" do
    it "returns a json containing registration info" do
      get "/bo/api/registrations/#{registration.reg_identifier}"

      expected_json = { "_id" => registration.id.to_s, renew_token: "renew_token" }.to_json

      expect(response.body).to eq(expected_json)
    end
  end

  describe "POST /bo/api/registrations" do
    let(:data) { File.read("#{Rails.root}/spec/support/fixtures/registration_seed.json") }

    it "generates a new registration, set an expire date and returns a json containing its info" do
      allow(Rails.configuration).to receive(:expires_after).and_return(1)
      expected_registrations_count = WasteCarriersEngine::Registration.count + 1

      post "/bo/api/registrations", data, format: :json

      response_info = JSON.parse(response.body)
      expect(response_info).to have_key("reg_identifier")
      expect(response_info["reg_identifier"]).to start_with("CBDU")

      registration = WasteCarriersEngine::Registration.find_by reg_identifier: response_info["reg_identifier"]

      expect(registration.expires_on.to_date).to eq(1.year.from_now.to_date)
      expect(WasteCarriersEngine::Registration.count).to eq(expected_registrations_count)
    end

    context "when the tier is LOWER" do
      let(:data) { File.read("#{Rails.root}/spec/support/fixtures/lower_tier_registration_seed.json") }

      it "generates a new registration with a CBDL number" do
        allow(Rails.configuration).to receive(:expires_after).and_return(1)

        post "/bo/api/registrations", data, format: :json

        response_info = JSON.parse(response.body)
        expect(response_info["reg_identifier"]).to start_with("CBDL")
      end
    end

    context "when the custom expire is set" do
      let(:data) { File.read("#{Rails.root}/spec/support/fixtures/expire_set_registration_seed.json") }

      it "generates a new registration without overriding the expires_on date value" do
        expected_registrations_count = WasteCarriersEngine::Registration.count + 1

        post "/bo/api/registrations", data, format: :json

        response_info = JSON.parse(response.body)
        registration = WasteCarriersEngine::Registration.find_by reg_identifier: response_info["reg_identifier"]

        expect(registration.expires_on.to_s).to eq("2021-05-14T10:38:22+00:00")
        expect(WasteCarriersEngine::Registration.count).to eq(expected_registrations_count)
      end
    end
  end
end
