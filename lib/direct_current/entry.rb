
module DirectCurrent
  class Entry
    attr_accessor :static_finder

    def initialize(*args)
      @source = OpenStruct.new *args
    end

    @@active_blocks = {}
    def self.active_block(id)
      @@active_blocks[id]
    end

    def keys
      to_h.keys
    end

    def [](val)
      value = @source.send(val)
      value = Entry.new(value) if value.is_a? Hash
      return value
    end

    def to_h
      if @source.respond_to? :to_h
        HashWithIndifferentAccess.new(@source.to_h)
      else
        HashWithIndifferentAccess.new(@source.marshal_dump)
      end
    end

    def method_missing(method, *args, &block)

      if block

        value = @source.send(method, *args)
        r = SecureRandom.random_number(10000)

        if value.is_a? Array
          if block.arity > 0
            if block.arity == 1
              eval "alias :method_missing_hold_#{r} :method_missing", block.binding
              value.each do |item|
                item = Entry.new(item) if item.is_a?(Hash) || items.is_a?(OpenStruct)
                @@active_blocks[r] = {value: item, parent: self}
                item.parent = item
                #eval "def method_missing(method,*args,&block);if method.to_sym == \"#{block.parameters[0][1].to_s}\".to_sym;#{block.parameters[0][1].to_s}.method_missing(method,*args,&block);elsif method.to_sym == :parent;HighVoltage::DirectCurrent::Entry.active_block(#{r})[:parent];else;method_missing_hold_#{r}(method,*args,&block);end;end", block.binding
                block.call(item)
              end
              eval "alias :method_missing :method_missing_hold_#{r}", block.binding
              @@active_blocks.except!(r)
            else
              value.each do |item|
                item = Entry.new(item) if item.is_a?(Hash)
                block.call *block.parameters.map { |p| v = item.send(p[1]); v = Entry.new(item) if item.is_a?(Hash);v }
              end
            end
            return
          end

          # block nesting recursion via method chaining, excellent!!!
          eval "alias :method_missing_hold_#{r} :method_missing", block.binding
          value.each do |item|
            if item.is_a?(Hash) || items.is_a?(OpenStruct)
              item = Entry.new(item)
              item.parent = self
              item.children = item
            end
            if item.is_a?(Entry)
              @@active_blocks[r] = item
              eval "def method_missing(method,*args,&block); DirectCurrent::Entry.active_block(#{r}).method_missing(method,*args,&block);end", block.binding
              block.call
            else
              @@active_blocks[r] = {value: item, parent: self}
              eval "def method_missing(method,*args,&block);if [:name,:title,:value,:item].include?(method.to_sym);DirectCurrent::Entry.active_block(#{r})[:value];elsif method.to_sym == :parent;DirectCurrent::Entry.active_block(#{r})[:parent];else;method_missing_hold_#{r}(method,*args,&block);end;end", block.binding
              block.call
            end
          end
          eval "alias :method_missing :method_missing_hold_#{r}", block.binding
          @@active_blocks.except!(r)
          return
        end

        # if the block is for a hash/object just enable access to the keys, no loop
        # this should be dried up by taking this into a function and also calling it from the loop
        eval "alias :method_missing_hold_#{r} :method_missing", block.binding
        item = value
        if item.is_a?(Hash) || items.is_a?(OpenStruct)
          item = Entry.new(item)
          item.parent = self
          item.children = item
        end
        if item.is_a?(Entry)
          @@active_blocks[r] = item
          eval "def method_missing(method,*args,&block); DirectCurrent::Entry.active_block(#{r}).method_missing(method,*args,&block);end", block.binding
          block.call.to_s
        else
          @@active_blocks[r] = {value: item, parent: self}
          eval "def method_missing(method,*args,&block);if [:name,:title,:value,:item].include?(method.to_sym);DirectCurrent::Entry.active_block(#{r})[:value];elsif method.to_sym == :parent;DirectCurrent::Entry.active_block(#{r})[:parent];else;method_missing_hold_#{r}(method,*args,&block);end;end", block.binding
          block.call.to_s
        end
        eval "alias :method_missing :method_missing_hold_#{r}", block.binding
        @@active_blocks.except!(r)
        return value

      else
        value = @source.send(method, *args, &block)
        value = Entry.new(value) if value.is_a?(Hash)
        return value
      end

    end

    def children(args = {})
      cache = !args.empty?
      result = nil
      if @source.children == nil || cache == false
        args ||= {}
        if args[:include_root]
          if site_root
            result = [static_finder.get_page("/"),*static_finder.get_pages(page_path)]
          else
            result = static_finder.get_pages(page_path)
          end
        else
          result = static_finder.get_pages(page_path)
        end
      else
        return @source.children
      end
      if cache && result
        @source.children = result
        @source.children
      else
        result
      end
    end



    def parent(args = {})
      cache = !args.empty?
      result = nil
      if @source.children == nil || cache == false
        result = page_path == "" ? nil : static_finder.get_page(static_finder.parent_path(path))
      else
        return @source.parent
      end
      if cache && result
        @source.parent = result
        @source.parent
      else
        result
      end
    end

    def siblings(args = {})
      cache = !args.empty?
      if parent
        return parent.children
      end
    end

    def to_s
      if title
        return title
      else
        super.to_s
      end
    end

  end
end

