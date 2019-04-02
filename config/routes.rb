Rails.application.routes.draw do
  root 'books#latest'
  get 'books/latest'
  get 'books/archives/:publish_date' => "books#archives"
<<<<<<< HEAD
=======
  get 'books/index'
>>>>>>> b472a794057eabfc39493e58721a106534e26ab9
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
