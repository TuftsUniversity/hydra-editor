require 'spec_helper'

describe "record editing" do
  before do
    HydraEditor.models = ['Audio']
    @user = FactoryGirl.create(:user)
    @ability = double(Ability)
    @ability.stub(:authorize!).and_return(true)
    Ability.stub(:new).with(@user).and_return(@ability)
    # Avoid the catalog so we don't have to run Solr
    allow_any_instance_of(RecordsController).to receive(:redirect_after_update).and_return("/404.html")
    allow_any_instance_of(Audio).to receive(:persisted?).and_return(true)
    allow_any_instance_of(Audio).to receive(:new_record?).and_return(false)
    allow_any_instance_of(Audio).to receive(:save).and_return(true)
    @record = Audio.new(pid: "foo:1", title: "Cool Track")
    # We need a clone to give to the edit view b/c it gets changed by initialize_fields
    @record_clone = Audio.new(pid: "foo:1", title: "Cool Track")
    # We use the original record for the update view to start clean and apply the form data
    ActiveFedora::Base.should_receive(:find).with(@record.pid, cast: true).and_return(@record_clone, @record)
    login_as @user
  end
  after do
    Warden.test_reset!
  end
  it "should be idempotent" do
    visit "/records/#{@record.pid}/edit"
    click_button 'Save'
    @record.title.should == ["Cool Track"]
    @record.creator.should == []
    @record.description.should == []
    @record.subject.should == []
  end
end
