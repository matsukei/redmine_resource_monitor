class CreateMonitorResources < ActiveRecord::Migration
  def change
    create_table :monitor_resources do |t|
      t.integer :memory_total
      t.integer :memory_used
      t.float :cpu_used

      t.integer :logged_in_users
      t.float :last_load_average

      t.timestamps
    end
  end
end
