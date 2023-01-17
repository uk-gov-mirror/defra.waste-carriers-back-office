# frozen_string_literal: true

require "csv"

module Reports
  class BaseCsvFileSerializer < BaseSerializer

    def initialize(path)
      @path = path

      super()
    end

    def to_csv(csv: nil, force_quotes: true)
      unless csv
        csv = CSV.open(@path, "w", force_quotes: force_quotes)
        csv << self.class::ATTRIBUTES.values
      end

      each_data do |parsed_object|
        csv << parsed_object unless parsed_object.nil?
      end

      csv
    rescue StandardError => e
      Rails.logger.error "Error writing CSV file to #{@path}: #{e}"
      Airbrake.notify(e, csv_file_path: @path)
    end
  end
end
