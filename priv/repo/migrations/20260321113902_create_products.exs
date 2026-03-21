defmodule PhxEcommerce.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string
      add :description, :string
      add :price, :decimal, precision: 15, scale: 6, null: false
      add :image_path, :string, default: "/images/default.jpg"

      timestamps(type: :utc_datetime)
    end
  end
end
