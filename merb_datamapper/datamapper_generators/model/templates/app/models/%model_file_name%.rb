class <%= model_class_name %>
  include DataMapper::Persistable
  
<% model_attributes.each do |attr| -%>
  <%= "property :#{attr.first}, :#{attr.last}" %>
<% end -%>
end