#   ===================
#   ライブラリ読み込み
#   ===================
require 'open-uri'
require 'time'


#   ===================
#       メイン処理
#   ===================
namespace :scrape_data do
    desc '電撃文庫の新刊情報取得'
    task :dengeki => :environment do
        #   ===================
        #        定数管理
        #   ===================
        
        #スクレイピング先のURL
        URL = 'https://dengekibunko.jp/product/newrelease-bunko.html'
        #何月刊行かを取得するパス
        MONTH = '//span[@class="month"]'
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

        #   ===================
        #     スクレイピング
        #   ===================

        charset = nil
        html = open(URL) do |f|
            charset = f.charset
            f.read
        end

        #結果格納配列(2月分発表されているので、月で分ける)
        results = Array.new(2).map{Array.new(0)}

        #全htmlを取得する
        doc = Nokogiri::HTML.parse(html, nil, charset)

        #何月刊行か取得する
        month_num_node = doc.xpath(MONTH)
        month_num = month_num_node[0].inner_text
        next_month_num = month_num_node[1].inner_text

        #各月のリスト全体を取得する
        two_ul = doc.xpath(ULIST)

        #現在時刻を取得する
        t = Time.new
        date = t.strftime("%Y/%m/%d/%H")
        
        #配列の添字
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
                results[cnt] << {title: title, author: author, illustrator: illustrator, subtitle: subtitle, img: img, ISBN: isbn, publish_date: publish_date, price: price, books_url: books_url, scrape_date: date, month: month_num}
            end
            #添字切り替え
            cnt+=1

            #翌月に切り替え
            month_num = next_month_num
        end


        #   ===================
        #     DBへの書き込み
        #   ===================

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
