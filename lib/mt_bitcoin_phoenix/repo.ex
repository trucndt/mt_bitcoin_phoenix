defmodule MtBitcoinPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :mt_bitcoin_phoenix,
    adapter: Ecto.Adapters.Postgres
end
