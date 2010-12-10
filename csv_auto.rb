require 'csv_collector'

@times = []
@number_samples = {}

# Converts minutes to seconds
def mins(minutes)
    return minutes * 60
end

def update (t)
    c = RedditML::CSVCollector.new("autoout/#{t}.csv")
    c.add_to_csv
    
    @number_samples[t] += 1
    sleep 2
end

while true do
    now = Time.now.to_i
    
    @times.each do |t|
        if @number_samples[t] == 1 && mins(19) < (now - t) && (now - t) < mins(21)
            # Do second data point
            update t
            puts "DP 2 for #{t}"
        elsif @number_samples[t] == 2 && mins(39) < (now - t) && (now - t) < mins(41)
            # Do third data point
            update t
            puts "DP 3 for #{t}"
        elsif @number_samples[t] == 3 && mins(59) < (now - t) && (now - t) < mins(61)
            update t
            # Do fourth data point and remove from array
            @times.delete(t)
            puts "DP 4 (finished) for #{t}"
        end
    end
    
    if @times.size == 0 || (now - @times[-1]) > mins(15) # more than 15 minutes since last batch
        c = RedditML::CSVCollector.new("autoout/#{now}.csv")
        c.get_new_articles
        
        @times << now
        @number_samples[now] = 1
        
        puts "DP 1 (new) for #{now}"
        
        sleep 2 # Wait 2 seconds due to JSON access
    end
    
    sleep 3 # Wait 3 seconds
end

#c = RedditML::CSVCollector.new("out/1137.csv")
#c.add_to_csv


# 952 NO! This is the hottest 46 year old female on the planet. By a significant margin, too. (SFW)
# old: 1017
# last: 1037
# DONE: 1057

# 1017 What is the WORST video on Youtube?
# last: 1037
# last: 1057
# DONE: 1117

# 1037 Ski or Snowboard?
# last: 1057
# last: 1117
# DONE: 1137

# 1057 Barbara Walters Says David Petraeus is the Most Fascinating Person of 2010. Do you agree?
# last: 1117
# last: 1137
# DONE: 1157

# 1117 Friend with cancer told me tonight he's stopping treatment. How can I be there without being physically there?
# last: 1137
# last: 1157
# NEXT/final: 1217

# 1137 Iron Chef: The Early Years
# last: 1157
# NEXT: 1217
# final: 1237

# 1157 A Letter from Anonymous to the Governments, Corporations and Citizens of the World.
# next: 1217
# next: 1237
# next: 1257
