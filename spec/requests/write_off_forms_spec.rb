# frozen_string_literal: true

require "rails_helper"

RSpec.describe "WriteOffForms", type: :request do
  describe "GET /bo/resource/:_id/write-off/new" do
    context "when an agency user is signed in" do
      let(:user) { create(:user, :agency) }
      let(:renewing_registration) { create(:renewing_registration, :overpaid) }

      before(:each) do
        sign_in(user)
      end

      context "when the renewing registration has an overpayment below the agency user cap" do
        before do
          renewing_registration.finance_details.balance = -(WasteCarriersBackOffice::Application.config.write_off_agency_user_cap.to_i - 1)
          renewing_registration.save
        end

        it "renders the new template and returns a 200 status" do
          get new_resource_write_off_form_path(renewing_registration._id)

          expect(response).to render_template(:new)
          expect(response).to have_http_status(200)
        end
      end

      context "when the renewing registration has an overpayment above the agency user cap" do
        before do
          renewing_registration.finance_details.balance = -(WasteCarriersBackOffice::Application.config.write_off_agency_user_cap.to_i + 1)
        end

        it "redirects to the permissions page" do
          get new_resource_write_off_form_path(renewing_registration._id)

          expect(response).to redirect_to("/bo/pages/permission")
        end
      end
    end

    context "when an finance admin user is signed in" do
      let(:user) { create(:user, :finance_admin) }
      let(:renewing_registration) { create(:renewing_registration, :overpaid) }

      before(:each) do
        sign_in(user)
      end

      it "renders the new template and returns a 200 status" do
        get new_resource_write_off_form_path(renewing_registration._id)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context "when a user is not signed in" do
      it "redirects to the sign-in page" do
        get new_resource_write_off_form_path("foo")

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /bo/resource/:_id/write-off" do
    context "when a finance admin user is signed in" do
      let(:user) { create(:user, :finance_admin) }
      let(:renewing_registration) { create(:renewing_registration, :overpaid) }

      before(:each) do
        sign_in(user)
      end

      context "when the request data are valid" do
        let(:params) do
          {
            write_off_form: {
              comment: "A comment"
            }
          }
        end

        it "generates a new payment, updates the registration balance, returns a 302 status and redirects to the finance details page" do
          expected_payments_count = renewing_registration.finance_details.payments.count + 1

          post resource_write_off_form_path(renewing_registration._id), params

          renewing_registration.reload

          expect(renewing_registration.finance_details.payments.count).to eq(expected_payments_count)
          expect(renewing_registration.finance_details.balance).to eq(0)
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(resource_finance_details_path(renewing_registration._id))
        end
      end

      context "when the request data are not valid" do
        it "returns a 200 status and renders the :new template" do
          post resource_write_off_form_path(renewing_registration._id), {}

          expect(response).to have_http_status(200)
          expect(response).to render_template(:new)
        end
      end
    end
  end
end
