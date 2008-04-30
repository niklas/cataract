require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
require 'init'
describe LcarsBox do
  before(:each) do
    @box = LcarsBox
  end
  it "should be a module" do
    @box.should be_instance_of(Module)
  end
end

describe ActionView::Base do
  before(:each) do
    @view = ActionView::Base.new
  end
  it "should have a method to define a box" do
    @view.should respond_to(:define_box)
  end
end

describe LcarsBox, "defining a box called 'helm'" do
  before(:each) do
    lambda do
      @view = ActionView::Base.new
      @view.define_box :helm
    end.should_not raise_error
  end
  it "should add this box to its list" do
    @view.list_of_lcars_boxes.should include(:helm)
  end
  it "should define a helper method to render_helm" do
    @view.should respond_to(:render_helm)
  end
  it "should define a helper method to update_helm" do
    @view.should respond_to(:update_helm)
  end

  describe "rendering with some simple data and a block" do
    before(:each) do
      @html = _erbout = ''
      @view.render_helm :title => 'The Title', :buttons => %w(a b c) do
        _erbout << "Some Content"
      end
    end
    it "should not be empty" do
      @html.should_not be_empty
    end
    it "should have a complete lcars div with given content" do
      @html.should have_tag('div.lcars') do
        with_tag('div.inner') do
          with_tag('div.content','Some Content')
        end
        with_tag('ul.buttons') do
          with_tag('li','a')
          with_tag('li + li','b')
          with_tag('li + li + li','c')
        end
        with_tag('span.title') do
          have_text('The Title')
        end
      end
    end
  end
end
