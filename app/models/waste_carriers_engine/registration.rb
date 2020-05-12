# frozen_string_literal: true

module WasteCarriersEngine
  class Registration
    def self.lower_tier_or_in_grace_window
      date = Time.now.in_time_zone("London").beginning_of_day - Rails.configuration.grace_window.days + 1.day

      any_of({ :expires_on.gte => date }, { tier: LOWER_TIER })
    end
  end
end
