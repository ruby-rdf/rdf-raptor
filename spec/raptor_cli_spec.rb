require File.join(File.dirname(__FILE__), 'spec_helper')
ENV['RDF_RAPTOR_ENGINE'] = 'cli'
require 'rdf/raptor/cli'
require 'rdf/raptor/ffi'

describe RDF::Raptor, :cli => true do
  it 'should load the CLI engine' do
    #subject.ENGINE.should eql(:cli)
    expect(subject.included_modules).to include(RDF::Raptor::CLI)
    expect(subject.included_modules).not_to include(RDF::Raptor::FFI)
  end
end

describe RDF::Raptor::CLI, :cli => true do
  it 'should return the libraptor version' do
    expect(RDF::Raptor.version).not_to be_nil
  end
end
