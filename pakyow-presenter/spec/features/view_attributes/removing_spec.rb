RSpec.describe "removing string attributes" do
  let :view do
    Pakyow::Presenter::View.new("<div@post title=\"foo\"></div>").find(:post)
  end

  it "can be removed" do
    view.attributes.delete(:title)
    expect(view.to_html).not_to include("title")
  end

  it "can be removed by setting value to nil" do
    view.attributes[:title] = nil
    expect(view.to_html).not_to include("title")
  end
end

RSpec.describe "removing hash attributes" do
  let :view do
    Pakyow::Presenter::View.new("<div@post style=\"color:red\"></div>").find(:post)
  end

  it "can be removed" do
    view.attributes.delete(:style)
    expect(view.to_html).not_to include("style")
  end

  it "can be removed by setting value to nil" do
    view.attributes[:style] = nil
    expect(view.to_html).not_to include("style")
  end
end

RSpec.describe "removing set attributes" do
  let :view do
    Pakyow::Presenter::View.new("<div@post class=\"foo bar\"></div>").find(:post)
  end

  it "can be removed" do
    view.attributes.delete(:class)
    expect(view.to_html).not_to include("class")
  end

  it "can be removed by setting value to nil" do
    view.attributes[:class] = nil
    expect(view.to_html).not_to include("class")
  end
end

RSpec.describe "removing boolean attributes" do
  let :view do
    Pakyow::Presenter::View.new("<div@post checked=\"checked\"></div>").find(:post)
  end

  it "can be removed" do
    view.attributes.delete(:checked)
    expect(view.to_html).not_to include("checked")
  end

  it "can be removed by setting value to nil" do
    view.attributes[:checked] = nil
    expect(view.to_html).not_to include("checked")
  end
end
