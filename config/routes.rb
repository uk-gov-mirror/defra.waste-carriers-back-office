# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  root to: "application#redirect_root_to_dashboard"

  scope "/bo" do
    namespace(
      :api,
      defaults: { format: :json },
      constraints: ->(_request) { WasteCarriersEngine::FeatureToggle.active?(:api) }
    ) do
      resources :registrations, only: %i[show create]
      resources :renewals, only: :show
    end

    get "/resend-renewal-email/:reg_identifier", to: "resend_renewal_email#new", as: "resend_renewal_email"

    # Letters
    get "/letters", to: "letters#index", as: :letters
    resources :ad_reminder_letters_exports, only: %i[index update], path: "/ad-reminder-letters-exports"
    resources :digital_reminder_letters_exports, only: %i[index update], path: "/digital-reminder-letters-exports"
  end

  devise_for :users,
             controllers: { invitations: "user_invitations", sessions: "sessions" },
             path: "/bo/users",
             path_names: { sign_in: "sign_in", sign_out: "sign_out" }

  get "/bo" => "dashboards#index"
  get "/bo/convictions" => "convictions_dashboards#index", as: :convictions
  get "/bo/convictions/possible-matches" => "convictions_dashboards#possible_matches", as: :convictions_possible_matches
  get "/bo/convictions/in-progress" => "convictions_dashboards#checks_in_progress", as: :convictions_checks_in_progress
  get "/bo/convictions/approved" => "convictions_dashboards#approved", as: :convictions_approved
  get "/bo/convictions/rejected" => "convictions_dashboards#rejected", as: :convictions_rejected

  # Privacy policy
  get "/bo/ad-privacy-policy", to: "ad_privacy_policy#show", as: :ad_privacy_policy

  resources :resources,
            only: [],
            path: "/bo/resources" do
              resources :refunds,
                        only: %i[index new create],
                        param: :order_key

              resources :cancels,
                        only: %i[new create],
                        path_names: { new: "" }

              resources :reversal_forms,
                        only: %i[index new create],
                        path: "reversals",
                        path_names: { new: ":order_key/new" },
                        param: :order_key

              resources :payment_forms,
                        only: %i[new create],
                        path: "payments",
                        path_names: { new: "" }

              resources :cash_payment_forms,
                        only: %i[new create],
                        path: "payments/cash",
                        path_names: { new: "" }

              resources :cheque_payment_forms,
                        only: %i[new create],
                        path: "payments/cheque",
                        path_names: { new: "" }

              resources :postal_order_payment_forms,
                        only: %i[new create],
                        path: "payments/postal-order",
                        path_names: { new: "" }

              resources :bank_transfer_payment_forms,
                        only: %i[new create],
                        path: "payments/bank-transfer",
                        path_names: { new: "" }

              resources :worldpay_missed_payment_forms,
                        only: %i[new create],
                        path: "payments/worldpay-missed",
                        path_names: { new: "" }

              resources :worldpay_escapes,
                        only: :new,
                        path: "revert-to-payment-summary",
                        path_names: { new: "" }

              resources :worldpay_missed_payment_new_registrations,
                        only: :new,
                        path: "missed-worldpay-payment-new-registration",
                        path_names: { new: "" }

              resource :finance_details,
                       only: :show,
                       path: "finance-details"

              resource :write_off_form,
                       only: %i[new create],
                       path: "write-off"

              resource :charge_adjust_form,
                       only: %i[new create],
                       path: "payments/charge-adjusts",
                       path_names: { new: "" }

              resource :negative_charge_adjust_form,
                       only: %i[new create],
                       path: "payments/charge-adjust/negative",
                       path_names: { new: "" }

              resource :positive_charge_adjust_form,
                       only: %i[new create],
                       path: "payments/charge-adjust/positive",
                       path_names: { new: "" }
            end

  resources :new_registrations,
            only: :show,
            param: :token,
            path: "/bo/new-registrations"

  resources :renewing_registrations,
            only: :show,
            param: :reg_identifier,
            path: "/bo/renewing-registrations"

  resources :registrations,
            only: :show,
            param: :reg_identifier,
            path: "/bo/registrations" do
              resources :convictions,
                        only: :index

              resources :registration_conviction_approval_forms,
                        only: %i[new create],
                        path: "convictions/approve",
                        path_names: { new: "" }

              resources :registration_conviction_rejection_forms,
                        only: %i[new create],
                        path: "convictions/reject",
                        path_names: { new: "" }

              resources :registration_transfers,
                        only: %i[new create],
                        param: :reg_identifier,
                        path: "transfer",
                        path_names: { new: "" }

              get "transfer/success",
                  to: "registration_transfers#success",
                  as: :registration_transfer_success

              get "certificate", to: "certificates#show", as: :certificate
            end

  resources :transient_registrations,
            only: [],
            param: :reg_identifier,
            path: "/bo/transient-registrations",
            path_names: { show: "/:reg_identifier" } do
              resources :convictions,
                        only: :index

              resources :conviction_approval_forms,
                        only: %i[new create],
                        path: "convictions/approve",
                        path_names: { new: "" }

              resources :conviction_rejection_forms,
                        only: %i[new create],
                        path: "convictions/reject",
                        path_names: { new: "" }
            end

  get "/bo/registrations/:registration_reg_identifier/convictions/begin-checks",
      to: "convictions#begin_checks",
      as: :registration_convictions_begin_checks

  get "/bo/transient-registrations/:transient_registration_reg_identifier/convictions/begin-checks",
      to: "convictions#begin_checks",
      as: :transient_registration_convictions_begin_checks

  get "/bo/users",
      to: "users#index",
      as: :users

  resources :users,
            only: [],
            path: "/bo/users" do
              resources :user_activations,
                        as: :activations,
                        only: %i[new create],
                        path: "activate",
                        path_names: { new: "" }

              resources :user_deactivations,
                        as: :deactivations,
                        only: %i[new create],
                        path: "deactivate",
                        path_names: { new: "" }

              resources :user_roles,
                        as: :roles,
                        only: %i[new create],
                        path: "role",
                        path_names: { new: "" }
            end

  resources :conviction_imports,
            only: %i[new create],
            path: "/bo/import-convictions",
            path_names: { new: "" }

  # Redirect old Devise routes
  # rubocop:disable Style/FormatStringToken
  get "/agency_users(*all)" => redirect("/bo/users%{all}")
  get "/admins(*all)" => redirect("/bo/users%{all}")
  # rubocop:enable Style/FormatStringToken

  mount DefraRubyMocks::Engine => "/bo/mocks"

  mount DefraRubyFeatures::Engine => "/bo/features", as: "features_engine"

  mount WasteCarriersEngine::Engine => "/bo", as: "basic_app_engine"
end
# rubocop:enable Metrics/BlockLength
