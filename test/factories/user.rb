FactoryBot.define do
  factory :user do
    full_name { 'Usuário Comum' }
    cpf { '12345678900' }
    email { 'usuario@exemplo.com' }
    password { 'senha098' }
    balance { 200 }
    type { 'User' }
  end
end
