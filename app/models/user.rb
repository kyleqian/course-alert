# == Schema Information
#
# Table name: users
#
#  id                       :integer          not null, primary key
#  email                    :string
#  subject_settings         :text
#  public_id                :string
#  subscribed               :boolean
#  verified                 :boolean
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  pending_subject_settings :text
#

class User < ApplicationRecord
  include ActiveModel::Validations

  before_validation :create_public_id, :preprocess_user, on: :create
  validates :email, presence: true
  validates :subject_settings, presence: true
  validates :pending_subject_settings, presence: true
  validate :validate_email
  validate :validate_subject_settings
  validate :validate_pending_subject_settings

  def create_public_id
    begin
      self.public_id = SecureRandom.hex(4)
    end while self.class.exists?(public_id: public_id)
  end

  def preprocess_user
    self.subscribed = false
    self.verified = false
    self.subject_settings = '[]'
  end

  def validate_email
    errors.add(:email, "is not valid") unless (/@/ =~ email) != nil
  end

  def validate_subject_settings
    errors.add(:subject_settings, "is not valid") unless JSON.parse(subject_settings).is_a? Array
  end

  def validate_pending_subject_settings
    errors.add(:pending_subject_settings, "is not valid") unless JSON.parse(pending_subject_settings).is_a? Array
  end
end
