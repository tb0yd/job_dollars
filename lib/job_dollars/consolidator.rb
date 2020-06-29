require 'active_support/core_ext/hash'
require 'rubystats'
require 'csv'

module JobDollars
  module Consolidator
    def consolidate_scraper_data
      csv = CSV.parse(File.read("../data/masterlist.csv"), headers: true)

      csv_sr = csv.each_with_index.group_by { |row, ix| row["Senior Level-href"] == "" ? ix : row["Senior Level-href"] }.values
      csv_sr = csv_sr.map { |grp| grp.inject { |memo, item| memo[0]["salaries_senior"] += " " + item[0]["salaries_senior"]; memo }.first }

      csv_md = csv_sr.each_with_index.group_by { |row, ix| row["Mid Level-href"] == "" ? ix : row["Mid Level-href"] }.values
      csv_md = csv_md.map { |grp| grp.inject { |memo, item| memo[0]["salaries_mid"] += " " + item[0]["salaries_mid"]; memo }.first }

      csv_el = csv_md.each_with_index.group_by { |row, ix| row["Entry Level-href"] == "" ? ix : row["Entry Level-href"] }.values
      csv_el = csv_el.map { |grp| grp.inject { |memo, item| memo[0]["salaries_entry"] += " " + item[0]["salaries_entry"]; memo }.first }

      csv = File.open("../data/masterlist-consolidated.csv", "w+") do |f|
        f << csv_el[0].headers.join(",") + "\n"
        csv_el.each do |row|
          f << row.to_csv
        end
      end
    end
  end
end
