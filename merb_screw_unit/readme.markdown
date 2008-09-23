# MerbScrewUnit

A slice for the Merb framework.

* * *

	merb_screw_unit
	|-- LICENSE
	|-- README
	|-- Rakefile [1]
	|-- TODO
	|-- app [2]
	|   |-- controllers
	|   |   |-- application.rb
	|   |   `-- main.rb
	|   |-- helpers
	|   |   `-- application_helper.rb
	|   `-- views
	|       |-- layout
	|       |   `-- merb_screw_unit.html.erb [3]
	|       `-- main
	|           `-- index.html.erb
	|-- lib
	|   |-- merb_screw_unit
	|   |   |-- merbtasks.rb [4]
	|   |   `-- slicetasks.rb [5]
	|   `-- merb_screw_unit.rb [6]
	|-- log
	|   `-- merb_test.log
	|-- public [7]
	|   |-- javascripts
	|   |   `-- master.js
	|   `-- stylesheets
	|       `-- master.css
	|-- spec [8]
	|   |-- merb_screw_unit_spec.rb
	|   |-- controllers
	|   |   `-- main_spec.rb
	|   `-- spec_helper.rb
	`-- stubs [9]
	    `-- app
	        `-- controllers
	            |-- application.rb
	            `-- main.rb


1. Rake tasks to package/install the gem - edit this to modify the manifest.
2. The slice application: controllers, models, helpers, views.
3. The default layout, as specified in Merb::Slices::config[:merb_screw_unit][:layout]
   change this to :application to use the app's layout.
4. Standard rake tasks available to your application.
5. Your custom application rake tasks.
6. The main slice file - contains all slice setup logic/config.
7. Public assets you (optionally) install using rake slices:merb\_screw\_unit:install
8. Specs for basis slice behaviour - you usually adapt these for your slice.
9. Stubs of classes/views/files for the end-user to override - usually these
   mimic the files in app/ and/or public/; use rake slices:merb\_screw\_unit:stubs to
   get started with the override stubs. Also, slices:merb\_screw\_unit:patch will
   copy over views to override in addition to the files found in /stubs.


To see all available tasks for MerbScrewUnit run:

	rake -T slices:merb_screw_unit

* * *

## Instructions for installation:

file: config/init.rb

### add the slice as a regular dependency


	dependency 'merb_screw_unit'


### if needed, configure which slices to load and in which order

	Merb::Plugins.config[:merb_slices] = { :queue => ["MerbScrewUnit", ...] }

### optionally configure the plugins in a before\_app\_loads callback

	Merb::BootLoader.before_app_loads do

	  Merb::Slices::config[:merb_screw_unit][:option] = value

	end

file: config/router.rb

### example: /merb\_screw\_unit/:controller/:action/:id

	r.add_slice(:MerbScrewUnit)

### example: /foo/:controller/:action/:id

	r.add_slice(:MerbScrewUnit, 'foo') # same as :path => 'foo'

### example: /:lang/:controller/:action/:id (with :a param set)

	r.add_slice(:MerbScrewUnit, :path => ':lang', :params => { :a => 'b' })

### example: /:controller/:action/:id

	r.slice(:MerbScrewUnit)

Normally you should also run the following rake task:

	rake slices:merb_screw_unit:install

* * *

## You can put your application-level overrides in:

host-app/slices/merb\_screw\_unit/app - controllers, models, views ...

### Templates are located in this order:

1. host-app/slices/merb\_screw\_unit/app/views/*
2. gems/merb\_screw\_unit/app/views/*
3. host-app/app/views/*

You can use the host application's layout by configuring the
merb\_screw\_unit slice in a before\_app\_loads block:

	Merb::Slices.config[:merb_screw_unit] = { :layout => :application }

By default :merb\_screw\_unit is used. If you need to override
stylesheets or javascripts, just specify your own files in your layout
instead/in addition to the ones supplied (if any) in
host-app/public/slices/merb\_screw\_unit.

In any case don't edit those files directly as they may be clobbered any time

	rake merb_screw_unit:install is run.

* * *

## About Slices

Merb-Slices is a Merb plugin for using and creating application 'slices' which
help you modularize your application. Usually these are reuseable extractions
from your main app. In effect, a Slice is just like a regular Merb MVC
application, both in functionality as well as in structure.

When you generate a Slice stub structure, a module is setup to serve as a
namespace for your controller, models, helpers etc. This ensures maximum
encapsulation. You could say a Slice is a mixture between a Merb plugin (a
Gem) and a Merb application, reaping the benefits of both.

A host application can 'mount' a Slice inside the router, which means you have
full over control how it integrates. By default a Slice's routes are prefixed
by its name (a router :namespace), but you can easily provide your own prefix
or leave it out, mounting it at the root of your url-schema. You can even
mount a Slice multiple times and give extra parameters to customize an
instance's behaviour.

A Slice's Application controller uses controller_for_slice to setup slice
specific behaviour, which mainly affects cascaded view handling. Additionaly,
this method is available to any kind of controller, so it can be used for
Merb Mailer too for example.

There are many ways which let you customize a Slice's functionality and
appearance without ever touching the Gem-level code itself. It's not only easy
to add template/layout overrides, you can also add/modify controllers, models
and other runtime code from within the host application.

To create your own Slice run this (somewhere outside of your merb app):

	$ merb-gen slice <your-lowercase-slice-name>