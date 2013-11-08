require_relative "./helper"

describe "tasks" do
  it "response should be an array" do
    VCR.use_cassette("tasks/all_tasks") do
      response = request "sites/devcloud:acquiatoolbeltdev/tasks"
      expect(response.code).to eq "200"
      JSON.parse(response.body).should be_an_instance_of Array
    end
  end
end
