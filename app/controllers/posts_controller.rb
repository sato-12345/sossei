class PostsController < ApplicationController
  before_action :require_login, only: [ :new, :create ]

  def index
    @posts = Post.includes(:user).page(params[:page]).per(8)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, notice: "投稿を作成しました"
    else
      flash.now[:danger] = t("投稿を作成出来ませんでした")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post), notice: "投稿を更新しました"
    else
      flash.now[:danger] = "投稿を更新出来ませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "投稿を削除しました"
  end

  private

  def post_params
    params.require(:post).permit(:title, :writer, :main_text_detail, :body)
  end
end
