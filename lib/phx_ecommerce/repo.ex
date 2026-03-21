defmodule PhxEcommerce.Repo do
  use Ecto.Repo,
    otp_app: :phx_ecommerce,
    adapter: Ecto.Adapters.Postgres
end
