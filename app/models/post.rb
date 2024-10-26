class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :writer, presence: true
  validates :main_text_detail, presence: true
end
