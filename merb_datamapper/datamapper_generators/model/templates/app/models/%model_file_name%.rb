class <%= model_class_name %> < DataMapper::Base
<% model_attributes.each do |attr| -%>
  <%= "property :#{attr.first}, :#{attr.last}" %>
<% end -%>
end