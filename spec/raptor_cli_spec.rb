require File.join(File.dirname(__FILE__), 'spec_helper')
ENV['RDF_RAPTOR_ENGINE'] = 'cli'
require 'rdf/raptor/cli'
require 'rdf/raptor/ffi'

describe RDF::Raptor, :cli => true do
  it 'should load the CLI engine' do
    #subject.ENGINE.should eql(:cli)
    subject.included_modules.should include(RDF::Raptor::CLI)
    subject.included_modules.should_not include(RDF::Raptor::FFI)
  end
end

describe RDF::Raptor::CLI, :cli => true do
  it 'should return the libraptor version' do
    RDF::Raptor.version.should_not be_nil
  end
end
