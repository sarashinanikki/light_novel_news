class BooksController < ApplicationController
  def latest
    dates1 = '%2019/03%'
    dates2 = '%2019/3%'
    @book_infos = Book.where("publish_date LIKE ?", dates1).or(Book.where("publish_date LIKE ?", dates2))
  end

  def archives
    t = Time.parse(params[:publish_date])
    dates = "%"+t.strftime("%Y/%m")+"%"
    @year_month = "#{t.year}年#{t.month}月"
    @book_infos = Book.where("publish_date LIKE ?", dates)
  end
end
