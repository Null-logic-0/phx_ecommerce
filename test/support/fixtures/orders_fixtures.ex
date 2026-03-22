defmodule PhxEcommerce.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxEcommerce.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        total_price: "120.5"
      })

    {:ok, order} = PhxEcommerce.Orders.create_order(scope, attrs)
    order
  end

  @doc """
  Generate a line_item.
  """
  def line_item_fixture(attrs \\ %{}) do
    {:ok, line_item} =
      attrs
      |> Enum.into(%{
        price: "120.5",
        quantity: 42
      })
      |> PhxEcommerce.Orders.create_line_item()

    line_item
  end
end
