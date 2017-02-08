class PagesController < ApplicationController
  def index
    @articles = Article.all
    a = render 'pages/index'
    expires_in 3.days, :public => true
    fresh_when @articles
  end
end
