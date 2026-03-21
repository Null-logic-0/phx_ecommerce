defmodule PhxEcommerceWeb.PageController do
  use PhxEcommerceWeb, :controller
  alias PhxEcommerce.Catalog

  def home(conn, _params) do
    products = Catalog.list_products()
    render(conn, :home, products: products, page_title: "Products List")
  end
end
