class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :writer, presence: true
end
