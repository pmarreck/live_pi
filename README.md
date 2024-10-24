# LivePi

This is a project to teach myself LiveView.

The idea is to stream Pi to the browser as fast as possible.

It was originally working, but too slowly (it was regenerating the whole number every time); then I broke it in the process of trying to have it utilize a streaming version of pi (which does work independently of liveview), probably because the state it must maintain to generate the next digit is much more sophisticated... and haven't fixed it yet. >..<>

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
