defmodule LivePi.Repo do
  use Ecto.Repo,
    otp_app: :live_pi,
    adapter: Ecto.Adapters.Postgres
end
