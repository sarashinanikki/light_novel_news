#   ========================
#      ライブラリ読み込み
#   ========================

require 'open-uri'
require 'time'

#   ========================
#           処理本体
#   ========================

namespace :scrape_data do
    #   ========================
    #           電撃文庫
    #   ========================
    desc '電撃文庫の新刊情報取得'
    task :dengeki => :environment do
        #   ========================
        #          文字列処理
        #   ========================
        def text_strip(str)
            str.gsub(/(\r\n|\r|\n|\f)/, "")
        end

        def text_format(str)
            t = Time.strptime(str, "%Y年 %m月%d日")
            t.strftime("%Y/%m/%d")
        end


        #   ========================
        #           定数管理
        #   ========================
        
        #スクレイピング先のURL
        URL = 'https://dengekibunko.jp/product/newrelease-bunko.html'
        #何月刊行かを取得するパス
        MONTH = '//span[@class="month"]'
        #<ul>があるのでそれを取得するパス
        ULIST = '//ul[@class="js-summary-product-list-with-image p-product-media list-unstyled"]'
        #各リストを取得するパス
        LIST = './/li[@class="p-books-media02__wrap -border js-summary-product-list-item"]'
        #タイトル、URL、著者、絵師、サブタイトル、画像、ISBN、発売日、値段を取得するパス
        TITLE = './/h2[@class="p-books-media__title"]'
        BOOKS_URL = 'a'
        AUTHORS = './/a[@class="p-books-media__authors-link"]'
        SUBTITLES = './/p[@class="p-books-media__lead"]'
        DESCRIPTION = './/p[@class="p-books-media__summary"]'
        IMG = './/img[@class="js-img-fallback p-books-media02__img img-fluid m-0"]'
        TABLES = './/table[@class="p-books-media02__info d-none d-md-table"]//td'

        #   ========================
        #        スクレイピング
        #   ========================

        charset = nil
        html = open(URL) do |f|
            charset = f.charset
            f.read
        end

        #結果格納配列
        results = Array.new(0)

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
        
        #レーベル
        label = "電撃文庫"

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
                description_node = li.xpath(DESCRIPTION)

                #各テキストデータの取得
                title = title_node.inner_text
                books_url = books_url_node.attribute('href').value
                author = authors_node[0].inner_text
                illustrator = authors_node[1].inner_text
                subtitle = subtitle_node[0].inner_text
                img = img_node.attribute('src').value
                isbn = tables_node[0].inner_text
                publish_date = text_format(tables_node[1].inner_text)
                description = text_strip(description_node[0].inner_text)
                price = tables_node[2].inner_text
                results << {title: title, author: author, illustrator: illustrator, subtitle: subtitle, img: img, ISBN: isbn, publish_date: publish_date, price: price, books_url: books_url, scrape_date: date, month: month_num, label: label, desc: description}
            end
            #翌月に切り替え
            month_num = next_month_num
        end


        #   ========================
        #        DBへの書き込み
        #   ========================

        results.each do |re|
            p re
        end

        puts "インポート処理を開始"
        # インポートができなかった場合の例外処理
        exception_flag = false

        # 重複しないよう1つずつ確認してDBに保存する
        results.each do |re|
            if (Book.where(ISBN: re[:ISBN]).count < 1)
                if !(Book.create(re))
                    exception_flag = true
                end
            end
        end
            
        if !(exception_flag)
            puts "インポート完了!!"
        else
            puts "インポートに失敗：UnknownAttributeError"
        end
    end

    #   ========================
    #    富士見ファンタジア文庫
    #   ========================    

    desc '富士見ファンタジア文庫の新刊情報取得'
    task :hujimi_fantasia => :environment do

        #   ========================
        #          文字列処理
        #   ========================

        def text_split(str)
            ret = str.split(' ')
            return ret
        end

        def text_format(str)
            t = Time.strptime(str, "%Y年 %m月%d日")
            t.strftime("%Y/%m/%d")
        end

        def detect_month(str)
            12.downto(1) do |i|
                if (str.include?("#{i}月"))
                    return i
                end
            end
        end
        
        def text_strip(str)
            ret = str.gsub!(/(\r\n|\r|\n|\f)/, "")
            ret.gsub(/ /, "")
        end


        #   ========================
        #           定数管理
        #   ========================
        
        #スクレイピング先のURL
        URL = 'http://www.fujimishobo.co.jp/novel/fantasia.php'
        #各書籍のデータを取得するパス
        BOOK_LIST = '//div[@class="inner"]'
        #何月刊行かを取得するパス
        MONTH = '//div[@class="new_title"]'
        #詳細情報が載っているURLを取得するパス
        BOOKS_URL = './/div[@class="common_book_box"]'
        #タイトルを取得するパス
        TITLE = '//h1[@class="book-title"]'
        #サブタイトルを取得するパス
        SUBTITLE = '//p[@class="book-title-sub"]'
        #著者と絵師を取得するパス
        AUTHORS = '//span[@class="authors-pc"]'
        #値段を取得するパス
        PRICE = '//li[@class="book-info-price"]'
        #発売日を取得するパス
        PUBLISH_DATE = '//dd[@class="detail-release-text"]'
        #ISBNを取得するパス
        ISBN = '//dd[@class="detail-isbn-text"]'
        #画像を取得するパス
        IMG = './/img'
        #あらすじを取得するパス
        DESCRIPTION = '//span[@class="show-text"]'

        #   ========================
        #        スクレイピング
        #   ========================

        charset = nil
        html = open(URL) do |f|
            charset = f.charset
            f.read
        end

        #結果格納配列
        results = Array.new(0)

        
        #現在時刻を取得する
        t = Time.new
        date = t.strftime("%Y/%m/%d/%H")
        
        #レーベル
        label = "富士見ファンタジア文庫"
        
        #全htmlを取得する
        doc = Nokogiri::HTML.parse(html, nil, charset)
        
        #何月刊行か取得する
        month_num_node = doc.xpath(MONTH)
        month_num = detect_month(month_num_node.inner_text)

        #各書籍のリストを取得
        book_list_node = doc.xpath(BOOK_LIST)
        
        book_list_node.each do |bl|
            #各詳細情報ページのリンクが書かれた段落を取得する
            paras = bl.xpath(BOOKS_URL)

            #詳細情報ページへのURL取得
            books_url = paras.xpath('.//a').attribute('href').value
            
            #詳細情報ページの全htmlを取得
            sub_charset = nil
            sub_html = open(books_url) do |f|
                sub_charset = f.charset
                f.read
            end
            sub_doc = Nokogiri::HTML.parse(sub_html, nil, sub_charset)

            #各ノードの取得
            title_node = sub_doc.xpath(TITLE)
            subtitle_node = sub_doc.xpath(SUBTITLE)
            authors_node = sub_doc.xpath(AUTHORS)
            price_node = sub_doc.xpath(PRICE)
            publish_date_node = sub_doc.xpath(PUBLISH_DATE)
            isbn_node = sub_doc.xpath(ISBN)
            description_node = sub_doc.xpath(DESCRIPTION)
            img_node = bl.xpath(IMG)

            title = title_node[0].inner_text
            subtitle = subtitle_node[0].inner_text
            authors = text_split(authors_node.inner_text)
            author = authors[0]
            illustrator = authors[1]
            price = text_strip(price_node[0].inner_text)
            publish_date = text_format(publish_date_node[0].inner_text)
            isbn = isbn_node.inner_text
            description = description_node.inner_text
            img = "http://www.fujimishobo.co.jp"
            img = img+img_node.attribute('src').value
            results << {title: title, author: author, illustrator: illustrator, subtitle: subtitle, img: img, ISBN: isbn, publish_date: publish_date, price: price, books_url: books_url, scrape_date: date, month: month_num, label: label, desc: description}
            sleep(0.5)
        end

        results.each do |re|
            p re
        end

        puts "インポート処理を開始"
        # インポートができなかった場合の例外処理
        exception_flag = false

        # 重複しないよう1つずつ確認してDBに保存する
        results.each do |re|
            if (Book.where(ISBN: re[:ISBN]).count < 1)
                if !(Book.create(re))
                    exceMFJption_flag = true
                end
            end
        end
            
        if !(exception_flag)
            puts "インポート完了!!"
        else
            puts "インポートに失敗：UnknownAttributeError"
        end
    end

    #   ========================
    #          MF文庫J
    #   ========================    

    desc 'MF文庫Jの新刊情報取得'
    task :MFJ => :environment do

        #   ========================
        #          文字列処理
        #   ========================

        def text_split(str)
            ret = str.split(' ')
            return ret
        end

        def text_format(str)
            t = Time.strptime(str, "%Y年%m月%d日")
            t.strftime("%Y/%m/%d")
        end

        def detect_month(str)
            12.downto(1) do |i|
                if (str.include?("#{i}月"))
                    return i
                end
            end
        end

        def search_month(str)
            t = Time.parse(str)
            t.month
        end
        
        
        def text_strip(str)
            ret = str.gsub!(/(\r\n|\r|\n|\f)/, "")
            ret.gsub(/ /, "")
        end


        #   ========================
        #           定数管理
        #   ========================
        
        #スクレイピング先のURL
        URL = 'https://mfbunkoj.jp/product/new-release.html'
        #何月刊行かを取得するパス
        MONTH = '//div[@class="new_title"]'
        #各書籍のデータを取得するパス
        BOOK_LIST = '//li[@class="clearfix"]'
        #詳細情報が載っているURLを取得するパス
        BOOKS_URL = './/h2//a'
        #タイトルを取得するパス
        TITLE = '//h1'
        #サブタイトルを取得するパス
        SUBTITLE = '//p[@class="catch"]'
        #著者と絵師を取得するパス
        AUTHORS = '//ul[@class="author"]//li//a'
        #値段、発売日、ISBNを取得するパス
        TABLE = './/dl[@class="clearfix"]//dd'
        #画像を取得するパス
        IMG = '//img[@class="js-img-fallback"]'
        #あらすじを取得するパス
        DESCRIPTION = '//p[@class="story"]'

        #   ========================
        #        スクレイピング
        #   ========================

        charset = nil
        html = open(URL) do |f|
            charset = f.charset
            f.read
        end

        #結果格納配列
        results = Array.new(0)

        
        #現在時刻を取得する
        t = Time.new
        date = t.strftime("%Y/%m/%d/%H")
        
        #レーベル
        label = "MF文庫J"
        
        #全htmlを取得する
        doc = Nokogiri::HTML.parse(html, nil, charset)

        #各書籍のリストを取得
        book_list_node = doc.xpath(BOOK_LIST)
        
        book_list_node.each do |bl|
            #詳細情報ページへのURL取得
            books_url = bl.xpath(BOOKS_URL).attribute('href').value

            #詳細情報ページの全htmlを取得
            sub_charset = nil
            sub_html = open(books_url) do |f|
                sub_charset = f.charset
                f.read
            end
            sub_doc = Nokogiri::HTML.parse(sub_html, nil, sub_charset)

            #各ノードの取得
            title_node = sub_doc.xpath(TITLE)
            subtitle_node = sub_doc.xpath(SUBTITLE)
            authors_node = sub_doc.xpath(AUTHORS)
            description_node = sub_doc.xpath(DESCRIPTION)
            img_node = sub_doc.xpath(IMG)
            table_node = sub_doc.xpath(TABLE)

            title = title_node[0].inner_text
            subtitle = subtitle_node[0].inner_text
            author = authors_node[0].inner_text
            illustrator = authors_node[1].inner_text
            publish_date = text_format(table_node[0].inner_text)
            price = table_node[1].inner_text
            isbn = table_node[3].inner_text
            description = description_node.inner_text
            img = img_node[0].attribute('src').value
            month_num = search_month(publish_date)
            results << {title: title, author: author, illustrator: illustrator, subtitle: subtitle, img: img, ISBN: isbn, publish_date: publish_date, price: price, books_url: books_url, scrape_date: date, month: month_num, label: label, desc: description}
            sleep(0.5)
        end

        results.each do |re|
            p re
        end
        
        puts "インポート処理を開始"
        # インポートができなかった場合の例外処理
        exception_flag = false

        # 重複しないよう1つずつ確認してDBに保存する
        results.each do |re|
            if (Book.where(ISBN: re[:ISBN]).count < 1)
                if !(Book.create(re))
                    exception_flag = true
                end
            end
        end
            
        if !(exception_flag)
            puts "インポート完了!!"
        else
            puts "インポートに失敗：UnknownAttributeError"
        end
    end

    #   ========================
    #          MF文庫J
    #   ========================    

    desc 'MF文庫Jの新刊情報取得'
    task :MFJ => :environment do

        #   ========================
        #          文字列処理
        #   ========================

        def text_split(str)
            ret = str.split(' ')
            return ret
        end

        def text_format(str)
            t = Time.strptime(str, "%Y年%m月%d日")
            t.strftime("%Y/%m/%d")
        end

        def detect_month(str)
            12.downto(1) do |i|
                if (str.include?("#{i}月"))
                    return i
                end
            end
        end

        def search_month(str)
            t = Time.parse(str)
            t.month
        end
        
        
        def text_strip(str)
            ret = str.gsub!(/(\r\n|\r|\n|\f)/, "")
            ret.gsub(/ /, "")
        end


        #   ========================
        #           定数管理
        #   ========================
        
        #スクレイピング先のURL
        URL = 'https://mfbunkoj.jp/product/new-release.html'
        #何月刊行かを取得するパス
        MONTH = '//div[@class="new_title"]'
        #各書籍のデータを取得するパス
        BOOK_LIST = '//li[@class="clearfix"]'
        #詳細情報が載っているURLを取得するパス
        BOOKS_URL = './/h2//a'
        #タイトルを取得するパス
        TITLE = '//h1'
        #サブタイトルを取得するパス
        SUBTITLE = '//p[@class="catch"]'
        #著者と絵師を取得するパス
        AUTHORS = '//ul[@class="author"]//li//a'
        #値段、発売日、ISBNを取得するパス
        TABLE = './/dl[@class="clearfix"]//dd'
        #画像を取得するパス
        IMG = '//img[@class="js-img-fallback"]'
        #あらすじを取得するパス
        DESCRIPTION = '//p[@class="story"]'

        #   ========================
        #        スクレイピング
        #   ========================

        charset = nil
        html = open(URL) do |f|
            charset = f.charset
            f.read
        end

        #結果格納配列
        results = Array.new(0)

        
        #現在時刻を取得する
        t = Time.new
        date = t.strftime("%Y/%m/%d/%H")
        
        #レーベル
        label = "MF文庫J"
        
        #全htmlを取得する
        doc = Nokogiri::HTML.parse(html, nil, charset)

        #各書籍のリストを取得
        book_list_node = doc.xpath(BOOK_LIST)
        
        book_list_node.each do |bl|
            #詳細情報ページへのURL取得
            books_url = bl.xpath(BOOKS_URL).attribute('href').value

            #詳細情報ページの全htmlを取得
            sub_charset = nil
            sub_html = open(books_url) do |f|
                sub_charset = f.charset
                f.read
            end
            sub_doc = Nokogiri::HTML.parse(sub_html, nil, sub_charset)

            #各ノードの取得
            title_node = sub_doc.xpath(TITLE)
            subtitle_node = sub_doc.xpath(SUBTITLE)
            authors_node = sub_doc.xpath(AUTHORS)
            description_node = sub_doc.xpath(DESCRIPTION)
            img_node = sub_doc.xpath(IMG)
            table_node = sub_doc.xpath(TABLE)

            title = title_node[0].inner_text
            subtitle = subtitle_node[0].inner_text
            author = authors_node[0].inner_text
            illustrator = authors_node[1].inner_text
            publish_date = text_format(table_node[0].inner_text)
            price = table_node[1].inner_text
            isbn = table_node[3].inner_text
            description = description_node.inner_text
            img = img_node[0].attribute('src').value
            month_num = search_month(publish_date)
            results << {title: title, author: author, illustrator: illustrator, subtitle: subtitle, img: img, ISBN: isbn, publish_date: publish_date, price: price, books_url: books_url, scrape_date: date, month: month_num, label: label, desc: description}
            sleep(0.5)
        end

        results.each do |re|
            p re
        end
        
        puts "インポート処理を開始"
        # インポートができなかった場合の例外処理
        exception_flag = false

        # 重複しないよう1つずつ確認してDBに保存する
        results.each do |re|
            if (Book.where(ISBN: re[:ISBN]).count < 1)
                if !(Book.create(re))
                    exception_flag = true
                end
            end
        end
            
        if !(exception_flag)
            puts "インポート完了!!"
        else
            puts "インポートに失敗：UnknownAttributeError"
        end
    end
end
