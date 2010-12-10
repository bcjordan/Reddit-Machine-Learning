# Load required modules, etc
require File.dirname(__FILE__) + '/article_collector_helper.rb'

module RedditML
    class ArticleCollector
        DEBUG = true
        SUBMISSION_URL_PREFIX = "http://www.reddit.com/by_id/"
        TIME_INTERVAL = 30 # seconds between data refreshes
        
        
        attr_accessor :list_url, :submissions, :refresh_url, :parser
        
        # Init method takes a reddit URL and loads its json page
        def initialize(url)
            @list_url = url
            
            @submissions = {}
        end
        
        def load_csv(filename)
            
        end
        
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
        
        # Downloads a new copy of submission[0], stores it in submission
#        def refresh_submission submission
#            submission << RedRuby::Submission.new(load_json(submission[0].json_url)[0]["data"]["children"][0]["data"])
#        end
        
        # Uses @submissions to gennerate a @refresh_url
        def generate_refresh_url
            url = SUBMISSION_URL_PREFIX
            @submissions.each do |key, submission|
                url += "t3_#{key},"
            end
            
            url += ".json"
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
