class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :posts # Userが複数の投稿を持つ関連付け

  validates :password, length: { minimum: 8, maximum: 20 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password, format: { with: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])/, message: 'は大文字、小文字、数字、特殊文字を含める必要があります' }, if: -> { new_record? || changes[:crypted_password] }
  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true

  validate :no_consecutive_characters

  private

  def no_consecutive_characters
    if password =~ /(.)\1\1/
      errors.add(:password, 'は同じ文字を3回以上続けて使用することはできません')
    end
  end
end
