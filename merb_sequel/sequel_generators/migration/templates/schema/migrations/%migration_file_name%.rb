# For details on Sequel migrations see 
# http://sequel.rubyforge.org/
# http://code.google.com/p/ruby-sequel/wiki/Migrations

class <%= model_class_name %>Migration < Sequel::Migration

  def up
    <%= "create_table :#{table_name} do" if table_name %>
<% if model_attributes.empty? -%>
      primary_key :id
<% else -%>
<% model_attributes.each do |attribute| -%>
      <%= attribute.last %> :<%= attribute.first %>
<% end -%>
<% end -%>
    <%= "end" if table_name %>
  end

  def down
<% if table_name -%>
    execute "DROP TABLE <%= table_name %>"
<% end -%>
  end

end
