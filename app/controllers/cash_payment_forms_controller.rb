# frozen_string_literal: true

class CashPaymentFormsController < ResourceFormsController
  include CanRenewIfPossible

  def new
    super(CashPaymentForm,
          "cash_payment_form")
  end

  def create
    params[:cash_payment_form][:updated_by_user] = current_user.email

    return unless super(CashPaymentForm,
                        "cash_payment_form")
  end

  private

  def cash_payment_form_params
    params.fetch(:cash_payment_form, {}).permit(
      :amount,
      :comment,
      :registration_reference,
      :date_received_day,
      :date_received_month,
      :date_received_year,
      :updated_by_user
    )
  end

  def authorize_user
    authorize! :record_cash_payment, @resource
  end
end
