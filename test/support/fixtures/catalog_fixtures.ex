defmodule PhxEcommerce.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxEcommerce.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image_path: "some image_path",
        price: "120.5",
        title: "some title"
      })
      |> PhxEcommerce.Catalog.create_product()

    product
  end
end
