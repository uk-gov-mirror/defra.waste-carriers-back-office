# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Refunds", type: :request do
  describe "GET /bo/finance_details/:_id/refunds" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      let(:renewing_registration) { create(:renewing_registration) }

      before(:each) do
        sign_in(user)
      end

      it "renders the index template and returns a 200 status" do
        get finance_details_refunds_path(renewing_registration._id)

        expect(response).to render_template(:index)
        expect(response).to have_http_status(200)
      end
    end

    context "when a user is not signed in" do
      it "redirects to the sign-in page" do
        get finance_details_refunds_path("foo")

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /bo/finance_details/:_id/refunds/new" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      let(:renewing_registration) { create(:renewing_registration) }
      let(:payment) { renewing_registration.finance_details.payments.first }

      before(:each) do
        sign_in(user)
      end

      it "renders the index template and returns a 200 status" do
        get new_finance_details_refund_path(renewing_registration._id, order_key: payment.order_key)

        expect(response).to render_template(:new)
        expect(response).to have_http_status(200)
      end
    end

    context "when a user is not signed in" do
      it "redirects to the sign-in page" do
        get new_finance_details_refund_path("foo", order_key: "bar")

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /bo/finance_details/:_id/refunds/:order_key" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      let(:renewing_registration) { create(:renewing_registration) }
      let(:payment) { renewing_registration.finance_details.payments.first }

      before(:each) do
        sign_in(user)
      end

      it "creates a refund payment, redirects to the finance details page and returns a 302 status" do
        payment.payment_type = WasteCarriersEngine::Payment::CASH
        payment.save

        expected_payments_count = renewing_registration.finance_details.payments.count + 1

        post finance_details_refunds_path(renewing_registration._id), order_key: payment.order_key

        renewing_registration.reload
        expect(renewing_registration.finance_details.payments.count).to eq(expected_payments_count)

        expect(response).to redirect_to(finance_details_path(renewing_registration._id))
        expect(response).to have_http_status(302)
      end

      context "when the payment is a worldpay payment" do
        it "creates a refund payment, redirects to the finance details page, sends a confirmation to worldpay and returns a 302 status" do
          payment.payment_type = WasteCarriersEngine::Payment::WORLDPAY
          payment.save

          worldpay_valid_response = <<-XML
            <?xml version=\"1.0\" encoding=\"UTF-8\"?>
            <!DOCTYPE paymentService PUBLIC \"-//WorldPay//DTD WorldPay PaymentService v1//EN\" \"http://dtd.worldpay.com/paymentService_v1.dtd\">
            <paymentService version=\"1.4\" merchantCode=\"EASERRSIMMOTO\">
              <reply>
                <ok>
                  <refundReceived orderCode=\"\">
                    <amount value=\"100\" currencyCode=\"GBP\" exponent=\"2\" debitCreditIndicator=\"credit\"/>
                  </refundReceived>
                </ok>
              </reply>
            </paymentService>
          XML

          stub_request(:get, "https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp").to_return(body: worldpay_valid_response)

          expected_payments_count = renewing_registration.finance_details.payments.count + 1

          post finance_details_refunds_path(renewing_registration._id), order_key: payment.order_key

          renewing_registration.reload
          expect(renewing_registration.finance_details.payments.count).to eq(expected_payments_count)

          expect(response).to redirect_to(finance_details_path(renewing_registration._id))
          expect(response).to have_http_status(302)
        end

        context "when the request to worldpay returns unexpected results" do
          it "does not create a payment and redirects to the finance details page" do
            payment.payment_type = WasteCarriersEngine::Payment::WORLDPAY
            payment.save

            worldpay_response = ""

            stub_request(:get, "https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp").to_return(body: worldpay_response)

            expected_payments_count = renewing_registration.finance_details.payments.count

            post finance_details_refunds_path(renewing_registration._id), order_key: payment.order_key

            renewing_registration.reload
            expect(renewing_registration.finance_details.payments.count).to eq(expected_payments_count)

            expect(response).to redirect_to(finance_details_path(renewing_registration._id))
            expect(response).to have_http_status(302)
          end
        end
      end
    end

    context "when a user is not signed in" do
      it "redirects to the sign-in page" do
        post finance_details_refunds_path("foo"), order_key: "bar"

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
