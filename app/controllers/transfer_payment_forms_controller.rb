# frozen_string_literal: true

class TransferPaymentFormsController < AdminFormsController
  def new
    super(TransferPaymentForm,
          "transfer_payment_form",
          params[:transient_registration_reg_identifier],
          :authorize_action)
  end

  def create
    params[:transfer_payment_form][:updated_by_user] = current_user.email

    return unless super(TransferPaymentForm,
                        "transfer_payment_form",
                        params[:transfer_payment_form][:reg_identifier],
                        :authorize_action)

    renew_if_possible
  end

  def authorize_action(transient_registration)
    authorize! :record_transfer_payment, transient_registration
  end
end
