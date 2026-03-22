defmodule PhxEcommerce.ShoppingCart.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    field :price_when_carted, :decimal
    field :quantity, :integer

    belongs_to :cart, PhxEcommerce.ShoppingCart.Cart
    belongs_to :product, PhxEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:quantity])
    |> validate_required([:quantity])
    |> validate_number(:quantity, greater_than_or_equal_to: 0, less_than: 100)
  end
end
