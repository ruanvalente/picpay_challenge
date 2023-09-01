# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# crate a new commum type user
User.create!(
  full_name: 'Usuário Comum',
  cpf: '12345678901',
  email: 'usuario@exemplo.com',
  password: 'senha123',
  balance: 100,
  type: 'User'
)

User.create!(
  full_name: 'Usuário Comum 2',
  cpf: '12345678900',
  email: 'usuario2@exemplo.com',
  password: 'senha098',
  balance: 200,
  type: 'User'
)

# create a new merchant type user
Merchant.create!(
  full_name: 'Lojista',
  cpf: '98765432101',
  email: 'lojista@exemplo.com',
  password: 'senha456',
  balance: 50,
  type: 'Merchant'
)
