require File.join(File.dirname(__FILE__), './core_ext/array.rb')

module JobDollars
  # This module contains the estimation code.
  module Estimator
    # Estimate value of a developer resume item.
    #
    # @param  y (Fixnum) number of years
    # @param  hash (HashWithIndifferentAccess) job data for the chosen skill,
    #         shaped like the top-level values in langval.yml
    # @return (Float) Value of resume item in dollars.
    def value_of_resume_item_in_dollars(y, hash)
      hash = hash.with_indifferent_access
      resu = hash[:resumes]
      sala = crunch_salaries(hash)

      chance = {
        entry: chance_of_getting_job(y, resu, :entry),
        mid: chance_of_getting_job(y, resu, :mid),
        senior: chance_of_getting_job(y, resu, :senior)
      }

      ((chance[:entry] * sala[:entry]) +
       (chance[:mid] * sala[:mid]) +
       (chance[:senior] * sala[:senior])) / 3.0
    end

    # Estimate the work the job market does for a candidate with a certain
    # number of years of experience in a given skill.
    #
    # @param  y (Fixnum) number of years
    # @param  hash (HashWithIndifferentAccess) job data for the chosen skill,
    #         shaped like the top-level values in langval.yml
    # @return (Float) Market work estimate in job-dollars.
    def market_work_in_job_dollars(y, hash)
      hash = hash.with_indifferent_access
      candidate_type = case
                       when y >= 5
                         :senior
                       when y >= 3 && y < 5
                         :mid
                       when y < 3
                         :entry
                       end

      value_of_resume_item_in_dollars(y, hash) * hash[:jobs][candidate_type]

    rescue TypeError # TODO: fix missing data -TB
      nil
    end

    # Estimate the work the job market does for a candidate with a certain
    # number of years of experience in a given skill, in Javagrads.
    #
    # @param  y (Fixnum) number of years
    # @param  hash (HashWithIndifferentAccess) job data for the chosen skill,
    #         shaped like the top-level values in langval.yml
    # @return (Float) Market work estimate in Javagrads.
    def market_work_in_javagrads(y, hash)
      market_work_in_job_dollars(y, hash) / JAVAGRAD_IN_JOB_DOLLARS
    rescue TypeError # TODO: fix missing data -TB
      nil
    end

    # Calculate the number of Javagrads of work the job market does for beginners
    # (zero years of experience) with this skill.
    #
    # @param  hash (HashWithIndifferentAccess) job data for the chosen skill,
    #         shaped like the top-level values in langval.yml
    # @return (Float) Beginner rating in Javagrads.
    def beginner_javagrad_rating(hash)
      market_work_in_javagrads(0.0, hash)
    rescue TypeError # TODO: fix missing data -TB
      nil
    end

    # Get the average salary for jobs returned from an Indeed.com search,
    # based on refinements sidebar text with facet totals.
    #
    # @param  salatext (String) refinements text
    # @param  total (Fixnum) total number of results
    # @return (Float) Average salary in dollars
    def average_salary_from_indeed_facets(salatext, total)
      salaries = salatext.lstrip.strip.split(/[\s\u00a0]+/).in_groups_of(2).map do |r|
        r.compact.map do |i|
          i.gsub(/\D/, '').to_f
        end
      end

      salaries = [[salaries[0][0], total.to_f]] + salaries

      salaries = salaries.map.with_index do |salary, idx|
        if idx == 0
          amt, count = *salary
          [amt, count - salaries[1][1]]
        elsif idx == salaries.size-1
          salary
        else
          amt, count = *salary
          [(amt+salaries[idx+1][0])/2, count-salaries[idx+1][1]]
        end
      end

      salaries = salaries.map do |amt, count|
        amt * count
      end

      salaries.inject(&:+) / total
    end

    NORMAL_DISTRIBUTION = {
      1 => [1.0],
      2 => [0.5,0.5],
      3 => [0.0918,0.82,0.0918],
      4 => [0.0228,0.48,0.48,0.0228],
      5 => [0.0082,0.21,0.58,0.21,0.0082],
      6 => [0.0038,0.09,0.41,0.41,0.09,0.0038],
      7 => [0.0021,0.04,0.24,0.43,0.24,0.04,0.0021],
      8 => [0.0013,0.02,0.14,0.34,0.34,0.14,0.02,0.0013],
      9 => [0.0009,0.01,0.09,0.24,0.34,0.24,0.09,0.01,0.0009],
      10 => [0.0007,0.01,0.04,0.16,0.29,0.29,0.16,0.04,0.01,0.0007],
      11 => [0.0005,0.01,0.03,0.1,0.22,0.28,0.22,0.1,0.03,0.01,0.0005]
    }

    # Given the total number of resumes, model the probability
    # distribution that various numbers of resumes will be selected.
    #
    # @param  total_resumes (Fixnum) Total number of resumes.
    # @return (Hash<Fixnum, Float>) Probabilities keyed to the number
    #         of resumes selected.
    def applicants_per_job_distribution(total_resumes)
      max = (Math.log(total_resumes) / 1.5).to_i + 1

      dist = (1..max).to_a.map do |num|
        [num, NORMAL_DISTRIBUTION[max][num-1]]
      end

      Hash[dist]
    end

    # Compute the chance a candidate will get a job, given the years
    # of experience, total number of resumes, and the candidate type
    #
    # @param  years (Float) candidate years of experience
    # @param  total_resumes (Fixnum) total resumes
    # @param  type (Symbol) in [:entry, :mid, :senior]
    # @return (Float) Chance the candidate will get a job
    def chance_of_getting_job(years, total_resumes, type = :senior)
      year_range = case
                   when type == :senior
                     [5.0, 10.0]
                   when type == :mid
                     [3.0, 5.0]
                   when type == :entry
                     [0.0, 3.0]
                   end

      strength = [((years.to_f - year_range[0]) / (year_range[1] - year_range[0])), 1.0].min

      return 0.0 if strength < 0

      dist = applicants_per_job_distribution(total_resumes)
      dist = dist.map do |resumes, c|
        other_resumes = resumes - 1

        # probability of getting the job
        c * (strength ** other_resumes)
      end

      dist.inject(&:+)
    end

    # Get the salary distribution for a skill.
    #
    # @param  hash (Hash) A hash of job data shaped like the top-level values
    #         in langval.yml
    # @return (Hash<Symbol, Float>) {entry: Float, mid: Float, senior: Float}
    def crunch_salaries(hash)
      {
        entry: average_salary_from_indeed_facets(hash["salaries"]["entry"], hash["jobs"]["entry"]),
        mid: average_salary_from_indeed_facets(hash["salaries"]["mid"], hash["jobs"]["mid"]),
        senior: average_salary_from_indeed_facets(hash["salaries"]["senior"], hash["jobs"]["senior"])
      }
    end

    # Convert job-dollars to Javagrads.
    #
    # @param  job_dollars (Float) Job-dollars.
    # @return (Float) Javagrads, precision-1.
    def to_javagrads(job_dollars)
      (job_dollars / JAVAGRAD).to_f(1)
    end

  end
end


