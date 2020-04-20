defmodule Vultr.Mixfile do
	use Mix.Project

	@description """
	Simple wrapper for the Vultr API
	"""

	def project, do: [
		app: :vultr,
		version: "0.3.0",
		elixir: "~> 1.5",
		deps: deps(),
		description: @description,
		package: package(),
	]

	# Configuration for the OTP application
	def application, do: [
		applications: [:httpotion],
	]

	defp deps, do: [
		{:inch_ex, "~> 2.0", only: :docs},
		{:ex_doc, "~> 0.16", only: :dev, runtime: false},
		{:httpotion, "~> 3.1.3"},
		{:poison, "~> 3.1"},
	]

	defp package, do: [
		name: :vultr,
		maintainers: ["James Dyson"],
		licenses: ["MIT"],
		links: %{"GitHub" => "https://github.com/avitex/elixir-vultr"},
	]
end
