defmodule Crypto do
  def generate_keys do
    :crypto.generate_key(:ecdh, :secp256k1)
  end

  def sign(message, private_key) do
    :crypto.sign(:ecdsa, :sha256, message, [private_key, :secp256k1])
  end

  def verify(message, signature, public_key) do
    :crypto.verify(:ecdsa, :sha256, message, signature, [public_key, :secp256k1])
  end
end
