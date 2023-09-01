class User < ApplicationRecord
  has_many :set_transactions, class_name: 'Transaction', foreign_key: 'sender_id'
  has_many :received_transactions, class_name: 'Transaction', foreign_key: 'receiver_id'

  validates :cpf, uniqueness: true
  validates :email, uniqueness: true
end
