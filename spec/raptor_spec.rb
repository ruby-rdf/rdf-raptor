require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::Raptor do
  it 'should return the libraptor version' do
    expect(subject.version).not_to be_nil
  end
  
  it 'should be available' do
    expect(subject.available?).to be true
  end
end
