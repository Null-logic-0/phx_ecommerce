defmodule PhxEcommerce.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias PhxEcommerce.Repo
  alias PhxEcommerce.Orders.Order
  alias PhxEcommerce.Accounts.Scope
  alias PhxEcommerce.Orders.LineItem
  alias PhxEcommerce.ShoppingCart

  @doc """
  Subscribes to scoped notifications about any order changes.

  The broadcasted messages match the pattern:

    * {:created, %Order{}}
    * {:updated, %Order{}}
    * {:deleted, %Order{}}

  """
  def subscribe_orders(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(PhxEcommerce.PubSub, "user:#{key}:orders")
  end

  defp broadcast_order(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(PhxEcommerce.PubSub, "user:#{key}:orders", message)
  end

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders(scope)
      [%Order{}, ...]

  """
  def list_orders(%Scope{} = scope) do
    Repo.all_by(Order, user_id: scope.user.id)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(scope, 123)
      %Order{}

      iex> get_order!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(%Scope{} = scope, id) do
    Order
    |> Repo.get_by!(id: id, user_id: scope.user.id)
    |> Repo.preload(line_items: [:product])
  end

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(scope, %{field: value})
      {:ok, %Order{}}

      iex> create_order(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(%Scope{} = scope, attrs) do
    with {:ok, order = %Order{}} <-
           %Order{}
           |> Order.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_order(scope, {:created, order})
      {:ok, order}
    end
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(scope, order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(scope, order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Scope{} = scope, %Order{} = order, attrs) do
    true = order.user_id == scope.user.id

    with {:ok, order = %Order{}} <-
           order
           |> Order.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_order(scope, {:updated, order})
      {:ok, order}
    end
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(scope, order)
      {:ok, %Order{}}

      iex> delete_order(scope, order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Scope{} = scope, %Order{} = order) do
    true = order.user_id == scope.user.id

    with {:ok, order = %Order{}} <-
           Repo.delete(order) do
      broadcast_order(scope, {:deleted, order})
      {:ok, order}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(scope, order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Scope{} = scope, %Order{} = order, attrs \\ %{}) do
    true = order.user_id == scope.user.id

    Order.changeset(order, attrs, scope)
  end

  alias PhxEcommerce.Orders.LineItem

  @doc """
  Returns the list of order_line_items.

  ## Examples

      iex> list_order_line_items()
      [%LineItem{}, ...]

  """
  def list_order_line_items do
    Repo.all(LineItem)
  end

  @doc """
  Gets a single line_item.

  Raises `Ecto.NoResultsError` if the Line item does not exist.

  ## Examples

      iex> get_line_item!(123)
      %LineItem{}

      iex> get_line_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_line_item!(id), do: Repo.get!(LineItem, id)

  @doc """
  Creates a line_item.

  ## Examples

      iex> create_line_item(%{field: value})
      {:ok, %LineItem{}}

      iex> create_line_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_line_item(attrs) do
    %LineItem{}
    |> LineItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a line_item.

  ## Examples

      iex> update_line_item(line_item, %{field: new_value})
      {:ok, %LineItem{}}

      iex> update_line_item(line_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_line_item(%LineItem{} = line_item, attrs) do
    line_item
    |> LineItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a line_item.

  ## Examples

      iex> delete_line_item(line_item)
      {:ok, %LineItem{}}

      iex> delete_line_item(line_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_line_item(%LineItem{} = line_item) do
    Repo.delete(line_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking line_item changes.

  ## Examples

      iex> change_line_item(line_item)
      %Ecto.Changeset{data: %LineItem{}}

  """
  def change_line_item(%LineItem{} = line_item, attrs \\ %{}) do
    LineItem.changeset(line_item, attrs)
  end

  def complete_order(%Scope{} = scope, %ShoppingCart.Cart{} = cart) do
    true = cart.user_id == scope.user.id

    line_items =
      Enum.map(cart.items, fn item ->
        %{
          product_id: item.product_id,
          price: item.product.price,
          quantity: item.quantity
        }
      end)

    order_changeset =
      Ecto.Changeset.change(%Order{}, %{
        user_id: scope.user.id,
        total_price: ShoppingCart.total_cart_price(cart),
        line_items: line_items
      })

    Repo.transact(fn ->
      with {:ok, order} <- Repo.insert(order_changeset),
           {:ok, _cart} <- ShoppingCart.prune_cart_items(scope, cart) do
        {:ok, order}
      end
    end)
    |> case do
      {:ok, order} ->
        broadcast_order(scope, {:created, order})
        {:ok, order}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
