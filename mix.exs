defmodule Vultr.Mixfile do
	use Mix.Project

	@description """
	Simple wrapper for the Vultr API
	"""

	def project do
		[
			app: :vultr,
			version: "0.2.1",
			elixir: "~> 1.3",
			deps: deps(),
			description: @description,
			package: package(),
		]
	end

	# Configuration for the OTP application
	def application do
		[applications: [:tesla, :ibrowse]]
	end

	defp deps do
		[
			{:inch_ex, "~> 0.5", only: :docs},
			{:ex_doc, "~> 0.14", only: :dev, runtime: false},
			{:tesla, "~> 0.7.1"},
			{:ibrowse, "~> 4.2"},
			{:poison, ">= 1.0.0"}
		]
	end

	defp package do
		[
			name: :vultr,
			maintainers: ["James Dyson"],
			licenses: ["MIT"],
			links: %{"GitHub" => "https://github.com/avitex/elixir-vultr"},
		]
	end
end
