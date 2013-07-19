require 'direct_current/entry'
require 'direct_current/yamlizer'
require 'direct_current/view_helper'
require 'direct_current/static_finder'
module DirectCurrent
  class Railtie < ::Rails::Railtie
    config.after_initialize do
#    initializer "direct_current.view_helpers" do

      ActionView::Template.send :include, DirectCurrent::Yamlizer
      #ActionController::Base.send :helper, DirectCurrent::ViewHelper
      ActionController::Base.send :include, DirectCurrent::ViewHelper
      ActionController::Base.send :helper, DirectCurrent::ViewHelper

      ActionView::Base.send :include, DirectCurrent::ViewHelper
      #ActionView::Base.send :helper, DirectCurrent::ViewHelper

    end
  end
end