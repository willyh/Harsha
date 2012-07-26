require 'spec_helper'

describe "posts/show.html.erb" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :question => "Question",
      :response => "Response"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Question/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Response/)
  end
end
