class CreateMonitorProcesses < ActiveRecord::Migration
  def change
    create_table :monitor_processes do |t|
      t.belongs_to :monitor_resource

      t.float :cpu
      t.integer :memory
      t.integer :count
      t.text :command

      t.timestamps
    end

    add_index :monitor_processes, :monitor_resource_id
  end
end
