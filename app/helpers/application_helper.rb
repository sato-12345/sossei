module ApplicationHelper
  # タイトル動的表示用
  def page_title(title = '')
    base_title = 'MyApp'
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  # meta-tags gem使用時
  # def default_meta_tags
  #   {
  #     site: 'MyApp',
  #     title: 'MyApp',
  #     reverse: true,
  #     charset: 'utf-8',
  #     description: '引用された文章を参考に気になる本を探すことができます',
  #     keywords: '',
  #     canonical: request.original_url,
  #     separator: '|',
  #     og: {
  #       site_name: 'MyApp',
  #       title: 'MyApp',
  #       description: '引用された文章を参考に気になる本を探すことができま',
  #       type: 'website',
  #       url: request.original_url,
  #       image: image_url(''), # 配置するパスやファイル名によって変更する
  #       locale: 'ja_JP'
  #     },
  #     twitter: {
  #       card: '', # Twitterで表示する場合は大きいカードに変更
  #       site: '@', # アプリの公式Twitterアカウントがあれば、アカウント名を記載
  #       image: image_url('') # 配置するパスやファイル名によって変更
  #     }
  #   }
  # end
end
