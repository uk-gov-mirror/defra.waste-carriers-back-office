# frozen_string_literal: true

require "csv"

module Reports
  class BaseSerializer
    def to_csv
      CSV.generate do |csv|
        csv << self.class::ATTRIBUTES

        registrations_data do |exemption_data|
          csv << exemption_data
        end
      end
    end

    private

    def registrations_data
      registrations_scope.each do |registration|
        yield parse_registration(registration)
      end
    end
  end
end
