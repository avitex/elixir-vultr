[![Build Status](https://travis-ci.org/avitex/elixir-vultr.svg)](https://travis-ci.org/avitex/elixir-vultr)
[![Inline docs](http://inch-ci.org/github/avitex/elixir-vultr.svg)](http://inch-ci.org/github/avitex/elixir-vultr)

# Vultr

**Simple wrapper for the [Vultr API](https://www.vultr.com/api/).**  
Documentation hosted on [hexdocs](https://hexdocs.pm/vultr).

## Installation

  Add `vultr` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:vultr, "~> 0.1.0"}]
  end
  ```

## Examples
### Retrieving app list

  ```elixir
  Vultr.app_list()

  # Example response
  %{
    body: %{ "1" => %{"APPID" => "1", "deploy_name" => "LEMP on CentOS 6 x64", ... }, ... },
    headers: %{ "content-type" => "application/json", ... },
    method: :get,
    opts: [],
    query: [],
    status: 200,
    url: "https://api.vultr.com/v1/app/list"
  }
  ```

### Using authenticated methods

  ```elixir
  client = Vultr.client("<APIKEY>")
  Vultr.server_list(client, %{})
  ```