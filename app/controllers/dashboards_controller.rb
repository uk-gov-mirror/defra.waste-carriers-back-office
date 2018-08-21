# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    set_term_and_filters
    @transient_registrations = Kaminari.paginate_array(matching_renewals).page params[:page]
  end

  private

  def set_term_and_filters
    @term = params[:term]
    @in_progress = get_filter_value(params[:in_progress])
    @pending_payment = get_filter_value(params[:pending_payment])
    @pending_conviction_check = get_filter_value(params[:pending_conviction_check])
  end

  def get_filter_value(filter_param)
    filter_param.present? && filter_param == "true"
  end

  def matching_renewals
    service = TransientRegistrationFinderService.new(@term,
                                                     @in_progress,
                                                     @pending_payment,
                                                     @pending_conviction_check)

    service.transient_registrations
  end
end
