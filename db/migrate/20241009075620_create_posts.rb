class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true # 外部キー(user_id)
      t.string :image_link # 書影リンク
      t.string :title, null: false # 書名
      t.string :writer, null: false # 著者名
      t.text :main_text_detail # 本文詳細
      t.text :body # 感想

      t.timestamps # created_atとupdated_at
    end
  end
end
