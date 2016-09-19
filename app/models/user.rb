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
#  last_update_sent         :datetime
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

  def self.FIX
    toolkit = MainToolkit.new
    response = toolkit.get_latest_diff()
    latest_diff = response[:latest_diff]
    start_date = response[:start_date]
    end_date = response[:end_date]
    User.where("last_update_sent < ? or last_update_sent IS NULL", DateTime.now - 5.days).order(id: :asc).each do |u|
      next unless u.verified and u.subscribed

      sleep(2)

      user_settings = JSON.parse(u.subject_settings)
      user_diff = latest_diff.select { |course| user_settings.include? course['department'] }
      if user_diff.length > 0
        begin
          MainMailer.send_update(u, user_diff, start_date, end_date).deliver_now
        rescue => e
          puts e
          break
        else
          u.last_update_sent = DateTime.now
          u.save!
        end
      end
    end
  end

  def self.send_all(from_id=0)
    toolkit = MainToolkit.new
    response = toolkit.get_latest_diff()
    latest_diff = response[:latest_diff]
    start_date = response[:start_date]
    end_date = response[:end_date]
    User.where("id >= ?", from_id).order(id: :asc).each do |u|
      next unless u.verified and u.subscribed

      sleep(5)

      user_settings = JSON.parse(u.subject_settings)
      user_diff = latest_diff.select { |course| user_settings.include? course['department'] }
      if user_diff.length > 0
        begin
          MainMailer.send_update(u, user_diff, start_date, end_date).deliver_now
        rescue => e
          logger.fatal("SEND_ALL ERROR!\nUSER ID: #{u.id}\nMESSAGE: #{e.message}\n\n")
          break
        else
          u.last_update_sent = DateTime.now
          u.save!
        end
      end
    end
  end

  def self.send_test(email='kylecqian@gmail.com')
    toolkit = MainToolkit.new
    response = toolkit.get_latest_diff()
    latest_diff = response[:latest_diff]
    start_date = response[:start_date]
    end_date = response[:end_date]
    u = User.find_by(email: email)
    user_settings = JSON.parse(u.subject_settings)
    user_diff = latest_diff.select { |course| user_settings.include? course['department'] }
    if user_diff.length > 0
      MainMailer.send_update(u, user_diff, start_date, end_date).deliver_now
    end
  end
end
