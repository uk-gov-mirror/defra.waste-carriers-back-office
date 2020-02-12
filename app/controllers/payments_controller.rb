# frozen_string_literal: true

class PaymentsController < ApplicationController
  include CanFetchResource

  prepend_before_action :authorize_user
  prepend_before_action :authenticate_user!
  before_action :define_payment_types

  def new; end

  def create
    payment_type = params[:payment_form][:payment_type]

    if valid_payment_type?(payment_type)
      redirect_to payment_path(payment_type)
    else
      render :new
    end
  end

  private

  def define_payment_types
    @payment_types = payment_types
  end

  def payment_types
    %w[cash
       cheque
       postal_order
       bank_transfer
       worldpay_missed]
  end

  def valid_payment_type?(payment_type)
    payment_types.include?(payment_type)
  end

  def payment_path(payment_type)
    public_send(
      "new_resource_#{payment_type}_payment_form_path",
      @resource._id
    )
  end

  def authorize_user
    authorize! :view_payments, WasteCarriersEngine::Registration
  end
end
