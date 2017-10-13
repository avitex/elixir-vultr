defmodule Vultr.Request do
	@moduledoc false

	@special_params [
		:subid, :dcid, :recordid, :vpsplanid, :appid, :osid,
		:isoid, :scriptid, :snapshotid, :sshkeyid, :backupid, :userid,
	]

	defmacro __using__(options) do
		module = __CALLER__.module

		Module.register_attribute(module, :__request_opts__, persist: true)
		Module.put_attribute(module, :__request_opts__, options)

		quote do
			import Vultr.Request, only: [request: 4]
		end
	end

	defmacro request(endpoint_method, endpoint_version, endpoint_path, endpoint_opts) do
		request_opts = Module.get_attribute(__CALLER__.module, :__request_opts__)
		base_url = Keyword.fetch!(request_opts, :base_url)
		
		endpoint_params = Keyword.get(endpoint_opts, :params, {nil, nil, []}) |> normalize_params
		endpoint_versioned_path = Path.join([endpoint_version, endpoint_path])
		endpoint_url = URI.merge(base_url, endpoint_versioned_path) |> to_string
		endpoint_description = Keyword.fetch!(endpoint_opts, :desc)
		endpoint_requires_api_key = Keyword.get(endpoint_opts, :api_key, nil)	
		endpoint_required_access = Keyword.get(endpoint_opts, :required_access, nil)
		endpoint_has_params = (length(endpoint_params) > 0)

		common_args = [endpoint_method, endpoint_url]

		func = &__MODULE__.perform_request/4

		func_name =
			endpoint_path
			|> String.replace("/", "_")
			|> String.to_atom

		func_doc = gen_doc(
			endpoint_method, endpoint_versioned_path, 
			endpoint_description, endpoint_params, 
			endpoint_required_access, endpoint_requires_api_key
		)

		func_body =
			cond do
				endpoint_requires_api_key && endpoint_has_params ->
					quote do
						def unquote(func_name)(api_key, params \\ []) when is_list(params) do
							unquote(func).(unquote_splicing(common_args), api_key, params)
						end
					end
				endpoint_requires_api_key ->
					quote do
						def unquote(func_name)(api_key) do
							unquote(func).(unquote_splicing(common_args), api_key, [])
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

	def perform_request(method, url, api_key, params) do
		headers = prepare_api_key_header(api_key)
		opts = [headers: headers] ++ prepare_params(method, params)
		resp = HTTPotion.request(method, url, opts)
		parsed_body = parse_body(resp)
		
		case resp.status_code do
			200 -> {:ok, parsed_body}
			400 -> {:error, :invalid_api_location, parsed_body}
			403 -> {:error, :invalid_api_key, parsed_body}
			405 -> {:error, :invalid_http_method, parsed_body}
			412 -> {:error, :bad_request, parsed_body}
			500 -> {:error, :server_error, parsed_body}
			503 -> {:error, :rate_limit, parsed_body}
		end
	end

	defp parse_body(%HTTPotion.Response{ body: body, headers: headers }) do
		case HTTPotion.Headers.fetch(headers, "content-type") do
			{:ok, "application/json"} ->
				Poison.decode!(body)
			_ ->
				body
		end
	end

	defp prepare_api_key_header(nil), do: []
	defp prepare_api_key_header(api_key), do: ["API-Key": api_key]

	defp prepare_params(:get, params), do: [query: prepare_query(params)]
	defp prepare_params(_, params), do: [body: prepare_body(params)]

	defp prepare_body(nil), do: ""
	defp prepare_body(params), do: capitalize_special_params(params) |> Enum.into(%{}) |> Poison.encode!

	defp prepare_query(nil), do: false
	defp prepare_query(params), do: capitalize_special_params(params)

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
		summary_table = doc_table([
			["Method", "Path", "API Key", "Required Access"],
			["------", "----", "-------", "---------------"],
			[doc_method(method), path, doc_api_key(api_key), doc_required_access(required_access)],
		])

		params_rows = Enum.map(params, &[
			"`#{String.downcase(&1.name)}`",
			&1.type_string,
			doc_optional_default(&1.optional, &1.default),
			String.replace(&1.desc, "\n", "<br>"),
		])

		params_table = doc_table([
			["Name", "Type", "Optional", "Description"],
			["----", "----", "--------", "-----------"],
		] ++ params_rows)

		"""
		#{desc}
		#{summary_table}
		#### Params
		#{params_table}
		"""
	end

	defp doc_optional_default(optional, default) do
		cond do
			optional && is_nil(default) ->
				"Yes"
			optional ->
				"<br>(Default `#{inspect default}`)"
			true ->
				"No"
		end
	end

	defp doc_method(method), do: method |> Atom.to_string |> String.upcase

	defp doc_api_key(nil), do: "No"
	defp doc_api_key(atm), do: atom_to_word(atm)

	defp doc_required_access(nil), do: "None"
	defp doc_required_access(atm), do: Atom.to_string(atm)

	defp doc_table(rows), do: Enum.map(rows, &doc_table_columns/1) |> Enum.join
	
	defp doc_table_columns(columns), do: "| #{Enum.join(columns, " | ")} |\n"

	defp atom_to_word(atm), do: atm |> Atom.to_string |> String.capitalize
end
