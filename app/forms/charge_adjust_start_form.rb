# frozen_string_literal: true

class ChargeAdjustStartForm < WasteCarriersEngine::BaseForm
  attr_accessor :charge_type

  validates :charge_type, presence: true

  def submit(params)
    # Assign the params for validation
    self.charge_type = params[:charge_type]

    valid?
  end
end
