# frozen_string_literal: true

class RegistrationConvictionPresenter < BaseConvictionPresenter
  def display_actions?
    conviction_check_required?
  end

  def begin_checks_path
    Rails.application.routes.url_helpers.registration_convictions_begin_checks_path(reg_identifier)
  end
end
