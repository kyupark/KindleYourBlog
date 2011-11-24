require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Tumblr
  attr_accessor :total
    
  def initialize(url)
    get_full_list(url)
    @tumblelog = @xml.xpath("//tumblelog")
    @posts = @body.xpath("//post")
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
  
  def articles(num)
    @posts[num]
  end
  
  def get_full_list(url)
    uri = url + "/api/read?num=50"
    @xml = Nokogiri::XML(open(uri), nil, 'UTF-8')
    posts = @xml.xpath("//posts").to_s
    @total = @xml.xpath("//posts")[0]['total'].to_i
    pages = @total.to_i/50
    num = 50
    pages.times do
      uri = url + "/api/read?num=50&start=" + num.to_s
      temp = Nokogiri::XML(open(uri), nil, 'UTF-8').xpath("//posts").to_s
      posts = posts + temp
      num += 50
    end
    @body = Nokogiri::HTML(posts, nil, 'UTF-8')
  end  
end

url = "http://thejoysofbeingjoy.tumblr.com"
tumblr = Tumblr.new(url)
puts tumblr.articles(156)['date']
