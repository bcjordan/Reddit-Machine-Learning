# Load required modules, etc
require File.dirname(__FILE__) + '/article_collector_helper.rb'

module RedditML
    class CSVCollector
        SUBMISSION_URL_PREFIX = "http://www.reddit.com/by_id/"        
        NEW_SUBMISSIONS_URL = "http://www.reddit.com/new/.json?sort=new&limit=100"
        
        attr_accessor :refresh_url, :parser, :parsed_submissions, :filename
        
        # Init method takes a reddit URL and loads its json page
        def initialize(csv_filename)
            @filename = csv_filename
        end
        
        # Get new articles takes a URL which contains the articles we will place
        # as the IDs for our CSV file
        def get_new_articles(url = NEW_SUBMISSIONS_URL, write_filename = @filename)
            get_submissions(url)
            write_new_csv(write_filename)
        end
        
        # Get submissions from a certain URL
        def get_submissions(url)
            @parser = RedRuby::Parser.new(url)
            @parser.parse_submissions
            @parsed_submissions = @parser.submissions
        end
        
        # Writes new CSV file with submission objects in @parsed_submissions
        def write_new_csv(write_filename = @filename)
            # Open a file with the name write_filename for writing
            total_string = "#{generate_refresh_url}\n"
            
            @parsed_submissions.each do |sub| # For each submission
                line = "#{sub.self_id},#{sub.score},#{sub.ups},#{sub.downs},#{ratio(sub.ups,sub.downs)},#{sub.num_comments}\n"
                total_string += line # Add line to string to write
            end
            
            # Write CSV string to file
            File.open(write_filename, 'w') {|f| f.write(total_string)} # WARNING: EMPTIES FILE
        end
            
        def ratio(up,down)
            return up.to_f/down.to_f unless down == 0
            return 0 if down == 0
            return 1 if down == 0 && up > 0
        end
        
        def add_to_csv(read_write_filename = @filename)
            total_string = ""
            
            first_line = true
            
            f = File.open(read_write_filename, "r") 
            f.each_line do |line|
                line.chomp! # Remove newline character
                if first_line
                    # Get first line from CSV, set refresh URL to it
                    first_line = false
                    total_string += "#{line}\n"
                    get_submissions(line)
                    @indexed_submissions = index_submissions
                else
                    sub = @indexed_submissions[line.split(",")[0]] # id
                    total_string += "#{line},#{sub.score},#{sub.ups},#{sub.downs},#{ratio(sub.ups,sub.downs)},#{sub.num_comments}\n" if sub
                end
            end
            f.close
            
            # Write CSV string to file
            File.open(read_write_filename, 'w') {|f| f.write(total_string)} # WARNING: EMPTIES FILE
        end
        
        def index_submissions
            indexed_submissions = {}
            @parsed_submissions.each do |sub|
                indexed_submissions[sub.self_id] = sub
            end
            return indexed_submissions
        end
        
        
=begin        
        def refresh_submissions
            if @submissions == {} # if this is our initial loading
                @refresh_url = @list_url
            else
                generate_refresh_url
            end
            
            @parser = RedRuby::Parser.new(@refresh_url)
            @parser.parse_submissions
            
            @parser.submissions.each do |submission|
                # Translate into CSV at this point?
                # If this is a new submission
                @submissions[submission.self_id] = [] unless @submissions[submission.self_id]
                @submissions[submission.self_id] << submission
            end
        end
=end

        # Downloads a new copy of submission[0], stores it in submission
#        def refresh_submission submission
#            submission << RedRuby::Submission.new(load_json(submission[0].json_url)[0]["data"]["children"][0]["data"])
#        end
        
        # Uses @submissions to gennerate a @refresh_url
        def generate_refresh_url
            url = SUBMISSION_URL_PREFIX
            @parsed_submissions.each do |submission|
                url += "t3_#{submission.self_id},"
            end
            
            url += ".json?limit=100"
            @refresh_url = url
        end
        
        private
        
        # Loads a JSON file from a local or remote location
        def load_json(location)
            contents = open(location) { |f| f.read }
            @json_string = contents
            return JSON.parse(@json_string)
        end
    end
end
