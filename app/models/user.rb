class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
	has_many :favorites, dependent: :destroy
	has_many :book_comments, dependent: :destroy

	has_many :active_relationships, class_name: "Relationship", foreign_key: :following_id
	has_many :followings, through: :active_relationships, source: :follower
	has_many :passive_relationships, class_name: "Relationship", foreign_key: :follower_id
	has_many :followers, through: :passive_relationships, source: :following

  attachment :profile_image, destroy: false

  def followed_by?(user)
    passive_relationships.find_by(following_id: user.id).present?
  end

  def self.looks(search, word)
    if search == "perfect_match"
      @user = User.where("name LIKE?", "#{word}")
    elsif search == "forward_match"
      @user = User.where("name LIKE?","#{word}%")
    elsif search == "backward_match"
      @user = User.where("name LIKE?","%#{word}")
    elsif search == "partial_match"
      @user = User.where("name LIKE?","%#{word}%")
    else
      @user = User.all
    end
  end

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }

end
