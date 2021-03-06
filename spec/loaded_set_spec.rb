require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

require __DIR__.parent + 'lib/data_mapper/repository'
require __DIR__.parent + 'lib/data_mapper/resource'
require __DIR__.parent + 'lib/data_mapper/loaded_set'

describe "DataMapper::LoadedSet" do
  
  it "should be able to materialize arbitrary objects" do
    
    DataMapper.setup(:default, "mock://localhost/mock") unless DataMapper::Repository.adapters[:default]
    
    cow = Class.new do
      include DataMapper::Resource
      
      property :name, String, :key => true
      property :age, Fixnum
    end

    properties = Hash[*cow.properties(:default).zip([0, 1]).flatten]    
    set = DataMapper::LoadedSet.new(DataMapper::repository(:default), cow, properties)
    
    set.materialize!(['Bob', 10])
    set.materialize!(['Nancy', 11])
    
    results = set.entries
    results.should have(2).entries
    
    bob, nancy = results[0], results[1]

    bob.name.should eql('Bob')
    bob.age.should eql(10)
    bob.should_not be_a_new_record
    
    nancy.name.should eql('Nancy')
    nancy.age.should eql(11)
    nancy.should_not be_a_new_record
    
    results.first.should == bob
  end
end