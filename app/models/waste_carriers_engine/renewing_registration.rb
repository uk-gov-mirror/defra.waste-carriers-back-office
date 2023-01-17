# frozen_string_literal: true

require WasteCarriersEngine::Engine.root.join(
  "app",
  "models",
  "waste_carriers_engine",
  "renewing_registration"
)

module WasteCarriersEngine
  class RenewingRegistration

    # for renewing registrations, use the original registration's expiry date plus three years
    def future_expiry_date
      expires_on + 3.years
    end

  end
end
