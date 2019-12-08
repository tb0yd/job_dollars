require File.join(File.dirname(__FILE__), './core_ext/array.rb')

module JobDollars
  module TeamCostEstimator
    include Estimator

    CONTRACTOR_COEFFICIENT = 1.5

    PLANNING_PHASE = { length: 0.1, multiplier: 2 }
    DESIGN_PHASE = { length: 0.25, multiplier: 2 }
    DEVELOPMENT_PHASE = { length: 0.4, multiplier: 5 }
    TESTING_PHASE = { length: 0.2, multiplier: 3 }
    MAINTENANCE_PHASE = { length: 0.05, multiplier: 1 }

    PLANNING_COMPOSITIONS = {3 => 'ssm', 4 => 'ssmm'}
    DESIGN_COMPOSITIONS = {3 => 'ssm', 4 => 'ssmm'}
    DEVELOPMENT_COMPOSITIONS = {7 => 'ssmmmee', 8 => 'sssmmmee', 9 => 'sssmmmeee', 10 => 'sssmmmmeee'}
    TESTING_COMPOSITIONS = {4 => 'smme', 5 => 'smmee', 6 => 'smmmee'}
    MAINTENANCE_COMPOSITIONS = {1 => 's', 2 => 'sm'}

    AGILE_COMPOSITIONS = {1 => 's', 2 => 'sm', 3 => 'smm', 4 => 'smme',
                          5 => 'ssmme', 6 => 'ssmmee', 7 => 'ssmmmee', 8 => 'ssmmmmee' }

    def sdlc_ongoing_yearly_cost(team_data, job_data)
      planning_composition, design_composition, development_composition,
        testing_composition, maintenance_composition = *sdlc_phase_compositions(team_data, job_data)

      salaries = crunch_salaries(job_data)

      cost_for_phase(maintenance_composition, 1, salaries)
    end

    def sdlc_project_cost(team_data, job_data, years: 2)
      planning_composition, design_composition, development_composition,
        testing_composition, maintenance_composition = *sdlc_phase_compositions(team_data, job_data)

      salaries = crunch_salaries(job_data)

      cost_for_phase(planning_composition, years * PLANNING_PHASE[:length], salaries) +
        cost_for_phase(design_composition, years * DESIGN_PHASE[:length], salaries) +
        cost_for_phase(development_composition, years * DEVELOPMENT_PHASE[:length], salaries) +
        cost_for_phase(testing_composition, years * TESTING_PHASE[:length], salaries) +
        cost_for_phase(maintenance_composition, years * MAINTENANCE_PHASE[:length], salaries)
    end

    def agile_year1_cost(team_data, job_data)
      agile_year1_composition = AGILE_COMPOSITIONS[(team_data["Agile"].to_i * 0.5).round]

      salaries = crunch_salaries(job_data)

      cost_for_phase(agile_year1_composition, 1, salaries)
    end

    def agile_ongoing_yearly_cost(team_data, job_data)
      agile_ongoing_composition = AGILE_COMPOSITIONS[(team_data["Agile"].to_i)]

      salaries = crunch_salaries(job_data)

      cost_for_phase(agile_ongoing_composition, 1, salaries)
    end

    def cost_for_phase(composition, length, salaries)
      cost = 0.0
      composition.chars.each do |char|
        cost += case char
          when 'S'
            salaries[:senior] * length
          when 's'
            salaries[:senior] * length * CONTRACTOR_COEFFICIENT
          when 'M'
            salaries[:mid] * length
          when 'm'
            salaries[:mid] * length * CONTRACTOR_COEFFICIENT
          when 'E'
            salaries[:entry] * length
          when 'e'
            salaries[:entry] * length * CONTRACTOR_COEFFICIENT
          end
      end
      cost
    end

    def sdlc_phase_compositions(team_data, job_data)
      planning_composition = PLANNING_COMPOSITIONS[team_data["Planning"].to_i]
      design_composition = DESIGN_COMPOSITIONS[team_data["Design"].to_i]
      development_composition = DEVELOPMENT_COMPOSITIONS[team_data["Development"].to_i]
      testing_composition = TESTING_COMPOSITIONS[team_data["Testing"].to_i]
      maintenance_composition = MAINTENANCE_COMPOSITIONS[team_data["Maintenance"].to_i]

      if team_data["Maintenance"].to_i == 1
        planning_composition = planning_composition.sub("s", "S")
        design_composition = design_composition.sub("s", "S")
        development_composition = development_composition.sub("s", "S")
        testing_composition = testing_composition.sub("s", "S")
        maintenance_composition = maintenance_composition.sub("s", "S")
      else
        planning_composition = planning_composition.sub("sm", "SM")
        design_composition = design_composition.sub("sm", "SM")
        development_composition = development_composition.sub("sm", "SM")
        testing_composition = testing_composition.sub("sm", "SM")
        maintenance_composition = maintenance_composition.sub("sm", "SM")
      end

      [planning_composition, design_composition, development_composition, testing_composition, maintenance_composition]
    end
  end
end
