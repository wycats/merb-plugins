<% klass = class_name.singularize -%>
<% ivar = class_name.snake_case.singularize -%>
class <%= class_name %> < Application
  provides :xml, :js, :yaml
  
  def index
    @<%= ivar %>s = <%= klass %>.find(:all)
    render @<%= ivar %>s
  end
  
  def show
    @<%= ivar %> = <%= klass %>.find(params[:id])
    render @<%= ivar %>
  end
  
  def new
    only_provides :html
    @<%= ivar %> = <%= klass %>.new(params[:<%= ivar %>])
    render
  end
  
  def create
    @<%= ivar %> = <%= klass %>.new(params[:<%= ivar %>])
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
  
  def update
    @<%= ivar %> = <%= klass %>.find(params[:id])
    if @<%= ivar %>.update_attributes(params[:<%= ivar %>])
      redirect url(:<%= ivar %>, @<%= ivar %>)
    else
      raise BadRequest
    end
  end
  
  def destroy
    @<%= ivar %> = <%= klass %>.find(params[:id])
    if @<%= ivar %>.destroy
      redirect url(:<%= ivar %>s)
    else
      raise BadRequest
    end
  end
end