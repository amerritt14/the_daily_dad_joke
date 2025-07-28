class SendAdminSummaryEmailsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting admin summary email send..."
    
    users = User.all
    pending_count = Joke.pending.count
    
    if users.empty?
      Rails.logger.warn "No users found to send admin summary emails to"
      return
    end

    sent_count = 0
    failed_count = 0

    users.find_each do |user|
      begin
        AdminNotificationMailer.pending_jokes_summary(user).deliver_now
        sent_count += 1
        Rails.logger.info "Sent admin summary email to #{user.email}"
      rescue StandardError => e
        failed_count += 1
        Rails.logger.error "Failed to send admin summary email to #{user.email}: #{e.message}"
      end
    end

    Rails.logger.info "Admin summary email send complete. Sent: #{sent_count}, Failed: #{failed_count}, Pending jokes: #{pending_count}"
  end
end
