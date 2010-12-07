require File.dirname(__FILE__) + '/test_helper.rb'

class RedditMLTest < Test::Unit::TestCase

    REDDIT_URL = "http://www.reddit.com/new/.json?sort=new"
    
    
    # Unit tests
    
    context "an article collector" do
        setup do
            @collector = RedditML::ArticleCollector.new(REDDIT_URL)
        end
        
        should "create a user" do
            assert @collector
            assert @collector.list_url
            assert @collector.parser
        end
        
        context "with parsed articles" do
            setup do
                @collector.refresh_submissions
                @submissions = @collector.submissions
            end
            
            should "create submission objects" do
                assert @submissions                
                assert_equal 25, @submissions.size # Listing page has 25 subs
                @submissions.each do |key, submission|
                    assert_equal key, submission[0].self_id
                    assert submission[0].url
                end
            end
            
            should "generate a refresh URL" do
                @collector.generate_refresh_url
                assert @collector.refresh_url
            end
            
            context "with refreshed submission objects" do
                setup do
                    # Test takes 2s * 25 articles = 50 seconds
                    
                    10.times do |i|
                        print "refresh ##{i}";
                        sleep 60
                        puts ""
                        @collector.refresh_submissions
                    end
                    
                    @submissions_refreshed = @collector.submissions
                end
                   
                should "have a second sample of same submissions" do
                    assert_equal 25, @submissions_refreshed.size
                    @submissions_refreshed.each do |key, submission|
                        assert_equal key, submission[0].self_id
                        assert_equal key, submission[1].self_id
                        
                        change_up = submission[9].ups - submission[0].ups
                        change_down = submission[9].downs - submission[0].downs
                        
                        if change_up != 0 or change_down != 0
                            puts "#{key} up: #{change_up}, down: #{change_down}: #{submission[0].title}"
                        end
                    end
                end
            end
        end
    end
end