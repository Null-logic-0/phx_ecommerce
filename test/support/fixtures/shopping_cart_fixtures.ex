defmodule PhxEcommerce.ShoppingCartFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxEcommerce.ShoppingCart` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{

      })

    {:ok, cart} = PhxEcommerce.ShoppingCart.create_cart(scope, attrs)
    cart
  end

  @doc """
  Generate a cart_item.
  """
  def cart_item_fixture(attrs \\ %{}) do
    {:ok, cart_item} =
      attrs
      |> Enum.into(%{
        price_when_carted: "120.5",
        quantity: 42
      })
      |> PhxEcommerce.ShoppingCart.create_cart_item()

    cart_item
  end
end
