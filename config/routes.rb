Rails.application.routes.draw do

  root to: "application#redirect_root_to_dashboard"

  devise_for :users, path: "/bo/users", path_names: { sign_in: "sign_in", sign_out: "sign_out" }

  get "/bo" => "dashboards#index"

  resources :transient_registrations,
            only: :show,
            param: :reg_identifier,
            path: "/bo/transient-registrations",
            path_names: { show: "/:reg_identifier" } do
              resources :convictions,
                        only: :index

              resources :conviction_approval_forms,
                        only: [:new, :create],
                        path: "convictions/approve",
                        path_names: { new: "" }

              resources :conviction_rejection_forms,
                        only: [:new, :create],
                        path: "convictions/reject",
                        path_names: { new: "" }

              resources :transfer_payment_forms,
                        only: [:new, :create],
                        path: "payments/transfer",
                        path_names: { new: "" }
            end

  mount WasteCarriersEngine::Engine => "/bo"
end
