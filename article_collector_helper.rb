require File.dirname(__FILE__) + '/../redruby/lib/redruby'
require 'pp'
require 'lingua/en/readability'

class String
    include Lingua::EN
    def readability
        Readability.new(self)
    end
end

