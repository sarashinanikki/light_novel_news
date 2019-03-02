require 'time'

class BooksController < ApplicationController
  def latest
    t = Time.new
    dates = "%"+t.strftime("%Y/%m")+"%"
    @book_infos = Book.where("publish_date LIKE ?", dates)
  end

  def archives
    t = Time.parse(params[:publish_date])
    dates = "%"+t.strftime("%Y/%m")+"%"
    @year_month = "#{t.year}年#{t.month}月"
    @book_infos = Book.where("publish_date LIKE ?", dates)
  end
end
