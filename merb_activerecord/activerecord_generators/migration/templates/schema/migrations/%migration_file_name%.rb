class <%= model_class_name %>Migration < ActiveRecord::Migration
  def self.up
    <%= "create_table :#{table_name} do |t|" if table_name %>
<% for attribute in model_attributes -%>
      t.<%= "%-11s" % attribute.last %> :<%= attribute.first %> 
<% end -%>

      t.timestamps
    <%= "end" if table_name %> 
  end

  def self.down
<% if table_name -%>
    drop_table :<%= table_name %>
<% end -%>
  end
end
