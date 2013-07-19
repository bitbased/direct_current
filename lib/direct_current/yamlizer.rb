module DirectCurrent
  module Yamlizer
    def self.included(base)
      base.class_eval do
        alias_method :encode_without_yamlinator!, :encode!
        alias_method :encode!, :encode_with_yamlinator!
      end
    end
  
    def encode_with_yamlinator!
      if source.start_with?("---")
        source.sub!(/^---$.*?.^---$./m,'')
      end
      encode_without_yamlinator!
    end
  end
end
