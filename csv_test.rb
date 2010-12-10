require 'csv_collector'

c = RedditML::CSVCollector.new("out/952.csv")
c.get_new_articles

#c = RedditML::CSVCollector.new("out/new.csv")
#c.add_to_csv
