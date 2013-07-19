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

Use a yaml for page attributes and settings
contact.html.erb
   ---
   title: Contact Us
   meta_title: Contact Our Team
   contact:
     email: info@bitbased.net
   ---
   <% image_tag "map.png", :class => "map_image" %>
   <h1><%= @page.title %></h1>
   <p>
     Contact us by email or phone<br>
     Email: <%= mail_to @page.contact.email %>
   </p>

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
  <body>
    <header>
      <nav>
        <% nav :root # creates ul/li with 'parent' and 'current' classes for styling navigation state from the :root %>
      </nav>
      <% yield :header_content %>
    </header>
    <% yield %>
  </body>
</html>
```

Got it?

## Routes

# ROUTES SECTION INCOMPLETE

## Credits

## License

Direct Current is Copyright © 2013 bitbased.net. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.