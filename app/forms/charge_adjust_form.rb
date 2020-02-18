# frozen_string_literal: true

class ChargeAdjustForm
  include ActiveModel::Model

  attr_accessor :charge_type

  validates :charge_type, presence: true

  def submit(params)
    self.charge_type = params[:charge_type]

    valid?
  end
end
