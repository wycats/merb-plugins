class <%= model_class_name %>Migration < ActiveRecord::Migration
  def self.up
    <%= "create_table :#{table_name} do |t|" if table_name %>
<% for attribute in model_attributes -%>
      t.column :<%= attribute.first %>, :<%= attribute.last %> 
<% end -%>
    <%= "end" if table_name %>    
  end

  def self.down
<% if table_name -%>
    drop_table :<%= table_name %>
<% end -%>
  end
end
