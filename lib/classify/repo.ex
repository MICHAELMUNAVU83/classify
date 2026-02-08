defmodule Classify.Repo do
  use Ecto.Repo,
    otp_app: :classify,
    adapter: Ecto.Adapters.Postgres
end
