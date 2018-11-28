# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Convictions", type: :request do
  let(:transient_registration) { create(:transient_registration, :requires_conviction_check) }

  describe "/bo/transient-registrations/:reg_identifier/convictions" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      it "renders the index template" do
        get "/bo/transient-registrations/#{transient_registration.reg_identifier}/convictions"
        expect(response).to render_template(:index)
      end

      it "returns a 200 response" do
        get "/bo/transient-registrations/#{transient_registration.reg_identifier}/convictions"
        expect(response).to have_http_status(200)
      end

      it "includes the reg identifier" do
        get "/bo/transient-registrations/#{transient_registration.reg_identifier}/convictions"
        expect(response.body).to include(transient_registration.reg_identifier)
      end
    end
  end

  describe "/bo/transient-registrations/:reg_identifier/convictions/begin-checks" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      it "updates the status of the conviction_sign_off" do
        get "/bo/transient-registrations/#{transient_registration.reg_identifier}/convictions/begin-checks"
        expect(transient_registration.reload.conviction_sign_offs.first.workflow_state).to eq("checks_in_progress")
      end

      it "redirects to the convictions page" do
        get "/bo/transient-registrations/#{transient_registration.reg_identifier}/convictions/begin-checks"
        expect(response).to redirect_to(convictions_path)
      end
    end
  end
end
