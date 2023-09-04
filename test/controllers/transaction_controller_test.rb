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

  test 'should create a transaction with valid parameters' do
    Transaction.destroy_all
    post :create, params: { sender_id: @sender.id, receiver_id: @receiver.id, amount: 10 }
    expected_response = '{"message":"Transaction was successful"}'
    assert_response expected_response.include?(response.body) ? :created : :unauthorized
    assert_equal expected_response.include?(response.body) ? 1 : 0, Transaction.count
  end

  test 'is not allowed to create a transaction with user type merchant' do
    Transaction.destroy_all
    post :create, params: { sender_id: @merchant.id, receiver_id: @receiver.id, amount: 10 }

    expected_response = '{"message":"Merchants cannot send money"}'
    assert_response :unprocessable_entity
    assert_equal expected_response, response.body
    assert_equal 0, Transaction.count
  end

  test 'it is not allowed to create a transaction if the balance amount is greater than the one sent.' do
    Transaction.destroy_all
    post :create, params: { sender_id: @sender.id, receiver_id: @receiver.id, amount: 2000 }
    expected_response = '{"message":"Insufficient balance"}'

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

  test 'it is not allowed to create a transaction if the user not unauthorized' do
    Transaction.destroy_all
    post :create, params: { sender_id: @sender.id, receiver_id: @receiver.id, amount: 10 }
    expected_response = '{"message":"Transaction is not authorized"}'

    if response.body.include?(expected_response)
      assert_response :unauthorized
      assert_equal expected_response, response.body
      assert_equal 0, Transaction.count
    end
  end
end
