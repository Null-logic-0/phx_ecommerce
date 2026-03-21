defmodule PhxEcommerceWeb.ProductHTML do
  use PhxEcommerceWeb, :html

  embed_templates "product_html/*"

  @doc """
  Renders a product form.

  The form is defined in the template at
  product_html/product_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def product_form(assigns)

  def category_opts(changeset) do
    changeset
    |> Ecto.Changeset.get_change(:categories, [])
    |> Enum.map(& &1.data.id)

    for cat <- PhxEcommerce.Catalog.list_categories() do
      {cat.title, cat.id}
    end
  end
end
