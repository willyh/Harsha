require 'spec_helper'

describe "posts/index.html.erb" do
  before(:each) do
    assign(:posts, [
      stub_model(Post,
        :question => "Question",
        :response => "Response"
      ),
      stub_model(Post,
        :question => "Question",
        :response => "Response"
      )
    ])
  end

  it "renders a list of posts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Question".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Response".to_s, :count => 2
  end
end
