def populate_server_response(coordinate, desc, reference)
  response = Hash.new
  response["coordinates"] = coordinate
  response["description"] = desc
  response["reference"] = reference
  response["vulnerabilities"] = Array.new

  response
end

def populate_server_response_vulnerability(server_response)
  vulnerability = Hash.new
  vulnerability["id"] = "913ec790-8fc6-49fc-b424-170c1b60c97c"
  vulnerability["title"] = "[CVE-2013-4660]  Improper Input Validation"
  vulnerability["description"] = "The JS-YAML module before 2.0.5 for Node.js parses input without properly considering the unsafe !!js/function tag, which allows remote attackers to execute arbitrary code via a crafted string that triggers an eval operation."
  vulnerability["cvssScore"] = 6.8
  vulnerability["cvssVector"] = "AV:N/AC:M/Au:N/C:P/I:P/A:P"
  vulnerability["cve"] = "CVE-2013-4660"
  vulnerability["reference"] = "https://ossindex.sonatype.org/vuln/913ec790-8fc6-49fc-b424-170c1b60c97c"
  server_response["vulnerabilities"].push(vulnerability)
  
  server_response
end
