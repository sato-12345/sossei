# README

## サービス名
# [私の一文(仮)]

## サービス概要　
おすすめしたい本の心に残った一文を投稿できます（おすすめポイントや感想も一緒に投稿できます。一文のみでもOKです）。本を探しているユーザーは気になる一文から本の詳細に飛ぶことができます。
##　想定されるユーザー層
本が好きな人、おすすめしたい本がある人、読む本を探している人
## サービスコンセプト
読みたい本を探す時に、Twitter（X）で引用されている文章にひかれて買うことが多いので、心に残る文章を見つける感覚で本を探すアプリがあれば良いなと思いました。掲示板形式で、気になる一文をクリックすることで本の詳細ページに飛ぶことができます。その人がなぜその本をおすすめしたのか（感想）も見ることができたらさらに興味を持つきっかけになると思っています。誰かの心に残った文章をシンプルに表示させつつ、サーチもしやすいアプリにしていきたいです。
## 実装を予定している機能
### MVP
* 会員登録
* ログイン
* ログアウト
* 本文入力機能
* 本文編集機能
* 掲示板機能
* ブックマーク機能
### その後の機能（予定）
* 検索機能(ransackを使って実装予定)
* タグ機能(gutentagを使って実装予定)
* レスポンシブ機能
* API機能（できたら）
#### 使用技術（予定）
* フロントエンド
HTML / CSS / JavaScript / Tailwind CSS
* バックエンド
Ruby 3.2.3 / Rails 7.1.3.4
* ransack、gutentag、rails-i18n(国際化)、sorcery（ログイン機能）などのgemを使用予定です。
