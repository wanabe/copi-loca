require 'rails_helper'

describe "GET /models", type: :request do
  it "returns 200 and renders the index page" do
    client = instance_double(Client, available_models: [ { id: "gpt-4.1", billing: { multiplier: 1 } } ])
    allow(Client).to receive(:new).and_return(client)
    get "/models"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Models")
    expect(response.body).to include("gpt-4.1")
  end
end
