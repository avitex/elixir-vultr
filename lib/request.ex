defmodule Vultr.Request do

	#@SPECIAL_PARAMS ["SUBID", "DCID", "RECORDID", "VPSPLANID", "APPID", "OSID", "ISOID", "SCRIPTID", "SNAPSHOTID", "SSHKEYID", "BACKUPID", "USERID"]

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

		request_client_var = Macro.var(:client, nil)
		request_params_var = Macro.var(:params, nil)

		function_args =
			cond do
				endpoint_requires_api_key && endpoint_has_params ->
					[request_client_var, request_params_var]
				endpoint_requires_api_key ->
					[request_client_var]
				endpoint_has_params ->
					[request_params_var]
				true ->
					[]
			end

		tesla_args =
			if endpoint_requires_api_key do
				[request_client_var]
			else
				[]
			end

		tesla_args =
			if endpoint_method === :get && endpoint_has_params do
				tesla_args ++ [quote do
					unquote(endpoint_path) <> "?" <> URI.encode_query(unquote(request_params_var))
				end]
			else
				tesla_args ++ [quote do
					unquote(endpoint_path)
				end]
			end
		
		tesla_args =
			if endpoint_method !== :get && endpoint_has_params do
				tesla_args ++ [request_params_var]
			else
				tesla_args
			end

		quote do
			@doc unquote(documentation(endpoint_method, endpoint_path, endpoint_description, endpoint_params, endpoint_required_access, endpoint_requires_api_key))
			def unquote(function_name(endpoint_path))(unquote_splicing(function_args)) do
				unquote(endpoint_method)(unquote_splicing(tesla_args))
			end
		end
	end

	defp function_name(path), do: path |> String.replace("/", "_") |> String.to_atom

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

	defp documentation(method, path, desc, params, required_access, api_key) do
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

	defp doc_api_key(nil), do: "No"
	defp doc_api_key(atm), do: atom_to_word(atm)

	defp doc_required_access(nil), do: "None"
	defp doc_required_access(atm), do: Atom.to_string(atm)
	
	defp atom_to_word(atm), do: atm |> Atom.to_string |> String.capitalize

	defp doc_method(method) do
		if !Enum.any?([:get, :post], fn supported -> method == supported end) do
			raise ArgumentError, message: "Bad method"
		end

		method |> Atom.to_string |> String.upcase()
	end
end