require_relative "./helper"

describe "domains" do
  it "response should be an array" do
    VCR.use_cassette("domains/all_dev_domains") do
      response = AcquiaToolbelt::CLI::API.request "sites/devcloud:acquiatoolbeltdev/envs/dev/domains", "GET", {}, false
      expect(response.status).to eq 200
      JSON.parse(response.body).should be_an_instance_of Array
    end
  end

  it "should return fields that are used" do
    VCR.use_cassette("domains/all_dev_domains") do
      response = AcquiaToolbelt::CLI::API.request "sites/devcloud:acquiatoolbeltdev/envs/dev/domains", "GET", {}, false
      expect(response.status).to eq 200
      response.body.should include "name"
    end
  end
end
