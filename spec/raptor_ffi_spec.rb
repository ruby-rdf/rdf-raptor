require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/raptor/ffi'
require 'rdf/raptor/cli'

describe RDF::Raptor do  
  it 'should load the FFI engine' do
    #subject.ENGINE.should eql(:ffi)
    subject.included_modules.should include(RDF::Raptor::FFI)
    subject.included_modules.should_not include(RDF::Raptor::CLI)
  end
end

describe RDF::Raptor::FFI do
  it 'should return the libraptor version' do
    RDF::Raptor.version.should_not be_nil
  end
end
