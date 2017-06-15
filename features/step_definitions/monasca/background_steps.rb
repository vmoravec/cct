Given(/^the admin node is available$/) do
  validate_admin!
end

Given(/^monasca node is available$/) do
  monasca_node = nodes.find(node_alias: "monasca")
  expect(monasca_node).not_to eq(nil)
end
