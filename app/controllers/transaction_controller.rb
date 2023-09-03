require 'httparty'
require 'notification_service'
require 'authorization_service'

class TransactionController < ApplicationController
  def create
    sender = find_user(params[:sender_id])
    receiver = find_user(params[:receiver_id])
    amount = params[:amount].to_d

    if sender.nil? || receiver.nil?
      render_user_not_found_error
    elsif sender.instance_of?(Merchant)
      render json: { message: 'Merchants cannot send money' }, status: :unprocessable_entity
    elsif sufficient_balance?(sender, amount) && authorize_transaction_successful?
      create_transaction(sender, receiver, amount)
    else
      status_response = if sufficient_balance?(sender,
                                               amount) && !authorize_transaction_successful?
                          :unauthorized
                        else
                          :unprocessable_entity
                        end
      puts "STATUS RESPONSE: #{status_response}"
      render_transaction_error_message(sender, amount, status_response)
    end
  end

  private

  def sufficient_balance?(sender, amount)
    sender.balance >= amount
  end

  def authorize_transaction_successful?
    AuthorizationService.authorize_transaction
  end

  def create_transaction(
    sender,
    receiver,
    amount
  )
    transaction = nil
    ActiveRecord::Base.transaction do
      transaction = Transaction.create(sender:, receiver:, amount:, status: 'completed')
      sender.update(balance: sender.balance - amount)
      receiver.update(balance: receiver.balance + amount)
    end

    return unless transaction

    render_transaction_success_message
    NotificationService.notification_message('Transaction was successful', transaction)
  end

  def render_transaction_success_message
    render json: { message: 'Transaction was successful' }, status: :created
  end

  def render_transaction_error_message(sender, amount, status)
    puts "STATUS: #{status}"
    render json: { message: transaction_error_message(sender, amount) }, status:
  end

  def transaction_error_message(sender, amount)
    if !sufficient_balance?(sender, amount)
      'Insufficient balance'
    else
      'Transaction is not authorized'
    end
  end

  def find_user(user_id)
    User.find_by(id: user_id)
  end

  def render_user_not_found_error
    render json: { message: 'User not found' }, status: :not_found
  end
end
