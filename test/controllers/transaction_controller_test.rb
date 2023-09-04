require 'test_helper'

class TransactionControllerTest < ActionController::TestCase
  def setup
    @sender = FactoryBot.create(:user)
    @receiver = FactoryBot.create(:user, cpf: '42345678901', email: 'test@example.com')
    @merchant = FactoryBot.create(:user,
                                  type: 'Merchant',
                                  balance: 50,
                                  cpf: '1234567891',
                                  full_name: 'Merchant',
                                  email: 'merchant@example.com')
  end

  test 'create renders Transaction was successful message' do
    Transaction.destroy_all

    def AuthorizationService.authorize_transaction
      true
    end

    if AuthorizationService.authorize_transaction
      post :create, params: { sender_id: @sender.id, receiver_id: @receiver.id, amount: 20 }

      assert_response :created
      expected_response = '{"message":"Transaction was successful"}'
      assert_equal expected_response, response.body
      assert_equal 1, Transaction.count
    end
  end

  test 'is not allowed to create a transaction with user type merchant' do
    Transaction.destroy_all
    post :create, params: { sender_id: @merchant.id, receiver_id: @receiver.id, amount: 10 }

    expected_response = '{"message":"Merchants cannot send money"}'
    assert_response :unprocessable_entity
    assert_equal expected_response, response.body
    assert_equal 0, Transaction.count
  end

  test 'it is not allowed to create a transaction if the user not found' do
    Transaction.destroy_all

    post :create, params: { sender_id: @sender.id, receiver_id: 32, amount: 10 }
    expected_response = '{"message":"User not found"}'

    assert_response :not_found
    assert_equal expected_response, response.body
    assert_equal 0, Transaction.count
  end

  test 'create renders Insufficient balance error' do
    Transaction.destroy_all

    post :create, params: { sender_id: @sender.id, receiver_id: @receiver.id, amount: 20_000 }

    assert_response :unprocessable_entity
    expected_response = '{"message":"Insufficient balance"}'
    assert_equal expected_response, response.body
    assert_equal 0, Transaction.count
  end

  test 'create renders Transaction is not authorized error when authorization fails' do
    Transaction.destroy_all

    def AuthorizationService.authorize_transaction
      false
    end

    unless AuthorizationService.authorize_transaction
      post :create, params: { sender_id: @sender.id, receiver_id: @receiver.id, amount: 20 }

      assert_response :unauthorized
      expected_response = '{"message":"Transaction is not authorized"}'
      assert_equal expected_response, response.body
      assert_equal 0, Transaction.count
    end
  end
end
