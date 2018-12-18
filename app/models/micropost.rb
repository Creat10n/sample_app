class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.microposts.content.length}
  validate  :picture_size

  default_scope ->{order(created_at: :desc)}
  scope :feed, (
    lambda do |following_ids, id|
      where "user_id IN (#{following_ids}) OR user_id = :user_id",
        following_ids: following_ids, user_id: id
    end
  )

  mount_uploader :picture, PictureUploader

  private
  # Validates the size of an uploaded picture.
  def picture_size
    return unless picture.size > Settings.microposts.picture_size.megabytes

    errors.add :picture, I18n.t("microposts.flash.picture_size")
  end
end
