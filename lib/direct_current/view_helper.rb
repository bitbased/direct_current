module DirectCurrent
  module ViewHelper
  
  def set_default_path(path_id)
    @default_path = path_id
  end

  def default_path=(path_id)
    set_default_path(path_id)
  end

  def default_path
    @default_path ||= nil
  end

  def entries(path = nil, include_self = false, &block_argument)
    if block_argument # block is given
      entries(path, include_self).each do |p|
        block_argument.call(p) # use call to execute the block
      end
    else
      if path.nil?
        page_finder.list(include_self)
      else
        page_finder_factory.new(path).list(include_self)
      end
    end
  end

  def image(src = nil, options = {}, &block_argument)
    density = 1
    density ||= options[:density]

    width ||= options[:width]
    height ||= options[:height]

    #w = width * density
    #h = height * density

    if block_argument # block is given
      block_argument.call(OpenStruct.new({url: src, title: src, src: src,width: options[:width],height: options[:height]})) # use call to execute the block
    else
      "<img src=\"#{src}\" width=\"#{width.to_s}\" height=\"#{height.to_s}\">".html_safe
    end
  end

  def current?(path = nil, options = {})
    params[:path_id] ||= default_path
    path = @active_path if path == nil
    if path.is_a? Array
      path.each do |item|
        return true if params[:path_id] == item.gsub(/^\//,"")
      end
      return false
    end
    return params[:path_id] == path.gsub(/^\//,"")
  end
  def parent?(path = nil, options = {})
    params[:path_id] ||= default_path
    path = @active_path if path == nil
    if path.is_a? Array
      path.each do |item|
        return true if params[:path_id] != path && params[:path_id].start_with?(item.gsub(/^\//,""))
      end
      return false
    end
    if options[:include_root]
      return params[:path_id] != path && params[:path_id].start_with?(path.gsub(/^\//,""))
    else
      return params[:path_id] != path && params[:path_id].start_with?(path.gsub(/^\//,"")) && path.to_s != nil.to_s
    end

  end


  def nav_classes(path = nil, options = {})
    tmp_path = @active_path
    @active_path = path if path != nil
    classes = []
    classes << "parent" if parent?
    classes << "current" if current?
    @active_path = tmp_path
    return classes.join(" ")
  end

  def nav(path = nil, options = {}, &block_argument)
    path = entries("/", true) if path.to_s == "root" || path == nil
    if path.is_a?(Hash) || path.is_a?(OpenStruct)
      path = [path] 
      options[:levels]   ||= 2
    end
    path = entries(path) unless path.is_a? Array
    if block_argument # block is given
      path.each do |p|
        tmp_path = @active_path
        @active_path = p[:path]
        block_argument.call(p) # use call to execute the block
        @active_path = tmp_path
      end
    else # the value of block_argument becomes nil if you didn't give a block
      options[:levels]   ||= 1
      options[:level]    ||= 1
      options[:exclude]  ||= []
      #options[:field]    ||= :title
      options[:exclude] = [options[:exclude].url] if options[:exclude].is_a? Hash
      options[:exclude]    = [options[:exclude]] if options[:exclude] && !options[:exclude].is_a?(Array)

      if options[:class].is_a?(Array)
        ss = "<ul#{ " class=\"" + options[:class].join(" ") + "\"" if options[:class] }>"
      elsif options[:class].is_a?(Hash)
        
        if options[:class][options[:level]]
          if options[:class][options[:level]].is_a?(Array)
            ss = "<ul#{ " class=\"" + options[:class][options[:level]].join(" ") + "\"" if options[:class][options[:level]] }>"
          else
            ss = "<ul#{ " class=\"" + options[:class][options[:level]].to_s + "\"" if options[:class][options[:level]] }>"
          end
        else
          ss = "<ul>"
        end
      else
        ss = "<ul#{ " class=\"" + options[:class].to_s + "\"" if options[:class] }>"
      end
      
      return "" if path.length == 0

      path.each do |p|
        tmp_path = @active_path
        @active_path = p[:path]
        @active_path = [@active_path, p[:_redirect]] if p[:_redirect]

        if p[:_descendants]
          @active_path = [@active_path] if !@active_path.is_a?(Array)
          @active_path += p[:_descendants]
        end

        title = p.send(options[:field].to_sym) if options[:field]
        title ||= p[:nav_title]
        title ||= p[:title]
        title ||= p[:slug]
        next if p.status.to_s != "live"
        next if options[:exclude].include? p.url
        url = p._redirect
        url ||= p.url
        classes = nav_classes
        ss += "<li#{(" class=\"" + classes + "\"") if classes != ""}><a href=\"#{url}\">#{title}</a>"
        begin
          opt = options.clone
          opt[:class]   = nil unless opt[:class].is_a?(Hash)
          opt[:self]    = false
          opt[:levels] -= 1
          opt[:level]   = options[:level] + 1
          if p.path != "" && p.status.to_s == "live"
            ss += nav(p.path, opt) if opt[:levels] > 0
          end
        rescue
        end
        ss += "</li>" # use call to execute the block
        @active_path = tmp_path
      end
      ss += "</ul>"

      ss.html_safe
    
    end
  end

  def breadcrumbs(path = nil, options = {}, &block_argument)
    #path = entries(path) unless path.is_a? Array
    if block_argument # block is given
      path.each do |p|
        tmp_path = @active_path
        @active_path = p[:path]
        block_argument.call(p) # use call to execute the block
        @active_path = tmp_path
      end
    else # the value of block_argument becomes nil if you didn't give a block
      options[:levels]   ||= 1
      options[:level]    ||= 1
      options[:exclude]  ||= []
      options[:include_self]  ||= true if options[:include_self] != false
      #options[:field]    ||= :title
      options[:exclude]    = [options[:exclude]] if options[:exclude] && !options[:exclude].is_a?(Array)

      if options[:class].is_a?(Array)
        ss = "<ul#{ " class=\"" + options[:class].join(" ") + "\"" if options[:class] }>"
      elsif options[:class].is_a?(Hash)
        
        if options[:class][options[:level]]
          if options[:class][options[:level]].is_a?(Array)
            ss = "<ul#{ " class=\"" + options[:class][options[:level]].join(" ") + "\"" if options[:class][options[:level]] }>"
          else
            ss = "<ul#{ " class=\"" + options[:class][options[:level]].to_s + "\"" if options[:class][options[:level]] }>"
          end
        else
          ss = "<ul>"
        end
      else
        ss = "<ul#{ " class=\"" + options[:class].to_s + "\"" if options[:class] }>"
      end

      pp = path
      last = false
      first = true
      current = true
      lis = []
      while pp do
        p = pp

        tmp_path = @active_path
        @active_path = p[:path]

        title = p.send(options[:field].to_sym) if options[:field]
        title ||= p.nav_title
        title ||= p.title
        title ||= p.slug

        if !current || options[:include_self] != false
          classes = []
          #classes << options[:include_self]
          classes << "current" if current?
          classes << "parent" if parent?(nil, include_root: true)
          classes << "first" if first
          first = false
          classes << "inactive" if p._sub || p._redirect

          sst = "<li data-page-path=\"#{p.url}\" class=\"#{classes.join(" ")}\"><a href=\"#{p.url}\">#{title}</a>"
          begin
            opt = options.clone
            opt[:class]   = nil unless opt[:class].is_a?(Hash)
            opt[:self]    = false
            opt[:levels] -= 1
            opt[:level]   = options[:level] + 1
            if p.path != ""
              sst += nav(p.path, opt) if opt[:levels] > 0
            end
          rescue
          end
          sst += "</li>" # use call to execute the block
          lis << sst
        end
        begin
          pp = pp.parent
        rescue
          pp = nil
        end
        current = false
        pp = nil if last
        last = true if pp && pp.path == ""
        @active_path = tmp_path
      end


      ss += lis.reverse.join + "</ul>"

      ss.html_safe
    
    end
  end

  def current_page
    page_finder.find
  end

  def page_finder
    params[:path_id] ||= default_path
    page_finder_factory.new(params[:path_id])
  end

  def page_finder_factory
    params[:path_id] ||= default_path
    params[:path_id] = "" if params[:path_id] == nil
    DirectCurrent::StaticFinder
  end

  def find_default(parameter, options = {})
    d = nil

    @page = page_finder.get
    stack = @page
    while(stack)
      if(stack["default_#{parameter.to_s}".to_sym])
        d = stack["default_#{parameter.to_s}".to_sym]
        break
      end
      stack = stack.parent
    end
    if @page[parameter] != nil
      return @page[parameter]
    end
    return d
  end

  def layout_for_page
    layout = "application"
    @page = page_finder.get
    stack = @page
    while(stack)
      if(stack[:default_layout])
        layout = stack[:default_layout]
        break
      end
      stack = stack.parent
    end
    if @page[:layout] != nil
      return @page[:layout]
    end
    return layout
  end

  protected
  def _prefixes
    @_prefixes_with_partials ||= super | %w(partials layouts)
  end

end
end