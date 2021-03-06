require 'pp'
require 'pathname'
require 'rubygems'
require 'spec'

# for __DIR__
require Pathname(__FILE__).dirname.expand_path.parent + 'lib/data_mapper/support/kernel'

ENV['LOG_NAME'] = 'spec'
require __DIR__.parent + 'environment'
require __DIR__ + 'mock_adapter'

class Article
  include DataMapper::Resource
  include DataMapper::Scope

  property :blog_id,    Fixnum
  property :created_at, DateTime
  property :author,     String
  property :title,      String

  class << self
    def property_by_name(name)
      properties(repository.name).detect do |property|
        property.name == name
      end
    end
  end
end

class Comment
  include DataMapper::Resource
end

class NormalClass
  # should not include DataMapper::Resource
end

class Class
  def publicize_methods
    klass = class << self; self; end

    saved_private_class_methods      = klass.private_instance_methods
    saved_protected_class_methods    = klass.protected_instance_methods
    saved_private_instance_methods   = self.private_instance_methods
    saved_protected_instance_methods = self.protected_instance_methods

    self.class_eval do
      klass.send(:public, *saved_private_class_methods)
      klass.send(:public, *saved_protected_class_methods)
      public(*saved_private_instance_methods)
      public(*saved_protected_instance_methods)
    end

    begin
      yield
    ensure
      self.class_eval do
        klass.send(:private, *saved_private_class_methods)
        klass.send(:protected, *saved_protected_class_methods)
        private(*saved_private_instance_methods)
        protected(*saved_protected_instance_methods)
      end
    end
  end
end
