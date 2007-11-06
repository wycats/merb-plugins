<% klass = class_name.singularize -%>
<% ivar = class_name.snake_case.singularize -%>
class <%= class_name %> < Application
  provides :xml, :js, :yaml
  
  def index
    @<%= ivar %>s = <%= klass %>.all
    render @<%= ivar %>s
  end
  
  def show(id)
    @<%= ivar %> = <%= klass %>[id]
    render @<%= ivar %>
  end
  
  def new(<%= ivar %>)
    only_provides :html
    @<%= ivar %> = <%= klass %>.new(<%= ivar %>)
    render @<%= ivar %>
  end
  
  def create(<%= ivar %>)
    @<%= ivar %> = <%= klass %>.new()
    if @<%= ivar %>.save
      redirect url(:<%= ivar %>, @<%= ivar %>)
    else
      render :action => :new
    end
  end
  
  def edit
    only_provides :html
    @<%= ivar %> = <%= klass %>.find(params[:id])
    render
  end
  
  def update(id, <%= ivar %>)
    @<%= ivar %> = <%= klass %>[id]
    if @<%= ivar %>.update_attributes(<%= ivar %>)
      redirect url(:<%= ivar %>, @<%= ivar %>)
    else
      raise BadRequest
    end
  end
  
  def destroy(id)
    @<%= ivar %> = <%= klass %>[id]
    if @<%= ivar %>.destroy!
      redirect url(:<%= ivar %>s)
    else
      raise BadRequest
    end
  end
end