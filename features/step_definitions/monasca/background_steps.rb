Given(/^the admin node is available$/) do
  validate_admin!
end

Given(/^monasca node is available$/) do
  @monasca_node = nodes.find(node_alias: "monasca").first
  expect(@monasca_node).not_to eq(nil)
  admin_node.ping!(@monasca_node)
end
