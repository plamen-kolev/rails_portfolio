class ArticlesController < ApplicationController
  def index
    @articles = Article.all
    expires_in 3.days, :public => true
    fresh_when @articles
  end

  def show
    @article = Article.where(slug: params[:slug]).first
    expires_in 3.days, :public => true
    fresh_when @article
  end
end
