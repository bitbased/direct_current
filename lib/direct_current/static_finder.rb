module DirectCurrent
  class StaticFinder < HighVoltage::PageFinder

    @@depth = 0

    def regex_all
      /\.haml$|\.erb$|\.html|\.html\.erb$|\.md$|\.md\.erb$|\.html\.md\.erb$/
    end
    def regex_index
      /index\./i
    end
    def regex_hidden
      /\.config$/i
    end
    def regex_slug
      /^_[0-9][0-9]?[0-9]?-|^_[0-9][0-9][0-9][0-9]-[0-9][0-9]?-[0-9][0-9]?-|^[0-9][0-9]?[0-9]?-|^[0-9][0-9][0-9][0-9]-[0-9][0-9]?-[0-9][0-9]?-|^_/
    end

    def content_path
      HighVoltage.content_path
    end
    def content_root
      @@c_root ||= Rails.root.join("app","views",content_path)
    end
    
    #def list2
    #  directory = File.join(content_root,@page_id.gsub(/^\//,""))
    #  if Dir.glob(File.join(directory, "*")).grep(/index\./i).grep(regex_all).length > 0
    #    puts "INDEX"
    #  end
    #end

    def get_pages(page_path, include_self = false)

      #page = get_page(page_path)

      #return page.children + page if include_self
      #return page.children

      page_name = Pathname.new(page_path).basename.to_s

      #parent = parent_path(page_path)
      #parent = "" if page_path == ""
      paths = []
      
      list_names(page_path).each do |name|
        if name !~ regex_index && name !~ regex_hidden
          paths << File.join(page_path, name)
        end
      end

      if include_self
        page = get_page(page_path)
        paths = [page.path] + paths# [get_page(page_path)] + paths
      end

      pages = []
      paths.each do |p|
        p = p.gsub(regex_all,"")
        page = get_page(p)
        if page
          if page._sub
            page.title = p.to_s.split("/")[-1].titleize
            page.path = p
            pages << page
          else
            pages << page
          end
        end
      end

      return pages

    end

    def list(include_self = false)
      page_path = @page_id.gsub(/^\//,"")
      return get_pages(page_path,include_self)
    end

    def get
      return get_page(@page_id)
    end

    def get_page(page_path)
      @@depth += 1

      @@page_cache ||= {}
      return @@page_cache[page_path] if @@page_cache[page_path]

      page_path = page_path.gsub(/^\//,"")
      site_root = false

      if page_path == "../"
        page_path = ""
        site_root = true
      end
      if page_path.start_with?(".")
        return {title: "", children: [], siblings: [], :parent => nil}
      end

      page_name = Pathname.new(page_path).basename.to_s

      parent = parent_path(page_path)
      
      path = nil
      index = false
      sub = false
      if list_names(page_path).grep(regex_index).grep(regex_all).length > 0
        index = true
        path = File.join(page_path,list_names(page_path).grep(regex_index).grep(regex_all).first)
      else
        list_names(parent).each do |name|
          if !path_directory?(File.join(parent, name)) && name.gsub(regex_all,"") == page_name || name.gsub(regex_all,"").gsub(regex_slug,"") == page_name
            if path_directory?(File.join(parent, name))
              sub = true
            end
            path = File.join(parent, name)
          end
        end
      end

      if path == nil
        list_names(page_path).each do |name|
          if !path_directory?(File.join(page_path, name))
            path = File.join(page_path, name)
            break
          end
        end
      end

      if path_directory?(path)
        list_names(path).each do |name|
          if !path_directory?(File.join(path, name))
            path = File.join(path, name)
            break
          end
        end
      end
      
      title_ov = nil
      loop_count = 0
      while path_directory?(path)
        loop_count += 1
        return nil if loop_count>5

        list_names(path).each do |name|
          if path_directory?(File.join(path, name))
            path = File.join(path, name)
            break
          end
        end

        if path_directory?(path)
          if list_names(path).grep(regex_index).grep(regex_all).length > 0
            index = true
            path = File.join(path,list_names(path).grep(regex_index).grep(regex_all).first)
          else
            list_names(path).each do |name|
              if !path_directory?(File.join(path, name))
                path = File.join(path, name)
                break
              end
            end
          end

        end
      end

      yaml = ""
      dir = false
      dir_page = false
      
      if File.exists? get_file(path)
        template = File.read(get_file(path))

        min = -1
        first = true
        last = false
        template.lines.each do |line|
          line = line.gsub("\r","").gsub("\n","")
          break if first && line != "---"
          if first && line == "---"
            first = false
            next
          end
          if line != "---"
            yaml += line+"\r\n"
          else
            last = true
            break
          end
          
        end
        if last == false
          yaml = ""
        end
      end

      h = YAML.load(yaml)
      h ||= {}
      h = HashWithIndifferentAccess.new(h)
      
      h[:title] = title_ov if title_ov

      exact_path = exact_path(path)
      fname = nil
      raw_slug = nil
      if dir
        fname = path.to_s.split("/")[-1].gsub(/\..*/,"")
        raw_slug = exact_path.to_s.split("/")[-1].gsub(/\..*/,"")
        slug = path.to_s.split("/")[-1].gsub(/\..*/,"").gsub(regex_slug,"")
        h[:path] = File.join(path,slug).gsub(/^\//,"")
      elsif index
        slug = path.to_s.split("/").last(2).first
        fname = slug.to_s.gsub(regex_all,"")
        raw_slug = exact_path.to_s.split("/").last(2).first.to_s.gsub(regex_all,"")
        slug = slug.to_s.gsub(regex_all,"").gsub(regex_slug,"")
        h[:path] = File.join(parent_path(parent_path(path)),slug).gsub(/^\//,"")
        if(page_path == "")
          slug = "index"
          raw_slug = "index"
          h[:path] = ""
        end
      else
        slug = path.to_s.split("/").last
        fname = slug.to_s.gsub(regex_all,"")
        raw_slug = exact_path.to_s.split("/").last.gsub(regex_all,"")
        slug = slug.to_s.gsub(regex_all,"").gsub(regex_slug,"")
        h[:path] = File.join(parent_path(path),slug).gsub(/^\//,"")
      end

      url = h[:path]
      if url == "index"
        url = ""
      end
      h[:url] = "/" + url

      if page_path != url #&& "redirect_to_smart_url"
        h[:_redirect] = "/" + url
      end

      if (dir && !dir_page) || sub
        h[:_redirect] = "/" + url
        h[:title] ||= page_path.split("/").last.titleize
      end

      h[:_sub] = sub
      extra = fname.gsub(fname.gsub(regex_slug,""),"").gsub(/-$/,"")
      if extra.length > 3
        h[:date] ||= DateTime.parse(extra,"yyyy-mm-dd") rescue nil
      else
        h[:date] = nil
      end
      if extra == ""
        h[:id] = slug.gsub(/^_/,"")
        h[:status] ||= :hidden if raw_slug.start_with?("_")
      else
        h[:id] = extra.gsub(/^_/,"")
        h[:status] ||= :hidden if extra.start_with?("_")
      end

      h[:status] ||= :live

      h[:last_modified] ||= DateTime.parse(File.mtime(get_file(path)).to_s)

      h[:slug] = slug
      title ||= slug.titleize
      h[:title] ||= title
      h[:exact_path] = exact_path.gsub(regex_all,"")

      h[:site_root] = site_root
      h[:site_root] ||= page_path == ""
      h[:page_path] = page_path
      path = page_path
      
      h = DirectCurrent::Entry.new h
      h.static_finder = self

      @@page_cache[page_path] ||= h
    end


    def path_exists(path)
      File.exists? get_file(path)
    end
    def path_directory?(path)
      File.directory? get_file(path)
    end
    def path_file?(path)
      File.file? get_file(path)
    end
    def list_names(path, filter = "*")
      @@names_cache = {}

      @@names_cache[path + "%" + filter] ||= Dir.glob(File.join(get_file(path), filter)).map { |ff|
        Pathname.new(ff).basename.to_s
      }.sort
    end
    def parent_path(path)
      path = "/" if path == ""
      return value = "../" if path == "/"
      File.expand_path("..","/"+path).gsub(/^\//,"")
    end
    def exact_path(path)
      @@exact_path_cache ||= {}
      return @@exact_path_cache[path] if @@exact_path_cache[path]
      #@@depth += 1
      #dp = @@depth
      #puts "=>#{' ' * dp * 2}exact_path(\"#{path}\")"
      if File.exists? File.join(content_root,path)
        #puts "#{' ' * dp * 2}  return[:exact_path] \"#{path}\""
        return path
      end

      exact_path = ""
      path.split("/").each do |part|
        build = exact_path
        build += "/" + part
        if File.exists? File.join(content_root,build)
          exact_path = build
        else
          piece = nil
          # list_names(exact_path, "*#{part}*").each do |name|
          #puts "#{' ' * dp * 2}  part: \"#{part}\""
          list_names(exact_path).each do |name|
            next if !name.include? part
            if name.gsub(regex_slug,"").gsub(regex_all,"") == part.gsub(regex_slug,"").gsub(regex_all,"")
              piece = name.gsub(regex_all,"")
              break
            end
          end
          if piece
            exact_path += "/" + piece
          else
            #puts "#{' ' * dp * 2}  throw Exception '#{exact_path}'/'#{part}':#{list_names(exact_path,"*" + part + "*")}"
            throw "path does not exist #{path}"
          end
        end
      end

      #puts "#{' ' * dp * 2}  return[:exact_path] \"#{exact_path.gsub(/^\//,"")}\""    
      
       @@exact_path_cache[path] ||= exact_path.gsub(/^\//,"")
    #ensure
      #@@depth -= 1
    end
    def get_file(path)
      @@file_cache ||= {}
      begin
        return @@file_cache[path] if @@file_cache[path]
        @@file_cache[path] ||= File.join(content_root,exact_path(path))
      rescue
        nil
      end
    end


    def find
      page_path = super.to_s.gsub(content_path,"").gsub(/^\//,"")
      page_name = Pathname.new(page_path).basename.to_s

      parent = parent_path(page_path)
      path = nil
      if list_names(page_path).grep(regex_index).grep(regex_all).length > 0
        path = File.join(page_path,list_names(page_path).grep(regex_index).grep(regex_all).first)
      else
        list_names(parent).each do |name|
          if !path_directory?(File.join(parent, name)) && name.gsub(regex_all,"") == page_name || name.gsub(regex_all,"").gsub(regex_slug,"") == page_name
            path = File.join(parent, name)
          end
        end
      end

      if path == nil || path_directory?(path)
        list_names(page_path).each do |name|
          if !path_directory?(File.join(page_path, name))
            path = File.join(page_path, name)
            break
          end
        end
      end

      return nil if !File.exists?(File.join(content_root,exact_path(path)))
      return File.join(content_path,exact_path(path))
    end
  end
end