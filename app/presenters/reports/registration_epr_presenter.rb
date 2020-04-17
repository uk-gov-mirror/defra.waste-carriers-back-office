# frozen_string_literal: true

module Reports
  class RegistrationEprPresenter < ::WasteCarriersEngine::BasePresenter
    delegate :uprn, :house_number, :address_line_1, :address_line_2, :address_line_3, :address_line_4,
             :town_city, :postcode, :country, :easting, :northing,
             to: :company_address, prefix: true

    def metadata_date_activated
      metaData&.date_activated&.to_formatted_s(:year_month_day_hyphens)
    end

    def registration_type
      return "carrier_broker_dealer" if lower_tier?

      super
    end

    def expires_on
      return if lower_tier?
      return unless super.present?

      return (super + Rails.configuration.grace_window.days).to_formatted_s(:year_month_day_hyphens) if expired?

      super.to_formatted_s(:year_month_day_hyphens)
    end

    def company_no
      return unless business_type == "limitedCompany"

      number = super

      return unless number

      number = number.strip

      return if number.chars.uniq == ["0"]

      number
    end
  end
end
