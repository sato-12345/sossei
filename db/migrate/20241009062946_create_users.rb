class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name, null: false # ユーザー名（必須）
      t.string :email, null: false, index: { unique: true } # メールアドレス（必須・ユニーク）
      t.string :crypted_password, null: false # 暗号化されたパスワード（必須）
      t.string :salt # パスワードのセキュリティ強化用のsalt（必須）
      t.timestamps # created_at と updated_at を自動生成
    end
  end
end
