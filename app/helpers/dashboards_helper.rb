# frozen_string_literal: true

module DashboardsHelper
  include WasteCarriersEngine::ApplicationHelper

  def inline_registered_address(result)
    address = displayable_address(result.registered_address)

    return if address.empty?

    address.join(", ")
  end

  def result_type(result)
    return :renewal if result.is_a?(WasteCarriersEngine::TransientRegistration)
    return :new_registration if result.pending?
  end

  def status_tags(result)
    StatusTagService.run(resource: result)
  end
end
