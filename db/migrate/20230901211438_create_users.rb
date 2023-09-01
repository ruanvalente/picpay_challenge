class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :cpf
      t.string :email
      t.string :password
      t.decimal :balance
      t.string :type

      t.timestamps
    end
  end
end
