# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActionLinksHelper, type: :helper do
  describe "details_link_for" do
    context "when the resource is a renewing registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns the renewing registration path" do
        expect(helper.details_link_for(resource)).to eq(renewing_registration_path(resource.reg_identifier))
      end
    end

    context "when the resource is a registration" do
      let(:resource) { build(:registration, reg_identifier: "CBDU1") }

      it "returns the registration path" do
        expect(helper.details_link_for(resource)).to eq(registration_path(resource.reg_identifier))
      end
    end

    context "when the resource is not a registration or a renewing registration" do
      let(:resource) { double(:resource) }

      it "returns a default path" do
        expect(helper.details_link_for(resource)).to eq("#")
      end
    end
  end

  describe "resume_link_for" do
    context "when the resource is a transient_registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns the correct path" do
        expect(helper.resume_link_for(resource)).to eq(WasteCarriersEngine::Engine.routes.url_helpers.new_renewal_start_form_path(resource.reg_identifier))
      end
    end

    context "when the resource is not a transient_registration" do
      let(:resource) { build(:registration) }

      it "returns the correct path" do
        expect(helper.resume_link_for(resource)).to eq("#")
      end
    end
  end

  describe "payment_link_for" do
    context "when the resource is a transient_registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns the correct path" do
        expect(helper.payment_link_for(resource)).to eq(transient_registration_payments_path(resource.reg_identifier))
      end
    end

    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      it "returns the correct path" do
        path = "#{Rails.configuration.wcrs_backend_url}/registrations/#{resource.id}/paymentstatus"
        expect(helper.payment_link_for(resource)).to eq(path)
      end
    end

    context "when the resource is not a registration or a transient_registration" do
      let(:resource) { nil }

      it "returns the correct path" do
        expect(helper.payment_link_for(resource)).to eq("#")
      end
    end
  end

  describe "convictions_link_for" do
    context "when the resource is a transient_registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns the correct path" do
        expect(helper.convictions_link_for(resource)).to eq(transient_registration_convictions_path(resource.reg_identifier))
      end
    end

    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      it "returns the correct path" do
        path = "#{Rails.configuration.wcrs_backend_url}/registrations/#{resource.id}/approve"
        expect(helper.convictions_link_for(resource)).to eq(path)
      end
    end

    context "when the resource is not a registration or a transient_registration" do
      let(:resource) { nil }

      it "returns the correct path" do
        expect(helper.convictions_link_for(resource)).to eq("#")
      end
    end
  end

  describe "renew_link_for" do
    context "when the resource is a registration" do
      let(:resource) { create(:registration) }

      it "returns the correct path" do
        expect(helper.renew_link_for(resource)).to eq(WasteCarriersEngine::Engine.routes.url_helpers.new_renewal_start_form_path(resource.reg_identifier))
      end
    end

    context "when the resource is not a registration" do
      let(:resource) { create(:renewing_registration) }

      it "returns the correct path" do
        expect(helper.renew_link_for(resource)).to eq("#")
      end
    end
  end

  describe "#display_details_link_for?" do
    context "when the result is a Registration" do
      let(:result) { build(:registration) }

      it "returns true" do
        expect(helper.display_details_link_for?(result)).to eq(true)
      end
    end

    context "when the result is not a Registration or a RenewingRegistration" do
      let(:result) { double(:result) }

      it "returns false" do
        expect(helper.display_details_link_for?(result)).to eq(false)
      end
    end

    context "when the result is a RenewingRegistration" do
      let(:result) { build(:renewing_registration) }

      it "returns true" do
        expect(helper.display_details_link_for?(result)).to eq(true)
      end
    end
  end

  describe "#display_resume_link_for?" do
    context "when the result is not a RenewingRegistration" do
      let(:result) { build(:registration) }

      it "returns false" do
        expect(helper.display_resume_link_for?(result)).to eq(false)
      end
    end

    context "when the result is a RenewingRegistration" do
      let(:result) { build(:renewing_registration) }

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_resume_link_for?(result)).to eq(false)
        end
      end

      context "when the result has been submitted" do
        before { result.workflow_state = "renewal_received_form" }

        it "returns false" do
          expect(helper.display_resume_link_for?(result)).to eq(false)
        end
      end

      context "when the result is in WorldPay" do
        before { result.workflow_state = "worldpay_form" }

        it "returns false" do
          expect(helper.display_resume_link_for?(result)).to eq(false)
        end
      end

      context "when the result is in a resumable state" do
        before { result.workflow_state = "location_form" }

        context "when the user does not have permission" do
          before { allow(helper).to receive(:can?).and_return(false) }

          it "returns false" do
            expect(helper.display_resume_link_for?(result)).to eq(false)
          end
        end

        context "when the user has permission" do
          before { allow(helper).to receive(:can?).and_return(true) }

          it "returns true" do
            expect(helper.display_resume_link_for?(result)).to eq(true)
          end
        end
      end
    end
  end

  describe "#display_payment_link_for?" do
    context "when the result is a Registration" do
      let(:result) { build(:registration) }

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_payment_link_for?(result)).to eq(false)
        end
      end

      context "when the result has no pending payment" do
        let(:result) { build(:registration, :no_pending_payment) }

        it "returns false" do
          expect(helper.display_payment_link_for?(result)).to eq(false)
        end
      end

      context "when the result has a pending payment" do
        let(:result) { build(:registration, :pending_payment) }

        it "returns true" do
          expect(helper.display_payment_link_for?(result)).to eq(true)
        end
      end
    end

    context "when the result is a RenewingRegistration" do
      let(:result) { build(:renewing_registration) }

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_payment_link_for?(result)).to eq(false)
        end
      end

      context "when the result has no pending payment" do
        let(:result) { build(:renewing_registration, :no_pending_payment) }

        it "returns false" do
          expect(helper.display_payment_link_for?(result)).to eq(false)
        end
      end

      context "when the result has a pending payment" do
        let(:result) { build(:renewing_registration, :pending_payment) }

        it "returns true" do
          expect(helper.display_payment_link_for?(result)).to eq(true)
        end
      end
    end
  end

  describe "#display_revoke_link_for?" do
    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      before do
        expect(helper).to receive(:can?).with(:revoke, WasteCarriersEngine::Registration).and_return(can)
      end

      context "when the user has permission for revoking" do
        let(:can) { true }

        before do
          expect(resource).to receive(:active?).and_return(active)
        end

        context "when the resource is active" do
          let(:active) { true }

          it "returns true" do
            expect(helper.display_revoke_link_for?(resource)).to be_truthy
          end
        end

        context "when the resource is not active" do
          let(:active) { false }

          it "returns false" do
            expect(helper.display_revoke_link_for?(resource)).to be_falsey
          end
        end
      end

      context "when the user has no permission for revoking" do
        let(:can) { false }

        it "returns false" do
          expect(helper.display_revoke_link_for?(resource)).to be_falsey
        end
      end
    end

    context "when the resource is a transient registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns false" do
        expect(helper.display_revoke_link_for?(resource)).to be_falsey
      end
    end
  end

  describe "#display_edit_link_for?" do
    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      before do
        expect(helper).to receive(:can?).with(:update, WasteCarriersEngine::Registration).and_return(can)
      end

      context "when the user has permission for revoking" do
        let(:can) { true }

        it "returns true" do
          expect(helper.display_edit_link_for?(resource)).to be_truthy
        end
      end

      context "when the user has no permission for revoking" do
        let(:can) { false }

        it "returns false" do
          expect(helper.display_edit_link_for?(resource)).to be_falsey
        end
      end
    end

    context "when the resource is a transient registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns false" do
        expect(helper.display_edit_link_for?(resource)).to be_falsey
      end
    end
  end

  describe "#display_view_confirmation_letter_link_for?" do
    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      before do
        expect(helper).to receive(:can?).with(:view_certificate, WasteCarriersEngine::Registration).and_return(can)
      end

      context "when the user has permission for revoking" do
        let(:can) { true }

        before do
          expect(resource).to receive(:active?).and_return(active)
        end

        context "when the resource is active" do
          let(:active) { true }

          it "returns true" do
            expect(helper.display_view_confirmation_letter_link_for?(resource)).to be_truthy
          end
        end

        context "when the resource is not active" do
          let(:active) { false }

          it "returns false" do
            expect(helper.display_view_confirmation_letter_link_for?(resource)).to be_falsey
          end
        end
      end

      context "when the user has no permission for revoking" do
        let(:can) { false }

        it "returns false" do
          expect(helper.display_view_confirmation_letter_link_for?(resource)).to be_falsey
        end
      end
    end

    context "when the resource is a transient registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns false" do
        expect(helper.display_view_confirmation_letter_link_for?(resource)).to be_falsey
      end
    end
  end

  describe "#display_order_copy_cards_link_for?" do
    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      before do
        expect(helper).to receive(:can?).with(:order_copy_cards, WasteCarriersEngine::Registration).and_return(can)
      end

      context "when the user has permission for revoking" do
        let(:can) { true }

        before do
          expect(resource).to receive(:active?).and_return(active)
        end

        context "when the resource is active" do
          let(:active) { true }

          before do
            expect(resource).to receive(:upper_tier?).and_return(upper_tier)
          end

          context "when the resource is an upper tier" do
            let(:upper_tier) { true }

            it "returns true" do
              expect(helper.display_order_copy_cards_link_for?(resource)).to be_truthy
            end
          end

          context "when the resource is not an upper tier" do
            let(:upper_tier) { false }

            it "returns false" do
              expect(helper.display_order_copy_cards_link_for?(resource)).to be_falsey
            end
          end
        end

        context "when the resource is not active" do
          let(:active) { false }

          it "returns false" do
            expect(helper.display_order_copy_cards_link_for?(resource)).to be_falsey
          end
        end
      end

      context "when the user has no permission for revoking" do
        let(:can) { false }

        it "returns false" do
          expect(helper.display_order_copy_cards_link_for?(resource)).to be_falsey
        end
      end
    end

    context "when the resource is a transient registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns false" do
        expect(helper.display_order_copy_cards_link_for?(resource)).to be_falsey
      end
    end
  end

  describe "#display_cease_link_for?" do
    context "when the resource is a registration" do
      let(:resource) { build(:registration) }

      before do
        expect(helper).to receive(:can?).with(:cease, WasteCarriersEngine::Registration).and_return(can)
      end

      context "when the user has permission for revoking" do
        let(:can) { true }

        it "returns true" do
          expect(helper.display_cease_link_for?(resource)).to be_truthy
        end
      end

      context "when the user has no permission for revoking" do
        let(:can) { false }

        it "returns false" do
          expect(helper.display_cease_link_for?(resource)).to be_falsey
        end
      end
    end

    context "when the resource is a transient registration" do
      let(:resource) { build(:renewing_registration) }

      it "returns false" do
        expect(helper.display_cease_link_for?(resource)).to be_falsey
      end
    end
  end

  describe "#display_payment_details_link_for?" do
    context "when the result is a Registration" do
      let(:result) { build(:registration) }

      it "returns true" do
        expect(helper.display_payment_details_link_for?(result)).to eq(true)
      end

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_payment_details_link_for?(result)).to eq(false)
        end
      end
    end

    context "when the result is a RenewingRegistration" do
      let(:result) { build(:renewing_registration) }

      it "returns true" do
        expect(helper.display_payment_details_link_for?(result)).to eq(true)
      end

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_payment_details_link_for?(result)).to eq(false)
        end
      end
    end
  end

  describe "#display_convictions_link_for?" do
    context "when the result is a Registration" do
      let(:result) { build(:registration) }

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_convictions_link_for?(result)).to eq(false)
        end
      end

      context "when the user does not have permission" do
        before { allow(helper).to receive(:can?).and_return(false) }

        it "returns false" do
          expect(helper.display_convictions_link_for?(result)).to eq(false)
        end
      end

      context "when the user has permission" do
        before { allow(helper).to receive(:can?).and_return(true) }

        context "when the result has no pending convictions check" do
          let(:result) { build(:renewing_registration, :does_not_require_conviction_check) }

          it "returns false" do
            expect(helper.display_convictions_link_for?(result)).to eq(false)
          end
        end

        context "when the result has a pending convictions check" do
          let(:result) { build(:renewing_registration, :requires_conviction_check) }

          it "returns true" do
            expect(helper.display_convictions_link_for?(result)).to eq(true)
          end
        end
      end
    end

    context "when the result is a RenewingRegistration" do
      let(:result) { build(:renewing_registration) }

      context "when the result has been revoked" do
        before { result.metaData.status = "REVOKED" }

        it "returns false" do
          expect(helper.display_convictions_link_for?(result)).to eq(false)
        end
      end

      context "when the user does not have permission" do
        before { allow(helper).to receive(:can?).and_return(false) }

        it "returns false" do
          expect(helper.display_convictions_link_for?(result)).to eq(false)
        end
      end

      context "when the user has permission" do
        before { allow(helper).to receive(:can?).and_return(true) }

        context "when the result has no pending convictions check" do
          let(:result) { build(:renewing_registration, :does_not_require_conviction_check) }

          it "returns false" do
            expect(helper.display_convictions_link_for?(result)).to eq(false)
          end
        end

        context "when the result has a pending convictions check" do
          let(:result) { build(:renewing_registration, :requires_conviction_check) }

          it "returns true" do
            expect(helper.display_convictions_link_for?(result)).to eq(true)
          end
        end
      end
    end

    describe "#display_renew_link_for?" do
      context "when the result is not a Registration" do
        let(:result) { build(:renewing_registration) }

        it "returns false" do
          expect(helper.display_renew_link_for?(result)).to eq(false)
        end
      end

      context "when the result is a Registration" do
        let(:result) { build(:registration) }

        context "when the user does not have permission" do
          before { allow(helper).to receive(:can?).and_return(false) }

          it "returns false" do
            expect(helper.display_renew_link_for?(result)).to eq(false)
          end
        end

        context "when the user has permission" do
          before { allow(helper).to receive(:can?).and_return(true) }

          context "when the result cannot begin a renewal" do
            before { allow(result).to receive(:can_start_renewal?).and_return(false) }

            it "returns false" do
              expect(helper.display_renew_link_for?(result)).to eq(false)
            end
          end

          context "when the result can begin a renewal" do
            before { allow(result).to receive(:can_start_renewal?).and_return(true) }

            it "returns true" do
              expect(helper.display_renew_link_for?(result)).to eq(true)
            end
          end
        end
      end
    end

    describe "#display_transfer_link_for?" do
      context "when the result is not a Registration" do
        let(:result) { build(:renewing_registration) }

        it "returns false" do
          expect(helper.display_transfer_link_for?(result)).to eq(false)
        end
      end

      context "when the result is a Registration" do
        let(:result) { build(:registration) }

        context "when the result has been revoked or refused" do
          before { result.metaData.status = %w[REVOKED REFUSED].sample }

          it "returns false" do
            expect(helper.display_transfer_link_for?(result)).to eq(false)
          end
        end

        context "when the result is not revoked or refused" do
          before { result.metaData.status = %w[ACTIVE EXPIRED PENDING].sample }

          context "when the user does not have permission" do
            before { allow(helper).to receive(:can?).and_return(false) }

            it "returns false" do
              expect(helper.display_transfer_link_for?(result)).to eq(false)
            end
          end

          context "when the user has permission" do
            before { allow(helper).to receive(:can?).and_return(true) }

            it "returns true" do
              expect(helper.display_transfer_link_for?(result)).to eq(true)
            end
          end
        end
      end
    end
  end
end
