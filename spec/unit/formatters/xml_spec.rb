require 'chelsea/formatters/xml'

RSpec.describe Chelsea::XMLFormatter do
  it "brings back a proper junit xml style object" do
    server_response = Array.new
    server_response.push(populate_server_response("test", "test", "test")) 
    server_response.push(populate_server_response("test2", "test2", "test2")) 
    command = Chelsea::XMLFormatter.new({})

    xml = command.print_results(server_response, {})

    expect(xml).to eq("")
  end
end

def populate_server_response(coordinate, desc, reference)
  response = Hash.new
  response["coordinates"] = coordinate
  response["description"] = desc
  response["reference"] = reference
  response["vulnerabilities"] = Array.new

  response
end
