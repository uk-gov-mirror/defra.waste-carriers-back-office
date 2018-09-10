# frozen_string_literal: true

FactoryBot.define do
  factory :registration, class: WasteCarriersEngine::Registration do
    account_email { "whatever@example.com" }
    business_type { "limitedCompany" }
    company_name { "WasteCo" }
    company_no { "09360070" } # We need to use a valid company number
    contact_email { "whatever@example.com" }
    first_name { "Jane" }
    last_name { "Doe" }
    registration_type { "carrier_broker_dealer" }
    phone_number { "03708 506506" }
    tier { "UPPER" }

    addresses { [build(:address, :registered), build(:address, :contact)] }
    key_people { [build(:key_person, :does_not_require_conviction_check)] }

    metaData { build(:metaData) }

    trait :expires_soon do
      metaData { build(:metaData, status: :ACTIVE) }
      expires_on { 2.months.from_now }
    end
  end
end
