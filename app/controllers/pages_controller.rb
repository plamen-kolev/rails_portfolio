class PagesController < ApplicationController
  def index
    @articles = Article.all
    a = render 'pages/index'
    puts a
  end
end
