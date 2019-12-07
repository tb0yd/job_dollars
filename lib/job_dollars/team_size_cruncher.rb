require 'descriptive_statistics'

def crunch_averages(res)
  team_map = {}
  res.each do |row|
    next unless row["tech_do"]
    row["tech_do"].split("; ").each do |tech|
      next unless row["team_size_range"]
      case row["team_size_range"]
      when "I am not on a team"
        avg_team_size = 1.0
      when "20+ people"
        avg_team_size = 20.0
      else
        avg_team_size = row["team_size_range"].split("-")
        avg_team_size = (avg_team_size[0].to_i + avg_team_size[1].to_i).to_f / 2.0
      end

      if avg_team_size.to_i > 0
        if team_map[tech]
          team_map[tech] = team_map[tech] + [avg_team_size]
        else
          team_map[tech] = [avg_team_size]
        end
      end
    end
  end

  team_map.each_key do |k|
    team_map[k] = {mean: team_map[k].mean, stddev: team_map[k].standard_deviation, counts: team_map[k].group_by(&:itself).map { |x,y| [x, y.count.to_f / team_map[k].size] }.to_h}
  end
end

def map_to_lifecycle(counts, cycle)
  # sort by densest phase first
  cycle = cycle.sort { |c1, c2| c1[:headcount] <=> c2[:headcount] }.reverse

  original_counts = counts.clone
  rolling_counts = counts.clone

  cycle.each do |phase|
    rolling_prob = phase[:prob].clone
    original_prob = phase[:prob].clone
    phase[:estimate] = 0.0

    [17.5, 12.0, 7.0, 2.5, 1.0].each do |size|
      next if rolling_counts[size] == 0.0
      next if rolling_prob == 0.0

      if rolling_counts[size] >= rolling_prob
        puts "assigning #{rolling_prob}, #{original_prob}, #{size})} to #{phase[:name]}"
        phase[:estimate] += (rolling_prob / original_prob * size)
        rolling_counts[size] -= rolling_prob
        rolling_prob = 0.0
      elsif rolling_counts[size] < rolling_prob
        puts "assigning #{rolling_counts[size]}, #{original_prob}, #{size})} to #{phase[:name]}"
        phase[:estimate] += (rolling_counts[size] / original_prob * size)
        rolling_prob -= rolling_counts[size]
        rolling_counts[size] = 0.0
      end
    end
  end

  cycle
end

# Team sizes will be 43% (n*2), 21% (n*3), or 36% (n*5) according to their general probabilities

require 'csv'
results = CSV.parse(File.read("./data/stack-overflow-survey-2016.csv"), headers: true);0
pavgs = crunch_averages(results);0

puts pavgs.sort { |p1, p2| p1[1][:counts][7.0]-p1[1][:counts][2.5] <=> p2[1][:counts][7.0]-p2[1][:counts][2.5] }.map { |a| "#{"%20.20s" % a[0]}: Mean Team Size #{"%2.2f" % a[1][:mean]}; Dist: #{a[1][:counts].sort.map { |g,n| "#{g.to_i}:#{(n*100).to_i}%" }.join(", ")}; Mode: #{a[1][:counts].sort { |r1, r2| r1[1] <=> r2[1] }.last[0].to_i}" };0

File.open('./data/team_sizes.csv', 'w+') do |f|
  f << "Language,1 person,2-4 people,5-9 people,10-14 people,15-20 people,20+ people\n"

  pavgs.each do |lang, data|
    f << [lang, data[:counts][1.0], data[:counts][2.5], data[:counts][7.0], data[:counts][12.0], data[:counts][17.5], data[:counts][20.0]].map(&:to_s).join(",") + "\n"
  end
end
