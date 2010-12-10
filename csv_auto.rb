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

