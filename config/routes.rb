Rails.application.routes.draw do
  root 'books#latest'
  get 'books/latest'
  get 'books/archives/:publish_date' => "books#archives"
  get 'books/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
