require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Tumblr
  attr_accessor :articles
    
  def initialize(url)
    get_full_list(url)
    @tumblelog = @xml.xpath("//tumblelog")
    @posts = @body.xpath("//post")
    @articles = []
    @total.times do |num|
      @articles.push Article.new(@posts[num])
    end
  end
  
  class Article
    attr_accessor :id, :url, :type, :date_gmt, :date, :unix_timestamp, :format, :reglog_key, :slug
    def initialize(post)
      @article = Nokogiri::XML(post.to_s, nil, 'UTF-8').xpath("//post")[0]
      @id = @article['id']
      @url = @article['url']
      @type = @article['type']
      @date_gmt = @article['date-gmt']
      @date = @article['date']
      @unix_timestamp = @article['unix_timestamp']
      @format = @article['format']
      @reblog_key = @article['reblog-key']
      @slug = @article['slug']
    end
    
    def title
      title = ""
      unless @article.xpath("//photo-caption")[0].nil?
        title = @article.xpath("//photo-caption")[0].content 
        @article.xpath("//photo-caption")[0].remove
      end
      unless @article.xpath("//regular-title")[0].nil?
        title = @article.xpath("//regular-title")[0].content
        @article.xpath("//regular-title")[0].remove 
      end
      title
    end
    
    def content
      @article.css("photo-url").each do |elem|
        "<img src = \"" + elem.content + "\" />"
        elem.remove
      end
      @article
    end
  end
  
  def id
    @tumblelog[0]['name']
  end
  
  def title
    @tumblelog[0]['title']
  end
  
  def timezone
    @tumblelog[0]['timezone']
  end
  
  def to_s
    "http://" + @tumblelog[0]['name'] + ".tumblr.com"
  end
  
  def get_full_list(url)
    uri = url + "/api/read?num=50"
    @xml = Nokogiri::HTML(open(uri), nil, 'UTF-8')
    posts = @xml.xpath("//posts").to_s
    @total = @xml.xpath("//posts")[0]['total'].to_i
    pages = @total.to_i/50
    num = 50
    pages.times do
      uri = url + "/api/read?num=50&start=" + num.to_s
      temp = Nokogiri::HTML(open(uri), nil, 'UTF-8').xpath("//posts").to_s
      posts = posts + temp
      num += 50
    end
    @body = Nokogiri::HTML(posts, nil, 'UTF-8')
  end  
end

=begin
url = "http://thejoysofbeingjoy.tumblr.com"
articles = Tumblr.new(url).articles
puts articles[0].title
=end