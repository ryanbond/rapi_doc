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

    users:
      location: "/users"
      controller_name: "users_controller.rb"

Then invoke the generation by calling:

`rake rapi_doc`

Documentation Example
---------------------

    # =begin apidoc
    # url:: /books
    # method:: GET
    # access:: FREE
    # return:: [JSON|XML] - list of book objects
    # param:: page:int - the page, default is 1
    # param:: per_page:int - max items per page, default is 10
    #
    # output:: json
    # [
    #   { "created_at":"2011-12-05T09:46:11Z",
    #     "description":"dudul description",
    #     "id":1,
    #     "price":19,
    #     "title":"dudul biography",
    #     "updated_at":"2011-12-05T09:46:11Z" },
    # ]
    # ::output-end::
    #
    # output:: xml
    # <books type="array">
    #   <book>
    #     <id type="integer">1</id>
    #     <title>dudul biography</title>
    #     <description>dudul description</description>
    #     <price type="integer">19</price>
    #     <created-at type="datetime">2011-12-05T09:46:11Z</created-at>
    #     <updated-at type="datetime">2011-12-05T09:46:11Z</updated-at>
    #   </book>
    # </books>
    #::output-end::
    #
    # Get a list of all users in the system with pagination.  Defaults to 10 per page
    =end

    
Layout
------

Documentation layout is located at `config/rapi_doc/layout.html.erb`.

Credit
======

* Based on RAPI Doc by Jaap van der Meer found here: http://code.google.com/p/rapidoc/
* https://github.com/sabman/rapi_doc