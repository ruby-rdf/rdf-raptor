require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::Raptor do
  it 'should return the libraptor version' do
    subject.version.should_not be_nil
  end
  
  it 'should be available' do
    subject.available?.should be_true
  end
end