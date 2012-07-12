class AddPasswordHashFunctionAndPasswordHashWorkLoadToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.column :password_hash_function,  :string
      t.column :password_hash_work_load, :int
    end
  end

  def self.down
    change_table(:users) do |t|
      t.remove :password_hash_function
      t.remove :password_hash_work_load
    end
  end
end
