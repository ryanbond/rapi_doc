Rails API Doc Generator
=======================

RESTTful API generator...

It generates a set of HTML views in the public directory. Parses the desired controllers and generates appropriate views.

Currently does not read routes.rb and requires manual entry of routes

Installation
============

`gem install rapi_doc`

Usage
=====

Run `rake rapi_doc` to generate config and layout files. (TODO: Add a separate rake task to generate config files)

Modify config file by adding your controllers, e.g.:

`
users:
  location: "/users"
  controller_name: "users_controller.rb"
`

Then invoke the generation by calling:

`rake rapi_doc`

Documentation Example
---------------------

    =begin apidoc
    url:: /users
    method:: GET
    access:: FREE
    return:: [JSON|XML] - list of user objects
    param:: page:int - the page, default is 1
    param:: per_page:int - max items per page, default is 10
    
    Get a list of all users in the system with pagination.  Defaults to 10 per page
    =end
    
Layout
------

Documentation layout is located at `config/rapi_doc/layout.html.erb`.

Credit
======

* Based on RAPI Doc by Jaap van der Meer found here: http://code.google.com/p/rapidoc/
* https://github.com/sabman/rapi_doc