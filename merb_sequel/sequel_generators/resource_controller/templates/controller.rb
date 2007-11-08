<% klass = class_name.singularize -%>
<% ivar = class_name.snake_case.singularize -%>
class <%= class_name %> < Application
  provides :xml, :js, :yaml
  
  def index
    @<%= ivar.pluralize %> = <%= klass %>.all
    render @<%= ivar.pluralize %>
  end
  
  def show
    @<%= ivar %> = <%= klass %>[:id => params[:id]]
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
    @<%= ivar %> = <%= klass %>[:id => params[:id]]
    render
  end
  
  def update
    @<%= ivar %> = <%= klass %>[:id => params[:id]]
    if @<%= ivar %>.update(params[:<%= ivar %>])
      redirect url(:<%= ivar %>, @<%= ivar %>)
    else
      raise BadRequest
    end
  end
  
  def destroy
    @<%= ivar %> = <%= klass %>[:id => params[:id]]
    if @<%= ivar %>.destroy
      redirect url(:<%= ivar %>s)
    else
      raise BadRequest
    end
  end
end