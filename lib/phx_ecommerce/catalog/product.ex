defmodule PhxEcommerce.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias PhxEcommerce.Catalog.Category

  schema "products" do
    field :title, :string
    field :description, :string
    field :price, :decimal
    field :image_path, :string
    field :category_ids, {:array, :integer}, virtual: true

    many_to_many :categories, Category, join_through: "product_categories", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:title, :description, :price, :image_path])
    |> validate_required([:title, :description, :price])
  end
end
