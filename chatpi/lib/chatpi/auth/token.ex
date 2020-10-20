defmodule Chatpi.Auth.FetchStrategy do
  @moduledoc false
  use JokenJwks.DefaultStrategyTemplate

  def init_opts(opts) do
    url = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_HnccgMQBx/.well-known/jwks.json"
    Keyword.merge(opts, jwks_url: url)
  end
end

defmodule Chatpi.Auth.Token do
  @moduledoc false
  # no signer
  use Joken.Config, default_signer: nil

  add_hook(JokenJwks, strategy: Chatpi.Auth.FetchStrategy)

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss])
    # |> add_claim("roles", nil, &(&1 in ["admin", "user"])
    |> add_claim(
      "iss",
      nil,
      &(&1 == "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_HnccgMQBx")
    )
  end
end
