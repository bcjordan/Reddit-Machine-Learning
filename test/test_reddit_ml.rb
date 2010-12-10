require File.dirname(__FILE__) + '/test_helper.rb'

class RedditMLTest < Test::Unit::TestCase

    REDDIT_URL = "http://www.reddit.com/new/.json?sort=new"
    DEBUG = false
    # Unit tests
    
    should "get flesch and fog metrics for strings" do
        assert "hi".readability
        assert "hi".readability.flesch
        assert "hi".readability.fog
    end
    
    context "an article collector" do
        setup do
            @collector = RedditML::ArticleCollector.new(REDDIT_URL)
            @collector.refresh_submissions
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
                    @repeats = 2
                    
                    @repeats.times do |i|
                        print "refresh ##{i}" if DEBUG
                        sleep 5
                        puts "" if DEBUG
                        @collector.refresh_submissions
                    end
                    
                    @submissions_refreshed = @collector.submissions
                end
                   
                should "have a two samples of same submissions" do
                    pp @submissions_refreshed
                    # Number of submissions being tracked
                    assert_equal 25, @submissions_refreshed.size
                    # Number of samples from each submission
                    assert_equal 2, @submissions_refreshed[0].size
                    # Two samples from the same article should have the same
                    # 
                    @submissions_refreshed.each do |key, submission|
                        assert_equal key, submission[0].self_id
                        assert_equal key, submission[1].self_id
                    end
                end
            end
        end
    end
end