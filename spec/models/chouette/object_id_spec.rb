require 'spec_helper'

describe Chouette::ObjectId do

  def objectid(value = "abc:StopArea:abc123")
    Chouette::ObjectId.new value
  end

  subject { objectid }

  context "when invalid" do

    subject { objectid("abc") }

    it { should_not be_valid }

    its(:parts) { should be_nil }
    its(:system_id) { should be_nil }

  end
  
  context "when with spaces in last part" do

    subject { objectid("abc:Line:Aze toto") }

    it { should_not be_valid }


  end
  
  context "when with spaces in first part" do

    subject { objectid("ae abc:Line:Aze") }

    it { should_not be_valid }


  end
  
  context "when with spaces in middle part" do

    subject { objectid("aeabc:Li ne:Aze") }

    it { should_not be_valid }
    

  end
  
  context "when invalid in first part" do

    subject { objectid("Abc_+19:Line:Abc") }

    it { should_not be_valid }
  end
  
  context "when invalid in middle part" do

    subject { objectid("Abc_19:Li56ne:Abc") }

    it { should_not be_valid }
  end

  context "when invalid in last part" do

    subject { objectid("Abc_19:Line:Ab+c") }

    it { should_not be_valid }
  end
  context "when valid" do

    subject { objectid("Abc_19:Line:Abc_12-") }

    it { should be_valid }
  end

  describe "#parts" do

    it "should be the 3 parts of the ObjectId" do
      objectid("abc:StopArea:abc123").parts.should == %w{abc StopArea abc123}
    end

  end

  describe "#system_id" do
    
    it "should be the first ObjectId parts" do
      objectid("first:second:third").system_id.should == "first"
    end

  end

  describe "#object_type" do
    
    it "should be the second ObjectId parts" do
      objectid("first:second:third").object_type.should == "second"
    end

  end

  describe "#local_id" do
    
    it "should be the third ObjectId parts" do
      objectid("first:second:third").local_id.should == "third"
    end

  end

  it "should be valid when parts are found" do
    subject.stub :parts => "dummy"
    subject.should be_valid
  end

  describe ".create" do

    let(:given_system_id) { "systemId" }
    let(:given_object_type) { "objectType" }
    let(:given_local_id) { "localId" }

    subject { Chouette::ObjectId.create(given_system_id, given_object_type, given_local_id) }
    
    RSpec::Matchers.define :return_an_objectid_with_given do |attribute|
      match do |actual|
        actual.send(attribute).should == send("given_#{attribute}")
      end
    end

    it { should return_an_objectid_with_given(:system_id) }
    it { should return_an_objectid_with_given(:object_type) }
    it { should return_an_objectid_with_given(:local_id) }

  end

  describe ".new" do
    
    it "should return an existing ObjectId" do
      Chouette::ObjectId.new(objectid).should == objectid
    end

    it "should create an empty ObjectId with nil" do
      Chouette::ObjectId.new(nil).should be_empty
    end

  end


end
