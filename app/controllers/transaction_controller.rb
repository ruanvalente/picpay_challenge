class TransactionController < ApplicationController
  def index
    Transacion.all
  end

  def create
    sender = User.find_by(id: params[:sender_id])
    receiver = User.find_by(id: params[:receiver_id])
    amount = params[:amount].to_d

    if sender.instance_of?(Merchant)
      render json: { message: 'Merchants cannot send money' }, status: :unprocessable_entity
    elsif sender.balance >= amount
      transaction = Transaction.new(sender:, receiver:, amount:)

      if transaction.save
        sender.update(balance: sender.balance - amount)
        receiver.update(balance: receiver.balance + amount)
        render json: { message: 'Transaction was successfully' }, status: :created
      else
        render json: { message: 'Transaction failed' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'Insufficient balance' }, status: :unprocessable_entity
    end
  end
end
