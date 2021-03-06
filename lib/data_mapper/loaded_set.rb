require 'set'

module DataMapper
 
  class LoadedSet
 
    attr_reader :repository
    
    # +properties+ is a Hash of Property and values Array index pairs.
    #   { Property<:id> => 1, Property<:name> => 2, Property<:notes> => 3 }
    def initialize(repository, type, properties)
      @repository = repository
      @type = type
      @properties = properties
 
      @inheritance_property_index = if @inheritance_property = @type.inheritance_property(@repository.name) &&
        @properties.key?(@inheritance_property)
        @properties.values_at(@inheritance_property)
      else
        nil
      end
 
      @key_property_indexes = if (@key_properties = @type.key(@repository.name)).all? { |key| @properties.key?(key) }
        @properties.values_at(*@key_properties)
      else
        nil
      end
 
      @entries = []
    end
 
    def materialize!(values, reload = false)
      type = if @inheritance_property_index
        values[@inheritance_property_index]
      else
        @type
      end
 
      instance = nil
 
      if @key_property_indexes
        key_values = @key_property_indexes.map { |i| values[i] }
        instance = @repository.identity_map_get(type, key_values)
 
        if instance.nil?
          instance = type.allocate
          i = 0
          @key_properties.each do |p|
            instance.instance_variable_set(p.instance_variable_name, key_values[i])
            i += 1
          end
          @entries << instance
          instance.loaded_set = self
          instance.instance_variable_set("@new_record", false)
          @repository.identity_map_set(instance)
        else
          @entries << instance
          instance.loaded_set = self
          return instance unless reload
        end
      else
        instance = type.allocate
        instance.readonly!
        instance.instance_variable_set("@new_record", false)
        @entries << instance
        instance.loaded_set = self
      end
 
      @properties.each_pair do |property, i|
        instance.instance_variable_set(property.instance_variable_name, values[i])
      end
 
      instance
    end
    
    def first
      @entries.first
    end
    
    def entries
      @entries.uniq!
      @entries.dup
    end
  end
 
end