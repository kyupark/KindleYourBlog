require 'rubygems'
require 'readability'
require 'open-uri'
require 'simple-rss'

rss = SimpleRSS.parse open('http://slashdot.org/index.rdf')
title = rss.channel.title # => "Slashdot"
link = rss.channel.link # => "http://slashdot.org/"
articles = rss.items

puts articles.size
articles.each do |article|
  url = article.link
  source = open(url).read
  puts readable = Readability::Document.new(source).content
end
