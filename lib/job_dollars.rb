require File.join(File.dirname(__FILE__), './job_dollars/core_ext/hash.rb')
require File.join(File.dirname(__FILE__), './job_dollars/core_ext/hash_with_indifferent_access.rb')
require File.join(File.dirname(__FILE__), './job_dollars/estimator.rb')
# require File.join(File.dirname(__FILE__), './job_dollars/scraper.rb')

require 'yaml'

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

  extend Estimator

  def self.included(base)
    base.include Estimator
  end

  JOB_DATA = YAML.load(File.read(DATA_YML_FILE))
  JAVAGRAD_IN_JOB_DOLLARS = market_work_in_job_dollars(0.0, JOB_DATA["java-swing"])

  def job_dollar_summary
    ('%-20.20s' % 'stack') + ('%15.15s' % 'senior') + ('%15.15s' % 'mid') + ('%15.15s' % 'expert jr') + ('%15.15s' % 'junior') + "\n" +
      JOB_DATA.each_pair.sort { |k, v| k[1]["resumes"].to_i <=> v[1]["resumes"].to_i }.map { |k, v| ('%-20.20s' % k) + [0, 2.0, 4.0, 7.5].reverse.map { |n| '%15.2fk' % (market_work_in_job_dollars(n, v).to_f / 1000) }.join("") }.join("\n")
  end
end

