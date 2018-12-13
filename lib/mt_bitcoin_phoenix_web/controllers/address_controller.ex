defmodule MtBitcoinPhoenixWeb.AddressController do
  use MtBitcoinPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
