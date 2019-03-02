class BooksController < ApplicationController
  def latest
    dates1 = '%2019/03%'
    dates2 = '%2019/3%'
    @book_infos = Book.where("publish_date LIKE ?", dates1).or(Book.where("publish_date LIKE ?", dates2))
  end

  def archives
  end
end
