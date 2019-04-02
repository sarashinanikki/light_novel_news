require 'time'

class BooksController < ApplicationController
  def latest
<<<<<<< HEAD
    t = Time.new
    dates = "%"+t.strftime("%Y/%m")+"%"
    @book_infos = Book.where("publish_date LIKE ?", dates)
=======
    now_date = Time.new;
    dates1 = "%"+now_date.strftime("%Y/%m")+"%"
    @book_infos = Book.where("publish_date LIKE ?", dates1)
>>>>>>> b472a794057eabfc39493e58721a106534e26ab9
  end

  def index
  end
  

  def archives
    t = Time.parse(params[:publish_date])
    dates = "%"+t.strftime("%Y/%m")+"%"
    @year_month = "#{t.year}年#{t.month}月"
    @book_infos = Book.where("publish_date LIKE ?", dates)
  end
end
