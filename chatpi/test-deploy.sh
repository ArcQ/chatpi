source ./.env.dev
MIX_ENV=prod mix compile && MIX_ENV=prod mix release && ./_build/prod/rel/chatpi/bin/chatpi start
