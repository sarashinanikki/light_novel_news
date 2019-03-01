require 'open-uri'
require 'json'
require 'date'

namespace :scrape_data do
    desc '電撃文庫の新刊情報取得'
    task :dengeki => :environment do
        #スクレイピング先のURL
        URL = 'https://dengekibunko.jp/product/newrelease-bunko.html'
        #<ul>があるのでそれを取得パス
        ULIST = '//ul[@class="js-summary-product-list-with-image p-product-media list-unstyled"]'
        #各リストを取得するパス
        LIST = './/li[@class="p-books-media02__wrap -border js-summary-product-list-item"]'
        #タイトル、URL、著者、絵師、サブタイトル、画像、ISBN、発売日、値段を取得するパス
        TITLE = './/h2[@class="p-books-media__title"]'
        BOOKS_URL = 'a'
        AUTHORS = './/a[@class="p-books-media__authors-link"]'
        SUBTITLES = './/p[@class="p-books-media__lead"]'
        IMG = './/img[@class="js-img-fallback p-books-media02__img img-fluid m-0"]'
        TABLES = './/table[@class="p-books-media02__info d-none d-md-table"]//td'

        charset = nil
        html = open(URL) do |f|
            charset = f.charset
            f.read
        end

        #結果格納配列(2月分発表されているので、月で分ける)
        results = Array.new(2).map{Array.new(0)}
        doc = Nokogiri::HTML.parse(html, nil, charset)
        two_ul = doc.xpath(ULIST)
        
        cnt = 0
        two_ul.each do |ulists|
            lists = ulists.xpath(LIST)
            lists.each do |li|
                #各ノードの取得
                title_node = li.xpath(TITLE)
                books_url_node = title_node.xpath(BOOKS_URL)
                authors_node = li.xpath(AUTHORS)
                subtitle_node = li.xpath(SUBTITLES)
                img_node = li.xpath(IMG)
                tables_node = li.xpath(TABLES)

                #各テキストデータの取得
                title = title_node.inner_text
                books_url = books_url_node.attribute('href').value
                author = authors_node[0].inner_text
                illustrator = authors_node[1].inner_text
                subtitle = subtitle_node[0].inner_text
                img = img_node.attribute('src').value
                isbn = tables_node[0].inner_text
                publish_date = tables_node[1].inner_text
                price = tables_node[2].inner_text
                results[cnt] << {title: title, author: author, illustrator: illustrator, subtitle: subtitle, img: img, ISBN: isbn, date: publish_date, price: price, books_url: books_url}
            end
            cnt+=1
        end

        month = 2

        results.each do |r|
            p "----------#{month}月の新刊----------"
            r.each do |texts|
                p texts
            end
            month+=1
        end
    end
    end
end
