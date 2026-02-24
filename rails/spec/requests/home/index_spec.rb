require 'rails_helper'

describe "GET /", type: :request do
  it "returns 200 and renders the home page" do
    get "/"
    expect(response).to have_http_status(:ok)
    # ルートページのタイトルや特徴的な文言で判定
    expect(response.body).to include("Copi Loca").or include("Sessions")
  end
end
