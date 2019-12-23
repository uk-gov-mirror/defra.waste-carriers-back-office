# frozen_string_literal: true

module Reports
  module Boxi
    class RegistrationPresenter < WasteCarriersEngine::BasePresenter
      delegate :status, :route, :revoked_reason, to: :metadata, prefix: true

      delegate :balance, to: :finance_details, prefix: true, allow_nil: true
      delegate :match_result, to: :conviction_search_result, prefix: true, allow_nil: true

      def finance_details_balance
        balance = finance_details&.balance&.to_f || 0.00
        cents = balance / 100

        format("%<cents>.2f", cents: cents)
      end

      def metadata_date_registered
        metadata&.date_registered&.to_datetime&.to_formatted_s(:calendar_date_and_local_time)
      end

      def metadata_date_activated
        metadata&.date_activated&.to_datetime&.to_formatted_s(:calendar_date_and_local_time)
      end

      def expires_on
        super&.to_datetime&.to_formatted_s(:calendar_date_and_local_time)
      end

      def metadata_date_last_modified
        metadata&.last_modified&.to_datetime&.to_formatted_s(:calendar_date_and_local_time)
      end

      def conviction_search_result_searched_at
        conviction_search_result&.searched_at&.to_datetime&.to_formatted_s(:calendar_date_and_local_time)
      end

      private

      def metadata
        @_metadata ||= metaData
      end
    end
  end
end
