[![Build Status](https://travis-ci.org/avitex/elixir-vultr.svg)](https://travis-ci.org/avitex/elixir-vultr)
[![Hex.pm](https://img.shields.io/hexpm/v/vultr.svg)](https://hex.pm/packages/vultr)
[![Hex Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/vultr)

# Vultr

**Simple wrapper for the [Vultr API](https://www.vultr.com/api/).**  
Documentation hosted on [hexdocs](https://hexdocs.pm/vultr).

## Installation

  Add `vultr` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:vultr, "~> 0.2.2"}]
  end
  ```

## Examples
#### Retrieving app list

  ```elixir
  Vultr.app_list()

  # Example response
  {:ok, %{ "1" => %{"APPID" => "1", "deploy_name" => "LEMP on CentOS 6 x64", ... }, ... }}
  ```

#### Using authenticated methods

  ```elixir
  client = Vultr.client("<APIKEY>")
  Vultr.server_list(client, [])
  ```
