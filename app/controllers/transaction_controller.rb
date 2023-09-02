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
    elsif sender.balance >= amount && AuthorizationService.authorize_transaction
      create_transaction(sender, receiver, amount)
    else
      render json: { message: 'Insufficient balance or authorization failed' }, status: :unprocessable_entity
    end
  end

  private

  def create_transaction(sender, receiver, amount)
    transaction = Transaction.new(sender:, receiver:, amount:, status: 'completed')
    if transaction.save
      sender.update(balance: sender.balance - amount)
      receiver.update(balance: receiver.balance + amount)
      render json: { message: 'Transaction was successful' }, status: :created
      NotificationService.notification_message('Transaction was successful', transaction)
    else
      render json: { message: 'Transaction failed' }, status: :unprocessable_entity
    end
  end
  
  def find_user(user_id)
    User.find_by(id: user_id)
  end

  def render_user_not_found_error
    render json: { message: 'User not found' }, status: :not_found
  end
end
