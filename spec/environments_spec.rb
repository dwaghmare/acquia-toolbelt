require_relative "./helper"

describe "environments" do
  it "response should be an array" do
    VCR.use_cassette("environments/all_environments") do
      response = request "sites/devcloud:acquiatoolbeltdev/envs"
      expect(response.code).to eq "200"
      JSON.parse(response.body).should be_an_instance_of Array
    end
  end

  it "should return fields that are used" do
    VCR.use_cassette("environments/all_environments") do
      response = request "sites/devcloud:acquiatoolbeltdev/envs"
      expect(response.code).to eq "200"
      response.body.should include("name", "livedev", "ssh_host", "db_clusters", "vcs_path", "default_domain")
    end
  end
end
