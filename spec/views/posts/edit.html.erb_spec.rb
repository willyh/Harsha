require 'spec_helper'

describe "posts/edit.html.erb" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :question => "MyString",
      :response => "MyString"
    ))
  end

  it "renders the edit post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => posts_path(@post), :method => "post" do
      assert_select "input#post_question", :name => "post[question]"
      assert_select "input#post_response", :name => "post[response]"
    end
  end
end
