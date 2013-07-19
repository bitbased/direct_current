# Direct Current

Rails engine for static content.

Fully charged content.

Built on [thoughtbot, inc's](http://thoughtbot.com/community) excellent [High Voltage](https://github.com/thoughtbot/high_voltage) static pages gem. Inspired by [Statamic](http://statamic.com/) an excellent, altho not free, fully formed php based static content CMS.

## Static content? Dynamic content?

Complex Home Page Content, About/History, Information Pages, Marketing Pages, etc. You can render dynamic partials within static content or use custom controllers and actions for subsets of static content, or use content as a normal Rails view for any action.

## Installation

Include in your Gemfile:

```ruby
gem 'direct_current', :github => "bitbased/direct_current"
```

## Usage

Write your static content pages and put them in the RAILS_ROOT/app/views/pages directory.

    $ mkdir app/views/pages
    $ touch app/views/pages/index.haml # using haml
    $ touch app/views/pages/contact.html.erb
    $ touch app/views/pages/about.md # using a markdown gem

You can nest pages in a directory structure, and include index.* pages for sub directories.

Use a --- yaml --- block for page attributes and settings
contact.html.erb
```erb
---
title: Contact Us
meta_title: Contact Our Team
layout: layout # set a custom layout
contact:
  email: info@bitbased.net
---
<% content_for :header_area %>
  <%= image_tag "map.png", :class => "map_image" %>
<% end %>
<h1><%= @page.title %></h1>
<p>
  Contact us by email or phone<br>
  Email: <%= mail_to @page.contact.email %>
</p>
```
After setting up some pages you can create simple navigation from a layout in your app or any content page with:

```ruby
nav "folder/path"
```

```ruby
breadcrumbs # yes, that just happened!
```

layout.erb:
```erb
<html>
  <head>
    <meta name="title" content="<%= @page.meta_title || @page.title || "" # No Way!!!, Yep =) %>">
  </head>
  <body>
    <header>
      <nav>
        <%= nav :root # creates ul/li with 'parent' and 'current' classes for styling navigation state from the :root %>
      </nav>
      <%= yield :header_area %>
    </header>
    <%= yield %>
  </body>
</html>
```

Got it?

## Content Paths
prefix pages/paths with number for sorting, prefix with date for sorting and access to @page.date, use index.* pages in folders like you would with static html

numbers and dates are ignored in final urls and any listing parameters:
```
/pages/01-index.html
/pages/02-about/
/pages/02-about/index.html
/pages/02-about/history.html
/pages/02-about/_people.html # _ hides page from nav helper or listings
/pages/03-blog
/pages/03-blog/index.html
/pages/03-blog/2013-7-19-initial-commit-post.md
/pages/03-contact.html

## Caveats and Funky Stuff

Pollutes all your views and controllers with a few helpers, views get exciting method_missing handling for ceartain types of hashes

[Entry.rb](https://github.com/bitbased/direct_current/blob/master/lib/direct_current/entry.rb) does some weird junk by making an automatic OpenStuct-ish object of child objects to help make the view dsl more elegant

Ruby blocks can be used on arrays and hashes without .each in views also to help the dsl and object keys become locals inside blocks.

```erb
<% dictionary = [ {term: "Coffee", definition: "Black hot drink"} ]
<dl>
  <% dictionary do %>
    <dt><%= term # object keys become first class citizens in a block %></dt>
      <dd><%= definition %></dd>
  <% end %>
</dl>
```

## Routes

# ROUTES SECTION INCOMPLETE

For now you will need to create a custom controller:
app/controllers/content_controller.rb
```ruby
class ContentController < ApplicationController
  
  layout :layout_for_page

  def show
    @page = page_finder.get

    if @page._redirect
      redirect_to ("/" + @page._redirect).gsub(/^\/\//,"/")
    else
      render :template => current_page
    end
  end

  def contact
    params[:path_id] = "information/contact"
  end

end
```

And 2 custom routes
config/routes.rb
```
  # possible contact form usage
  get "/contact" => 'contact_form#new', :path_id => "contact"
  post "/contact" => 'contact_form#create', :path_id => "contact"

  # simple content usage
  get "/*path_id" => 'content#show' # put this after any pages
  root :to => 'content#show', :path_id => "" # root to /pages/index.*
```

## Credits

## License

Direct Current is Copyright © 2013 bitbased.net. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.