require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get latest" do
    get books_latest_url
    assert_response :success
  end

  test "should get archives" do
    get books_archives_url
    assert_response :success
  end

end
