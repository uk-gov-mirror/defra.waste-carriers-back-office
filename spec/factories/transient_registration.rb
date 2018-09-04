# frozen_string_literal: true

FactoryBot.define do
  factory :transient_registration, class: WasteCarriersEngine::TransientRegistration do
    # Create a new registration when initializing
    initialize_with { new(reg_identifier: create(:registration, :expires_soon).reg_identifier) }

    trait :pending_payment do
      workflow_state { "renewal_received_form" }
      finance_details { build(:finance_details, :positive_balance) }
    end

    trait :no_pending_payment do
      workflow_state { "renewal_received_form" }
      finance_details { build(:finance_details, :zero_balance) }
    end

    trait :requires_conviction_check do
      workflow_state { "renewal_received_form" }
      key_people { [build(:key_person, :requires_conviction_check)] }
      conviction_search_result { build(:conviction_search_result, :match_result_yes) }
      conviction_sign_offs { [build(:conviction_sign_off)] }
    end

    trait :does_not_require_conviction_check do
      workflow_state { "renewal_received_form" }
      key_people { [build(:key_person, :does_not_require_conviction_check)] }
      conviction_search_result { build(:conviction_search_result, :match_result_no) }
    end
  end
end
