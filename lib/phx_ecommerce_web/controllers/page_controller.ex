defmodule PhxEcommerceWeb.PageController do
  use PhxEcommerceWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
