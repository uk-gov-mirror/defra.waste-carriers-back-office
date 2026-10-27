# frozen_string_literal: true

namespace :one_off do
  desc "Create indexes for renewal notifications and renewal token lookups"
  task create_renewal_indexes: :environment do
    indexes = WasteCarriersEngine::Registration.collection.indexes

    indexes.create_one(
      { "metaData.status": 1, tier: 1, expires_on: 1 },
      { background: true, name: "renewal_notification_query_idx" }
    )

    indexes.create_one(
      { renew_token: 1 },
      { background: true, name: "renew_token_idx" }
    )
  end
end
