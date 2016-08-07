require File.join(File.dirname(__FILE__), './job_dollars/core_ext/hash.rb')
require File.join(File.dirname(__FILE__), './job_dollars/core_ext/hash_with_indifferent_access.rb')
require File.join(File.dirname(__FILE__), './job_dollars/estimator.rb')

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
  DATA_YML_FILE = File.join(File.dirname(__FILE__), './job_dollars.yml')

  extend Estimator

  def self.included(base)
    base.include Estimator
  end

  JOB_DATA = YAML.load(File.read(DATA_YML_FILE))
  JAVAGRAD_IN_JOB_DOLLARS = market_work_in_job_dollars(0.0, JOB_DATA["java-swing"])
end

