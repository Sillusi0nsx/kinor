# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'scraperwiki'
require 'mechanize'
require 'date'

=begin
AGENT_ALIASES = {
  'Windows IE 6' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
  'Windows IE 7' => 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
  'Windows Mozilla' => 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6',
  'Mac Safari' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10',
  'Mac FireFox' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6',
  'Mac Mozilla' => 'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401',
  'Linux Mozilla' => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
  'Linux Firefox' => 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.1) Gecko/20100122 firefox/3.6.1',
  'Linux Konqueror' => 'Mozilla/5.0 (compatible; Konqueror/3; Linux)',
  'iPhone' => 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28 Safari/419.3',
  'Mechanize' => "WWW-Mechanize/#{VERSION} (http://rubyforge.org/projects/mechanize/)"
}
=end

ScraperWiki.config = { db: 'data.sqlite', default_table_name: 'data' }

agent = Mechanize.new
agent.user_agent_alias = 'Windows IE 7'#'Mac Safari'

for i in 1..1
page = agent.get("http://kinokong.net/films/page/#{i}/")

 page.encoding = "windows-1251"

  list_films = page.links_with(href: %r{^http://kinokong.net/[\d\w\-]+\.html})
#list_image_preview = page.parser.xpath('//*[@id="dle-content"]/div/div/div[2]/div[1]/img')
  puts 'Cycle: ',i
  puts 'List of films'
  puts '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  puts list_films
  puts '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

  #list_films = list_films[0...1]
  # puts list_films
#puts list_image_preview

  reviews = list_films.map do |link|
    if link.text == ''
      next
    end
    review = link.click

    url = link.href
    puts url
    title = (review.search('.full-kino-title h1[1]').text)
    # artist = review_meta.search('h1')[0].text
    # album = review_meta.search('h2')[0].text
    # label, year = review_meta.search('h3')[0].text.split(';').map(&:strip)
    # reviewer = review_meta.search('h4 address')[0].text
    # review_date = Date.parse(review_meta.search('.pub-date')[0].text)
    # score = review_meta.search('.score').text.to_f
    year = review.parser.xpath('//*[@id="left"]/div[1]/div[3]/div[3]/b').text

    sound = review.parser.xpath('//*[@id="left"]/div[1]/div[3]/div[4]/b/em').text
    country = (review.parser.xpath('//*[@id="left"]/div[1]/div[3]/div[1]/b').text)
    duration = review.parser.xpath('//*[@id="left"]/div[1]/div[3]/div[2]/b').text
    genre = review.parser.xpath('//*[@id="left"]/div[1]/div[3]/div[5]/b').text
    actors = (review.parser.xpath('//*[@id="left"]/div[1]/div[4]/a').text)#.join(";")#.to_s
    director = (review.parser.xpath('//*[@id="left"]/div[1]/div[5]/a').text)
    #image = review.parser.xpath('//*[@id="imgbigp"]')
    image = review.image_with(:id => 'imgbigp')
    quality_rip = review.parser.xpath('//*[@id="left"]/div[1]/div[1]/div').text
    content = review.parser.xpath('//*[@id="right"]/div[6]/div[2]').text
    #p '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
    #p content
    match = content.scan(/flashvars\s*=\s*(.*)\s*;\s*var\s*params/i).to_s
    p '<------------------------------------>'
    p match
    #p '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
    #('//*[@id="videoplayer15841"]')
    # review.parser.xpath('').text
    desc = (review.search('.full-kino-story').text)#.parser.xpath('//*[@id="right"]/div[3]')#.text

    sql = "INSERT INTO data (title,url,`data`,`year`,sound,country,duration,genre,actors,`image`,quality_rip,`desc`) VALUES ('#{title}','#{url}','#{match}','#{year}','#{sound}','#{country}','#{duration}','#{genre}','#{actors}','#{image}','#{quality_rip}','#{desc}')"
    #puts sql
	ScraperWiki.save_sqlite(["name"], {"name" => title, "occupation" => match})

  end
end

ScraperWiki.select("* from data")
