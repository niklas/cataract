require File.dirname(__FILE__) + '/spec_helper'
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
    @template = ActionView::Base.new
  end
  it "should have a method to define a box" do
    @template.should respond_to(:define_box)
  end
end

describe LcarsBox, "defining a box called 'helm'" do
  before(:each) do
    lambda do
      @template = ActionView::Base.new
      @template.define_box :helm
    end.should_not raise_error
  end
  it "should add this box to its list" do
    @template.list_of_lcars_boxes.should include(:helm)
  end
  it "should define a helper method to render_helm" do
    @template.should respond_to(:render_helm)
  end
  it "should define a helper method to update_helm" do
    @template.should respond_to(:update_helm)
  end

  describe "rendering with some simple data and a block" do
    before(:each) do
      @html = _erbout = ''
      @template.render_helm :title => 'The Title', :buttons => %w(a b c) do
        _erbout << "Some Content"
      end
    end
    it "should not be empty" do
      @html.should_not be_empty
    end
    it "should have a complete lcars div with given content" do
      @html.should have_tag('div.lcars#helm') do
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

  describe "updating with some simple data for :title, :buttons and :content" do
    before(:each) do
      @update_data = { 
        :title => 'Another Title', 
        :buttons => %w(x y z),
        :content => "Some other Content"
      }
    end
    it "should select and replace the title" do
      rjs_for.update_helm(@update_data).should select_dom_element("helm > .title").and_replace_with(@update_data[:title])
    end
    it "should select and replace the content" do
      rjs_for.update_helm(@update_data).should select_dom_element("helm > div.inner > div.content").and_replace_with(@update_data[:content])
    end
    it "should select and replace the buttons" do
      rjs_for.update_helm(@update_data).should select_dom_element("helm > .buttons").and_replace_with('<li>x</li> <li>y</li> <li>z</li>')
    end
  end
end
