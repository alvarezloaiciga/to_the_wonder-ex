defmodule ToTheWonder.Repo do
  use Ecto.Repo,
    otp_app: :to_the_wonder,
    adapter: Ecto.Adapters.Postgres
end
