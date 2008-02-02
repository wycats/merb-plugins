class <%= class_name %> < DataMapper::Base
<% model_attributes.each do |attr| -%>
  <%= "property :#{attr.name}, :#{attr.type}" %>
<% end -%>
end