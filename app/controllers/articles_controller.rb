class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.where(slug: params[:slug]).first
  end
end
