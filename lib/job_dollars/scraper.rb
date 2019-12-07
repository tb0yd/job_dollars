require 'active_support/core_ext/hash'
require 'csv'
require 'yaml'

module JobDollars
  # This module contains the estimation code.
  module Scraper
    def parse_salary_col(salary_col)
      salary_col.gsub("$", "\n$")
    end

    def parse_job_col(job_col)
      job_col.match(/\d+/)[0].to_i
    end

    def parse_resume_col(resume_col)
      resume_col.gsub(",","").to_i
    end

    def scraper_output_to_yaml
      yaml = {}

      csv = CSV.parse(File.read("../data/masterlist.csv"), headers: true)
      csv.each do |row|
        if row["job search"] != ""
          uri = URI(row["job search"])
          topic = CGI.parse(uri.query)["q"][0].gsub(" ","-")
          topic = 'csharp-dotnet' if topic == 'c#-.net'
          yaml[topic] ||= {}

          if row["Entry Level"] != ""
            yaml[topic]['salaries'] ||= {}
            yaml[topic]['salaries']['entry'] = parse_salary_col(row["salaries_entry"])
          end

          if row["Mid Level"] != ""
            yaml[topic]['salaries'] ||= {}
            yaml[topic]['salaries']['mid'] = parse_salary_col(row["salaries_mid"])
          end

          if row["Senior Level"] != ""
            yaml[topic]['salaries'] ||= {}
            yaml[topic]['salaries']['senior'] = parse_salary_col(row["salaries_senior"])
          end

          if row["jobs_entry"] != ""
            yaml[topic]['jobs'] ||= {}
            yaml[topic]['jobs']['entry'] = parse_job_col(row["jobs_entry"])
          end

          if row["jobs_mid"] != ""
            yaml[topic]['jobs'] ||= {}
            yaml[topic]['jobs']['mid'] = parse_job_col(row["jobs_mid"])
          end

          if row["jobs_senior"] != ""
            yaml[topic]['jobs'] ||= {}
            yaml[topic]['jobs']['senior'] = parse_job_col(row["jobs_senior"])
          end

        elsif row["resume search"] != ""
          uri = URI(row["resume search"])
          topic = CGI.parse(uri.query)["q"][0].gsub(" ","-")
          topic = 'csharp-dotnet' if topic == 'c#-.net'
          yaml[topic] ||= {}

          if row["resumes"] != ""
            yaml[topic]['resumes'] = parse_resume_col(row["resumes"])
          end
        end
      end

      yaml.stringify_keys.to_yaml
    end

    def load_scraper_data
      yaml = scraper_output_to_yaml

      File.open("../data/job_dollars3.yml", "w+") do |file|
        file << yaml
      end
    end
  end
end
