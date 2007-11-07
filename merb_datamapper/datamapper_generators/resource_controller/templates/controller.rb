<% klass = class_name.singularize -%>
<% ivar = class_name.snake_case.singularize -%>
class <%= class_name.pluralize %> < Application
  provides :xml, :js, :yaml
  
  def index
    @<%= ivar.pluralize %> = <%= klass %>.all
    render @<%= ivar.pluralize %>
  end
  
  def show(id)
    @<%= ivar %> = <%= klass %>[id]
    raise BadRequest unless @<%= ivar %>
    render @<%= ivar %>
  end
  
  def new
    only_provides :html
    @<%= ivar %> = <%= klass %>.new
    render @<%= ivar %>
  end
  
  def create(<%= ivar %>)
    @<%= ivar %> = <%= klass %>.new(<%= ivar %>)
    if @<%= ivar %>.save
      redirect url(:<%= ivar %>, @<%= ivar %>)
    else
      render :action => :new
    end
  end
  
  def edit(id)
    only_provides :html
    @<%= ivar %> = <%= klass %>[id]
    raise BadRequest unless @<%= ivar %>
    render
  end
  
  def update(id, <%= ivar %>)
    @<%= ivar %> = <%= klass %>[id]
    raise BadRequest unless @<%= ivar %>
    if @<%= ivar %>.update_attributes(<%= ivar %>)
      redirect url(:<%= ivar %>, @<%= ivar %>)
    else
      raise BadRequest
    end
  end
  
  def destroy(id)
    @<%= ivar %> = <%= klass %>[id]
    raise BadRequest unless @<%= ivar %>
    if @<%= ivar %>.destroy!
      redirect url(:<%= ivar.pluralize %>)
    else
      raise BadRequest
    end
  end
end