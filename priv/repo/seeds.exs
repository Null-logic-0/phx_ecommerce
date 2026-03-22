alias PhxEcommerce.Catalog
alias PhxEcommerce.Catalog.Product
alias PhxEcommerce.Repo

# --- Categories ---
category_titles = ["Home Improvement", "Power Tools", "Gardening", "Books", "Education"]

categories =
  for title <- category_titles do
    {:ok, category} = Catalog.create_category(%{title: title})
    category
  end

# --- Products ---
product_data = [
  %{
    title: "Cordless Drill",
    description: "Lightweight, battery-powered drill for DIY projects.",
    price: Decimal.new("79.99"),
    category_titles: ["Power Tools"],
    image_path: "/images/drill.jpg"
  },
  %{
    title: "Garden Shovel",
    description: "Durable steel shovel for gardening and landscaping.",
    price: Decimal.new("24.50"),
    category_titles: ["Gardening", "Home Improvement"],
    image_path: "/images/shovel.jpg"
  },
  %{
    title: "Learning Elixir",
    description: "A complete guide to functional programming in Elixir.",
    price: Decimal.new("39.99"),
    category_titles: ["Books", "Education"],
    image_path: "/images/elixir.jpg"
  }
]

for %{
      title: title,
      description: desc,
      price: price,
      image_path: image_path,
      category_titles: cat_titles
    } <- product_data do
  product_categories =
    categories
    |> Enum.filter(&(&1.title in cat_titles))

  %Product{}
  |> Product.changeset(%{
    title: title,
    description: desc,
    price: price,
    image_path: image_path
  })
  |> Ecto.Changeset.put_assoc(:categories, product_categories)
  |> Repo.insert!()
end
