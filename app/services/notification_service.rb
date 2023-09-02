class NotificationService
  def self.notification_message(message, transaction)
    puts "Notification message: #{message} - status: #{transaction.status}"
  end
end
