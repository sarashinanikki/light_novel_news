require 'time'

class BooksController < ApplicationController
  def latest
    t = Time.new
    dates1 = "%"+t.strftime("%Y/%m")+"%"
    @book_infos = Book.where("publish_date LIKE ?", dates1)
  end

  def archives
  end
end
