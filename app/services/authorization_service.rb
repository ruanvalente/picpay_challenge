class AuthorizationService
  def self.authorize_transaction
    response = HTTParty.get('https://run.mocky.io/v3/8fafdd68-a090-496f-8c9a-3442cf30dae6')
    JSON.parse(response.body)['message'].downcase == 'autorizado'
  end
end
