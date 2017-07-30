defmodule Vultr.Request do
	@moduledoc false

	@special_params [
		:subid, :dcid, :recordid, :vpsplanid, :appid, :osid,
		:isoid, :scriptid, :snapshotid, :sshkeyid, :backupid, :userid,
	]

	defmacro __using__(_) do
		quote do
			import Vultr.Request, only: [request: 3]
		end
	end

	defmacro request(endpoint_method, endpoint_path, endpoint_opts) do
		endpoint_params = Keyword.get(endpoint_opts, :params, {nil, nil, []}) |> normalize_params
		endpoint_description = Keyword.fetch!(endpoint_opts, :desc)
		endpoint_requires_api_key = Keyword.get(endpoint_opts, :api_key, nil)	
		endpoint_required_access = Keyword.get(endpoint_opts, :required_access, nil)
		endpoint_has_params = (length(endpoint_params) > 0)

		common_args = [__CALLER__.module, endpoint_method, endpoint_path]

		func = &__MODULE__.perform_request/5

		func_name =
			endpoint_path
			|> String.replace("/", "_")
			|> String.to_atom

		func_doc = gen_doc(
			endpoint_method, endpoint_path, 
			endpoint_description, endpoint_params, 
			endpoint_required_access, endpoint_requires_api_key
		)

		func_body =
			cond do
				endpoint_requires_api_key && endpoint_has_params ->
					quote do
						def unquote(func_name)(client, params \\ []) when is_list(params) do
							unquote(func).(unquote_splicing(common_args), client, params)
						end
					end
				endpoint_requires_api_key ->
					quote do
						def unquote(func_name)(client) do
							unquote(func).(unquote_splicing(common_args), client, [])
						end
					end
				endpoint_has_params ->
					quote do
						def unquote(func_name)(params \\ []) when is_list(params) do
							unquote(func).(unquote_splicing(common_args), nil, params)
						end
					end
				true ->
					quote do
						def unquote(func_name)() do
							unquote(func).(unquote_splicing(common_args), nil, [])
						end
					end
			end

		quote do
			@doc unquote(func_doc)
			unquote(func_body)
		end
	end

	def perform_request(caller, method, url, client, params) do
		opts = [url: url, method: method] ++ prepare_params(method, params)
		resp = Tesla.perform_request(caller, client, opts)
		case resp.status do
			200 -> {:ok, resp.body}
			400 -> {:error, :invalid_api_location, resp.body}
			403 -> {:error, :invalid_api_key, resp.body}
			405 -> {:error, :invalid_http_method, resp.body}
			412 -> {:error, :bad_request, resp.body}
			500 -> {:error, :server_error, resp.body}
			503 -> {:error, :rate_limit, resp.body}
		end
	end

	defp prepare_params(:get, nil), do: [query: []]
	defp prepare_params(_, nil), do: [body: %{}]
	defp prepare_params(:get, params), do: [query: capitalize_special_params(params)]
	defp prepare_params(_, params), do: [body: Enum.into(capitalize_special_params(params), %{})]

	defp capitalize_special_params(params) do
		Enum.map(params, fn {k, v} ->
			is_special_param =
				Enum.any?(@special_params, fn special_param ->
					special_param == k
				end)

			if is_special_param do
				{k |> Atom.to_string |> String.upcase, v}
			else
				{k, v}
			end
		end)
	end

	defp normalize_param({name, opts}) do
		type = Keyword.fetch!(opts, :type)
		%{
			name: name,
			default: Keyword.get(opts, :default, nil),
			name_atom: (name |> String.downcase |> String.to_atom),
			optional: Keyword.get(opts, :optional, false),
			type: type,
			type_string: (type |> Atom.to_string),
			desc: Keyword.fetch!(opts, :desc),
		}
	end

	defp normalize_params({_, _, []}), do: []
	defp normalize_params({_, _, params}), do: params |> Enum.map(&normalize_param/1)

	##################################################
	# Documentation helpers

	defp gen_doc(method, path, desc, params, required_access, api_key) do
		doc = """
		#{desc}
		"""

		doc = 
			if length(params) > 0 do
				doc <> ("""
				### Params
				| Name | Type | Optional | Description |
				| ---- | ---- | -------- | ----------- |
				#{doc_params(params)}
				""")
			else
				doc
			end

		doc <> """
		### Backend
		- Method:           `#{doc_method(method)}`
		- Path:             `/v1/#{path}`
		- API Key:          `#{doc_api_key(api_key)}`
		- Required Access:  `#{doc_required_access(required_access)}`
		"""
	end

	defp doc_param(param), do: """
	| `#{String.downcase(param.name)}` | #{param.type_string} | #{doc_optional_default(param.optional, param.default)} | #{param.desc |> String.replace("\n", "<br>")} |
	"""

	defp doc_params(params), do: params |> Enum.map(&doc_param/1) |> Enum.join("")

	defp doc_optional_default(optional, default) do
		if optional do
			optional = "Yes"
			
			if default == nil do
				optional
			else
				optional <> "<br>(Default `#{inspect default}`)"
			end
		else
			"No"
		end
	end

	defp doc_method(method) do
		if !Enum.any?([:get, :post], fn supported -> method == supported end) do
			raise ArgumentError, message: "Bad method"
		end

		method |> Atom.to_string |> String.upcase
	end

	defp doc_api_key(nil), do: "No"
	defp doc_api_key(atm), do: atom_to_word(atm)

	defp doc_required_access(nil), do: "None"
	defp doc_required_access(atm), do: Atom.to_string(atm)

	defp atom_to_word(atm), do: atm |> Atom.to_string |> String.capitalize
end
