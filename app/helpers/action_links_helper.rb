# frozen_string_literal: true

module ActionLinksHelper
  def display_details_link_for?(resource)
    resource.is_a?(WasteCarriersEngine::TransientRegistration)
  end

  def display_resume_link_for?(resource)
    return false unless display_transient_registration_links?(resource)
    return false if resource.renewal_application_submitted?
    return false if resource.workflow_state == "worldpay_form"

    true
  end

  def display_payment_link_for?(resource)
    return false unless display_transient_registration_links?(resource)

    resource.pending_payment?
  end

  def display_convictions_link_for?(resource)
    return false unless display_transient_registration_links?(resource)

    resource.pending_manual_conviction_check?
  end

  private

  def display_transient_registration_links?(resource)
    resource.is_a?(WasteCarriersEngine::TransientRegistration) && !resource.metaData.REVOKED?
  end
end
