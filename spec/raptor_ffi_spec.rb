require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/raptor/ffi'
require 'rdf/raptor/cli'

describe RDF::Raptor do  
  it 'should load the FFI engine' do
    #subject.ENGINE.should eql(:ffi)
    expect(subject.included_modules).to include(RDF::Raptor::FFI)
    expect(subject.included_modules).not_to include(RDF::Raptor::CLI)
  end
end

describe RDF::Raptor::FFI do
  it 'should return the libraptor version' do
    expect(RDF::Raptor.version).not_to be_nil
  end
end
