require 'rubygems'
require 'readability'
require 'open-uri'
require 'simple-rss'

rss_url = 'http://www.instapaper.com/rss/497567/21ZkhzGjxw4LlB0gntEMr0R5E'

def metadata
  return "<metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">
    	<dc:title>Kindle User's Guide</dc:title>
    	<dc:language>en-us</dc:language>
    	<meta name=\"cover\" content=\"My_Cover\" />
  	<dc:identifier id=\"BookId\" opf:scheme=\"ISBN\">9781375890815</dc:identifier>
  	<dc:creator>Kyu.co</dc:creator>
  	<dc:publisher></dc:publisher>
  	<dc:subject>Reference</dc:subject>
  	<dc:date>2009-11-17</dc:date>
  </metadata>"
end

def item(name, loc)
  return "<item id=\"" + name + "\" media-type=\"application/xhtml+xml\" href=\"" + loc + "\"></item>"
end

def spine(filenames)
  string = "<spine toc=\"My_Table_of_Contents\">"
  filenames.each_with_index do |filename, num|
    string += "<itemref idref=" + "%04d" % (num+1) + " />"
  end
  string += "</spine>"
  return string
end

rss = SimpleRSS.parse open(rss_url)
title = rss.channel.title # => "Slashdot"
link = rss.channel.link # => "http://slashdot.org/"
articles = rss.items.reverse

puts "# of articles: " + articles.size.to_s

Dir.mkdir "Archive" unless File.directory?("Archive")
Dir.chdir "Archive"
Dir.mkdir title unless File.directory?(title)
Dir.chdir title
date = Time.now.utc.strftime("%Y-%m-%d")
Dir.mkdir date unless File.directory?(date)
Dir.chdir date
time = Time.now.utc.strftime("%H%M%S")
Dir.mkdir time unless File.directory?(time)
Dir.chdir time

filenames = []
readables = []

articles.each_with_index do |article, num|
  url = article.link
  source = open(url).read
  filenames.push "%04d-" % (num+1) + article.title + ".html"
  readables.push "<body><h1>" +  article.title + "</h1>" + Readability::Document.new(source).content + "</body>"
  aHTML = File.new(filenames.last, "w+:utf-8")
  aHTML.puts '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
  aHTML.puts readables.last
  aHTML.close
  puts filenames.last
end

opf_filename = title + ".opf"
bookdata = File.new(opf_filename, "w+:utf-8")
bookdata.puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
bookdata.puts metadata
bookdata.puts "<manifest>"
filenames.each_with_index do |filename, num|
  bookdata.puts item("%04d" % (num+1), filename)
end
bookdata.puts "</manifest>"
bookdata.puts spine(filenames)
bookdata.puts "</package>"
bookdata.close
puts opf_filename

puts system("../../../../kindlegen " + "\"" + opf_filename + "\"")