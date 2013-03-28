require 'rubygems'
require 'open-uri'
require 'tumblr_articles'

url = 'http://hai.kyu.co'

def metadata(title, date)
  string = "<metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">
    	<dc:title>#{title}</dc:title>
    	<dc:language>en-us</dc:language>
    	<meta name=\"cover\" content=\"My_Cover\" />
  	<dc:identifier id=\"BookId\" opf:scheme=\"ISBN\"></dc:identifier>
  	<dc:creator>Kyu.co</dc:creator>
  	<dc:publisher></dc:publisher>
  	<dc:subject>Reference</dc:subject>
  	<dc:date>#{date}</dc:date>
  </metadata>"
  return string
end

def item(name, loc)
  string = "<item id=\"#{name}"\" media-type=\"application/xhtml+xml\" href=\"#{loc}\"></item>"
  return string
end

def spine(filenames)
  string = "<spine toc=\"My_Table_of_Contents\">"
  filenames.each_with_index do |filename, num|
    string += "<itemref idref=" + "%04d" % (num+1) + " />"
  end
  string += "</spine>"
  return string
end

tumblr = Tumblr.new(url)
title = tumblr.title
link = tumblr
total = tumblr.articles.size

puts "# of articles: " + total.to_s

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
contents = []

total.times do |num|
  article = tumblr.articles[num]
  date = article.date
  filenames.push article.id + ".html"
  contents.push "<body><h1>" + article.title + "</h1><br/><small>" + date + "</small><br/>" + article.content + "</body>"
  aHTML = File.new(filenames.last, "w+:utf-8")
  aHTML.puts "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />"
  aHTML.puts contents.last
  aHTML.close
  puts filenames.last
end

opf_filename = title + ".opf"
bookdata = File.new(opf_filename, "w+:utf-8")
bookdata.puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
bookdata.puts metadata(title, date)
bookdata.puts "<manifest>"
filenames.reverse.each_with_index do |filename, num|
  bookdata.puts item("%04d" % (num+1), filename)
end
bookdata.puts "</manifest>"
bookdata.puts spine(filenames)
bookdata.puts "</package>"
bookdata.close
puts opf_filename

puts system("../../../../kindlegen " + "\"" + opf_filename + "\"")
