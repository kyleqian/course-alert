# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string
#  subject_settings :text
#  public_id        :string
#  subscribed       :boolean
#  verified         :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class User < ApplicationRecord
  before_create :create_public_id, :preprocess_user
  validates :email, presence: true
  validates :subject_settings, presence: true

  def create_public_id
    begin
      self.public_id = SecureRandom.hex(4)
    end while self.class.exists?(public_id: public_id)
  end

  def preprocess_user
    self.subscribed = false
    self.verified = false
  end
end
