class AddShortcutToTimeTable < ActiveRecord::Migration
  def change
    add_column "time_tables", "start_date", "date"
    add_column "time_tables", "end_date", "date"
  end
end
