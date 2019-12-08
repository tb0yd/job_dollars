require File.join(File.dirname(__FILE__), './job_dollars/core_ext/hash.rb')
require File.join(File.dirname(__FILE__), './job_dollars/core_ext/hash_with_indifferent_access.rb')
require File.join(File.dirname(__FILE__), './job_dollars/estimator.rb')
require File.join(File.dirname(__FILE__), './job_dollars/team_cost_estimator.rb')
# require File.join(File.dirname(__FILE__), './job_dollars/scraper.rb')

require 'yaml'
require 'csv'

# JobDollars is the main module to include to start using JobDollars. It automatically
# includes the built-in Estimator module, along with some constants.
#
# Example (IRB):
#
#   irb(main):001:0> require 'job_dollars'
#   => true
#   irb(main):002:0> include JobDollars
#   => Object
#   irb(main):006:0> beginner_javagrad_rating(JOB_DATA['java-android'])
#   => 17.541885876163494
module JobDollars
  DATA_YML_FILE = File.join(File.dirname(__FILE__), '../data/job_dollars3.yml')
  TEAM_DATA_CSV_FILE = File.join(File.dirname(__FILE__), '../data/typical-sizes.csv')

  extend Estimator

  def self.included(base)
    base.include Estimator
    base.include TeamCostEstimator
  end

  JOB_DATA = YAML.load(File.read(DATA_YML_FILE))
  TEAM_DATA = Hash[CSV.parse(File.read(TEAM_DATA_CSV_FILE), headers: true).map { |row| [row["Language"], row.to_h] }]
  # JAVAGRAD_IN_JOB_DOLLARS = market_work_in_job_dollars(0.0, JOB_DATA["java-swing"])

  def job_dollar_output
    str = 'stack,senior,mid,expert jr,junior' + "\n"

    sorted_job_data = JOB_DATA.each_pair.sort { |k, v| k[1]["resumes"].to_i <=> v[1]["resumes"].to_i }
    sorted_job_data.each do |k, v|
      next unless ["senior", "mid", "entry"].all? { |g| v["salaries"].has_key?(g) }
      str += "#{k},#{[0, 2.0, 4.0, 7.5].reverse.map { |n| (market_work_in_job_dollars(n, v).to_f / 1000).to_s }.join(",")}"
      str += "\n"
    end

    str
  end

  def team_cost_output
    str = 'stack,SDLC2Year,SDLC3Year,SDLC5Year,SDLCOngoingAnnual,AgileFirstYear,AgileOngoingAnnual' + "\n"

    JOB_DATA.each do |language, job_data|
      puts language
      puts TEAM_DATA.keys.inspect
      if ["AWS-developer","Azure-developer"].include?(language)
        team_data = TEAM_DATA["Cloud"]
      elsif ["Arduino-developer", "Raspberry-Pi-developer"].include?(language)
        team_data = TEAM_DATA["Arduino / Raspberry Pi"]
      elsif language == '"SQL-Server"-developer'
        team_data = TEAM_DATA["SQL Server"]
      elsif language == '"Visual-Basic"-developer'
        team_data = TEAM_DATA["Visual Basic"]
      elsif language == '"Windows-Phone"-developer'
        team_data = TEAM_DATA["Windows Phone"]
      elsif language == 'Golang-developer'
        team_data = TEAM_DATA["Go"]
      else
        team_data = TEAM_DATA[language.sub("-developer", "")]
      end

      next unless job_data && job_data["salaries"]
      next unless ["senior", "mid", "entry"].all? { |g| job_data["salaries"].has_key?(g) }

      str += [
        language,
        sdlc_project_cost(team_data, job_data, years: 2),
        sdlc_project_cost(team_data, job_data, years: 3),
        sdlc_project_cost(team_data, job_data, years: 5),
        sdlc_ongoing_yearly_cost(team_data, job_data),
        agile_year1_cost(team_data, job_data),
        agile_ongoing_yearly_cost(team_data, job_data),
      ].join(",")
      str += "\n"
    end

    str
  end

  def job_dollar_summary
    str = ('%-20.20s' % 'stack') + ('%15.15s' % 'senior') + ('%15.15s' % 'mid') + ('%15.15s' % 'expert jr') + ('%15.15s' % 'junior') + "\n"

    sorted_job_data = JOB_DATA.each_pair.sort { |k, v| k[1]["resumes"].to_i <=> v[1]["resumes"].to_i }
    sorted_job_data.each do |k, v|
      next unless ["senior", "mid", "entry"].all? { |g| v["salaries"].has_key?(g) }
      str += ('%-20.20s' % k) + [0, 2.0, 4.0, 7.5].reverse.map { |n| '%15.2fk' % (market_work_in_job_dollars(n, v).to_f / 1000) }.join("")
      str += "\n"
    end

    str
  end
end

