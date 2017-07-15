defmodule Vultr do
	use Tesla, docs: false
	use Vultr.Request

	plug Tesla.Middleware.BaseUrl, "https://api.vultr.com/v1"
	plug Tesla.Middleware.FormUrlencoded
	plug Tesla.Middleware.DecodeJson

	adapter :ibrowse

	def client(api_key) do
		Tesla.build_client [
			{Tesla.Middleware.Headers, %{ "API-Key" => api_key }}
		]
	end

	##################################################
	# Account

	request :get, "account/info", [
		desc: """
		Retrieve information about the current account.
		""",
		api_key: :required,
		required_access: :billing,
	]

	##################################################
	# Application

	request :get, "app/list", [
		desc: """
		Retrieve a list of available applications.

		These refer to applications that can be launched when creating a Vultr VPS.
		""",
	]

	##################################################
	# API Key

	request :get, "auth/info", [
		desc: """
		Retrieve information about the current API key.
		""",
		api_key: :required,
	]

	##################################################
	# Backup

	request :get, "backup/list", [
		desc: """
		List all backups on the current account.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				optional: true,
				desc: """
				Unique identifier of a subscription.
				Only backups for this subscription object will be returned.
				""",
			],
		},
	]

	##################################################
	# Block Storage

	request :post, "block/attach", [
		desc: """
		Attach a block storage subscription to a VPS subscription.

		The block storage volume must not be attached to any other VPS subscriptions for this to work.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				ID of the block storage subscription to attach.
				""",
			],
			"attach_to_SUBID" => [
				type: :integer,
				desc: """
				ID of the VPS subscription to mount the block storage subscription to.
				""",
			],
		},
	]

	request :post, "block/create", [
		desc: """
		Create a block storage subscription.
		""",
		api_key: :required,
		required_access: :provisioning,
		params: %{
			"DCID" => [
				type: :integer,
				desc: """
				DCID of the location to create this subscription in.
				See `regions_list`.
				""",
			],
			"label" => [
				type: :string,
				optional: true,
				desc: """
				Text label that will be associated with the subscription.
				""",
			],
			"size_gb" => [
				type: :integer,
				desc: """
				Size (in GB) of this subscription.
				""",
			],
		},
	]

	request :post, "block/delete", [
		desc: """
		Delete a block storage subscription.

		All data will be permanently lost.
		There is no going back from this call.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				ID of the block storage subscription to delete.
				""",
			],
		},
	]

	request :post, "block/detach", [
		desc: """
		Detach a block storage subscription from the currently attached instance.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				ID of the block storage subscription to detach.
				""",
			],
		},
	]

	request :post, "block/label_set", [
		desc: """
		Set the label of a block storage subscription.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				ID of the block storage subscription to detach.
				""",
			],
			"label" => [
				type: :string,
				desc: """
				Text label that will be shown in the control panel.
				""",
			],
		},
	]

	request :get, "block/list", [
		desc: """
		Retrieve a list of any active block storage subscriptions on this account.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				optional: true,
				desc: """
				Unique identifier of a subscription.
				Only the subscription object will be returned.
				""",
			],
		},
	]

	request :post, "block/resize", [
		desc: """
		Resize the block storage volume to a new size.

		**WARNING**: When shrinking the volume, you must manually shrink the filesystem and partitions beforehand, or you will lose data.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				ID of the block storage subscription to resize.
				""",
			],
			"size_gb" => [
				type: :integer,
				desc: """
				New size (in GB) of the block storage subscription.
				""",
			],
		},
	]

	##################################################
	# DNS

	request :post, "dns/create_domain", [
		desc: """
		Create a domain name in DNS.
		""",
		api_key: :required,
		required_access: :dns,
		params: %{
			"domain" => [
				type: :string,
				desc: """
				Domain name to create.
				""",
			],
			"serverip" => [
				type: :string,
				desc: """
				Server IP to use when creating default records (A and MX).
				""",
			],
		},
	]

	request :post, "dns/create_record", [
		desc: """
		Add a DNS record.
		""",
		api_key: :required,
		required_access: :dns,
		params: %{
			"data" => [
				type: :string,
				desc: """
				Data for this record.
				""",
			],
			"domain" => [
				type: :string,
				desc: """
				Domain name to add record to.
				""",
			],
			"name" => [
				type: :string,
				desc: """
				Name (subdomain) of record.
				""",
			],
			"priority" => [
				type: :integer,
				desc: """
				(only required for MX and SRV) Priority of this record (omit the priority from the data).
				""",
			],
			"ttl" => [
				type: :integer,
				optional: true,
				desc: """
				TTL of this record.
				""",
			],
			"type" => [
				type: :string,
				desc: """
				Type (A, AAAA, MX, etc) of record.
				""",
			],
		},
	]

	request :post, "dns/delete_domain", [
		desc: """
		Delete a domain name and all associated records.
		""",
		api_key: :required,
		required_access: :dns,
		params: %{
			"domain" => [
				type: :string,
				desc: """
				Domain name to delete.
				""",
			],
		},
	]

	request :post, "dns/delete_record", [
		desc: """
		Delete an individual DNS record.
		""",
		api_key: :required,
		required_access: :dns,
		params: %{
			"RECORDID" => [
				type: :integer,
				desc: """
				ID of record to delete.
				See `dns_records`.
				""",
			],
			"domain" => [
				type: :string,
				desc: """
				Domain name to delete record from.
				""",
			],
		},
	]

	request :get, "dns/list", [
		desc: """
		List all domains associated with the current account.
		""",
		api_key: :required,
		required_access: :dns,
	]

	request :get, "dns/records", [
		desc: """
		List all the records associated with a particular domain.
		""",
		api_key: :required,
		required_access: :dns,
		params: %{
			"domain" => [
				type: :string,
				desc: """
				Domain to list records for.
				""",
			],
		},
	]

	request :post, "dns/update_record", [
		desc: """
		Update a DNS record.
		""",
		api_key: :required,
		required_access: :dns,
		params: %{
			"RECORDID" => [
				type: :integer,
				desc: """
				ID of record to update.
				See `dns_records`.
				""",
			],
			"data" => [
				type: :string,
				optional: true,
				desc: """
				Data for this record.
				""",
			],
			"domain" => [
				type: :string,
				desc: """
				Domain name of record to update.
				""",
			],
			"name" => [
				type: :string,
				optional: true,
				desc: """
				Name (subdomain) of record.
				""",
			],
			"priority" => [
				type: :integer,
				optional: true,
				desc: """
				(only required for MX and SRV) Priority of this record (omit the priority from the data).
				""",
			],
			"ttl" => [
				type: :string,
				optional: true,
				desc: """
				TTL of this record.
				""",
			],
		},
	]

	##################################################
	# ISO Image

	request :get, "iso/list", [
		desc: """
		List all ISOs currently available on this account.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	##################################################
	# Operating System

	request :get, "os/list", [
		desc: """
		Retrieve a list of available operating systems.

		If the `windows` flag is true, a Windows license will be included with the instance, which will increase the cost.
		""",
	]

	##################################################
	# Plans

	request :get, "plans/list", [
		desc: """
		Retrieve a list of all active plans. Plans that are no longer available will not be shown.
		
		The `windows` field is no longer in use, and will always be false.
		Windows licenses will be automatically added to any plan as necessary.
		
		The `deprecated` field indicates that the plan will be going away in the future.
		New deployments of it will still be accepted, but you should begin to transition away from it's usage.
		Typically, deprecated plans are available for 30 days after they are deprecated.
		""",
		params: %{
			"type" => [
				type: :string,
				optional: true,
				desc: """
				The type of plans to return.
				Possible values: 'all', 'vc2', 'ssd', 'vdc2', 'dedicated'.
				""",
			],
		},
	]

	request :get, "plans/list_vc2", [
		desc: """
		Retrieve a list of all active vc2 plans. Plans that are no longer available will not be shown.
		
		The `deprecated` field indicates that the plan will be going away in the future.
		New deployments of it will still be accepted, but you should begin to transition away from it's usage.
		Typically, deprecated plans are available for 30 days after they are deprecated.
		""",
	]

	request :get, "plans/list_vdc2", [
		desc: """
		Retrieve a list of all active vdc2 plans. Plans that are no longer available will not be shown.
		
		The `deprecated` field indicates that the plan will be going away in the future.
		New deployments of it will still be accepted, but you should begin to transition away from it's usage.
		Typically, deprecated plans are available for 30 days after they are deprecated.
		""",
	]

	##################################################
	# Regions

	request :get, "regions/availability", [
		desc: """
		Retrieve a list of the `VPSPLANID`s currently available in this location.
		
		If your account has special plans available, you will need to pass your API key in in order to see them.
		For all other accounts, the API key is not optional.
		""",
		api_key: :optional,
		params: %{
			"DCID" => [
				type: :integer,
				desc: """
				Retrieve a list of the `VPSPLANID`s currently available in this location.
				""",
			],
		},
	]

	request :get, "regions/list", [
		desc: """
		Retrieve a list of all active regions.

		Note that just because a region is listed here, does not mean that there is room for new servers.
		""",
	]

	##################################################
	# Reserved IP

	request :post, "reservedip/attach", [
		desc: """
		Attach a reserved IP to an existing subscription.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"attach_SUBID" => [
				type: :integer,
				desc: """
				Unique indentifier of the server to attach the reserved IP to.
				""",
			],
			"ip_address" => [
				type: :string,
				desc: """
				Reserved IP to attach to your account (use the full subnet here).
				""",
			],
		},
	]

	request :post, "reservedip/convert", [
		desc: """
		Convert an existing IP on a subscription to a reserved IP.

		Returns the `SUBID` of the newly created reserved IP.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				`SUBID` of the server that currently has the IP address you want to convert.
				""",
			],
			"ip_address" => [
				type: :string,
				desc: """
				IP address you want to convert (v4 must be a /32, v6 must be a /64).
				""",
			],
			"label" => [
				type: :string,
				optional: true,
				desc: """
				Label for this reserved IP.
				""",
			],
		},
	]

	request :post, "reservedip/create", [
		desc: """
		Create a new reserved IP.

		Reserved IPs can only be used within the same datacenter for which they were created.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"DCID" => [
				type: :integer,
				desc: """
				Location to create this reserved IP in.
				See `regions_list`.
				""",
			],
			"ip_type" => [
				type: :string,
				desc: """
				Type of reserved IP to create.
				Either 'v4' or 'v6'.
				""",
			],
			"label" => [
				type: :string,
				optional: true,
				desc: """
				Label for this reserved IP.
				""",
			],
		},
	]

	request :post, "reservedip/destroy", [
		desc: """
		Remove a reserved IP from your account.

		After making this call, you will not be able to recover the IP address.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"ip_address" => [
				type: :string,
				desc: """
				Reserved IP to remove from your account.
				""",
			],
		},
	]

	request :post, "reservedip/detach", [
		desc: """
		Detach a reserved IP from an existing subscription.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"detach_SUBID" => [
				type: :integer,
				desc: """
				Unique identifier of the server to detach the reserved IP from.
				""",
			],
			"ip_address" => [
				type: :string,
				desc: """
				Reserved IP to attach to your account (use the full subnet here).
				""",
			],
		},
	]

	request :get, "reservedip/list", [
		desc: """
		List all the active reserved IPs on this account.

		The `subnet_size` field is the size of the network assigned to this subscription.
		This will typically be a /64 for IPv6, or a /32 for IPv4.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	##################################################
	# Server

	request :post, "server/app_change", [
		desc: """
		Changes the virtual machine to a different application.

		All data will be permanently lost.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"APPID" => [
				type: :integer,
				desc: """
				Application to use.
				See `server_app_change_list`.
				""",
			],
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :get, "server/app_change_list", [
		desc: """
		Retrieves a list of applications to which a virtual machine can be changed.

		Always check against this list before trying to switch applications because it is not possible to switch between every application combination.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/backup_disable", [
		desc: """
		Disables automatic backups on a server.

		Once disabled, backups can only be enabled again by customer support.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/backup_enable", [
		desc: """
		Enables automatic backups on a server.
		""",
		api_key: :required,
		required_access: :upgrade,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/backup_get_schedule", [
		desc: """
		Retrieves the backup schedule for a server.

		All time values are in UTC.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/backup_set_schedule", [
		desc: """
		Sets the backup schedule for a server.

		All time values are in UTC.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"cron_type" => [
				type: :string,
				desc: """
				Backup cron type.
				Can be one of 'daily', 'weekly', or 'monthly'.
				""",
			],
			"dom" => [
				type: :integer,
				optional: true,
				desc: """
				Day-of-month value (1-28).
				Applicable to crons: 'monthly'.
				""",
			],
			"dow" => [
				type: :integer,
				optional: true,
				desc: """
				Day-of-week value (0-6).
				Applicable to crons: 'weekly'.
				""",
			],
			"hour" => [
				type: :integer,
				optional: true,
				desc: """
				Hour value (0-23).
				Applicable to crons: 'daily', 'weekly', 'monthly'.
				""",
			],
		},
	]

	request :get, "server/bandwidth", [
		desc: """
		Get the bandwidth used by a virtual machine.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/create", [
		desc: """
		Create a new virtual machine.

		You will start being billed for this immediately.
		The response only contains the `SUBID` for the new machine.
		
		You should use `server_list` to poll and wait for the machine to be created (as this does not happen instantly).
		""",
		api_key: :required,
		required_access: :provisioning,
		params: %{
			"APPID" => [
				type: :integer,
				optional: true,
				desc: """
				If launching an application (OSID 186), this is the `APPID` to launch.
				See `app_list`.
				""",
			],
			"DCID" => [
				type: :integer,
				desc: """
				Location to create this virtual machine in. 
				See `regions_list`.
				""",
			],
			"ISOID" => [
				type: :integer,
				optional: true,
				desc: """
				If you've selected the 'custom' operating system, this is the ID of a specific ISO to mount during the deployment.
				""",
			],
			"OSID" => [
				type: :integer,
				desc: """
				Operating system to use.
				See `os_list`.
				""",
			],
			"SCRIPTID" => [
				type: :integer,
				optional: true,
				desc: """
				If you've not selected a 'custom' operating system, this can be the `SCRIPTID` of a startup script to execute on boot.
				See `startupscript_list`.
				""",
			],
			"SNAPSHOTID" => [
				type: :string,
				optional: true,
				desc: """
				If you've selected the 'snapshot' operating system, this should be the `SNAPSHOTID` to restore for the initial installation.
				See `snapshot_list`.
				""",
			],
			"SSHKEYID" => [
				type: :string,
				optional: true,
				desc: """
				Comma delimited list of SSH keys to apply to this server on install (only valid for Linux/FreeBSD).
				See `sshkey_list`.
				""",
			],
			"VPSPLANID" => [
				type: :integer,
				desc: """
				Plan to use when creating this virtual machine.
				See `plans_list`.
				""",
			],
			"auto_backups" => [
				type: :yes_no,
				optional: true,
				desc: """
				Whether or not automatic backups will be enabled for this server (these have an extra charge associated with them).
				""",
			],
			"ddos_protection" => [
				type: :yes_no,
				default: "no",
				optional: true,
				desc: """
				Whether or not DDOS protection will be enabled on the subscription (there is an additional charge for this).
				""",
			],
			"enable_ipv6" => [
				type: :yes_no,
				optional: true,
				desc: """
				Whether or not an IPv6 subnet will be assigned to the machine (where available).
				""",
			],
			"enable_private_network" => [
				type: :yes_no,
				optional: true,
				desc: """
				Whether or not private networking support will be added to the new server.
				""",
			],
			"hostname" => [
				type: :string,
				optional: true,
				desc: """
				The hostname to assign to this server.
				""",
			],
			"ipxe_chain_url" => [
				type: :string,
				optional: true,
				desc: """
				If you've selected the 'custom' operating system, this can be set to chainload the specified URL on bootup, via iPXE.
				""",
			],
			"label" => [
				type: :string,
				optional: true,
				desc: """
				This is a text label that will be shown in the control panel.
				""",
			],
			"notify_activate" => [
				type: :yes_no,
				default: "yes",
				optional: true,
				desc: """
				Whether or not an activation email will be sent when the server is ready.
				""",
			],
			"reserved_ip_v4" => [
				type: :string,
				optional: true,
				desc: """
				IP address of the floating IP to use as the main IP of this server
				""",
			],
			"tag" => [
				type: :string,
				optional: true,
				desc: """
				The tag to assign to this server.
				""",
			],
			"userdata" => [
				type: :string,
				optional: true,
				desc: """
				Base64 encoded cloud-init user-data.
				""",
			],
		},
	]

	request :post, "server/create_ipv4", [
		desc: """
		Add a new IPv4 address to a server.

		You will start being billed for this immediately.
		The server will be rebooted unless you specify otherwise.
		You must reboot the server before the IPv4 address can be configured.
		""",
		api_key: :required,
		required_access: :upgrade,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"reboot" => [
				type: :yes_no,
				default: "yes",
				optional: true,
				desc: """
				Whether or not the server is rebooted immediately.
				""",
			],
		},
	]

	request :post, "server/destroy", [
		desc: """
		Destroy (delete) a virtual machine.

		All data will be permanently lost, and the IP address will be released.
		There is no going back from this call.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/destroy_ipv4", [
		desc: """
		Removes a secondary IPv4 address from a server.

		Your server will be hard-restarted.
		We suggest halting the machine gracefully before removing IPs.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :get, "server/get_app_info", [
		desc: """
		Retrieves the application information for this subscription.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :get, "server/get_user_data", [
		desc: """
		Retrieves the (base64 encoded) user-data for this subscription.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/halt", [
		desc: """
		Halt a virtual machine. This is a hard power off (basically, unplugging the machine).

		The data on the machine will not be modified, and you will still be billed for the machine.
		To completely delete a machine, see `server_destroy`.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/iso_attach", [
		desc: """
		Attach an ISO and reboot the server.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"ISOID" => [
				type: :integer,
				desc: """
				The ISO that will be mounted.
				See `iso_list`.
				""",
			],
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/iso_detach", [
		desc: """
		Detach the currently mounted ISO and reboot the server.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :get, "server/iso_status", [
		desc: """
		Retrieve the current ISO state for a given subscription.

		The returned state may be 'ready', 'isomounting' or 'isomounted'.
		`ISOID` will only be set when the mounted ISO exists in your library ( see `iso_list` ), otherwise it will read '0'.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/label_set", [
		desc: """
		Set the label of a virtual machine.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"label" => [
				type: :string,
				desc: """
				This is a text label that will be shown in the control panel.
				""",
			],
		},
	]

	request :get, "server/list", [
		desc: """
		List all active or pending virtual machines on the current account.
		
		The 'status' field represents the status of the subscription and will be 'pending', 'active', 'suspended' or 'closed'.
		If the status is 'active', you can check `power_status` to determine if the VPS is powered on or not.
		When status is 'active', you may also use `server_state` for a more detailed status of 'none', 'locked', 'installingbooting', 'isomounting' or 'ok'.
		
		The API does not provide any way to determine if the initial installation has completed or not.
		The `v6_network`, `v6_main_ip`, and `v6_network_size` fields are deprecated in favor of `v6_networks`.
		
		If you need to filter the list, review the parameters for this function.
		Currently, only one filter at a time may be applied (`SUBID`, `tag`, `label`, `main_ip`).
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				optional: true,
				desc: """
				Unique identifier of a subscription.
				Only the subscription object will be returned.
				""",
			],
			"label" => [
				type: :string,
				optional: true,
				desc: """
				A text label string.
				Only subscription objects with this text label will be returned.
				""",
			],
			"main_ip" => [
				type: :string,
				optional: true,
				desc: """
				An IPv4 address.
				Only the subscription matching this IPv4 address will be returned.
				""",
			],
			"tag" => [
				type: :string,
				optional: true,
				desc: """
				A tag string.
				Only subscription objects with this tag will be returned.
				""",
			],
		},
	]

	request :get, "server/list_ipv4", [
		desc: """
		List the IPv4 information of a virtual machine.

		IP information is only available for virtual machines in the 'active' state.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	request :get, "server/list_ipv6", [
		desc: """
		List the IPv6 information of a virtual machine.

		IP information is only available for virtual machines in the 'active' state.
		If the virtual machine does not have IPv6 enabled, then an empty array is returned.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	request :get, "server/neighbors", [
		desc: """
		Determine what other subscriptions are hosted on the same physical host as a given subscription.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/os_change", [
		desc: """
		Changes the virtual machine to a different operating system.

		All data will be permanently lost.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"OSID" => [
				type: :integer,
				desc: """
				Operating system to use.
				See `server_os_change_list`.
				""",
			],
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :get, "server/os_change_list", [
		desc: """
		Retrieves a list of operating systems to which a virtual machine can be changed.

		Always check against this list before trying to switch operating systems.
		because it is not possible to switch between every operating system combination.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/reboot", [
		desc: """
		Reboot a virtual machine.

		This is a hard reboot (basically, unplugging the machine).
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/reinstall", [
		desc: """
		Reinstall the operating system on a virtual machine.

		All data will be permanently lost, but the IP address will remain the same.
		There is no going back from this call.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"hostname" => [
				type: :string,
				optional: true,
				desc: """
				The hostname to assign to this server.
				""",
			],
		},
	]

	request :post, "server/restore_backup", [
		desc: """
		Restore the specified backup to the virtual machine.

		Any data already on the virtual machine will be lost.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"BACKUPID" => [
				type: :string,
				desc: """
				`BACKUPID` to restore to this instance.
				See `backup_list`.
				""",
			],
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/restore_snapshot", [
		desc: """
		Restore the specified snapshot to the virtual machine.

		Any data already on the virtual machine will be lost.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"BACKUPID" => [
				type: :string,
				desc: """
				`SNAPSHOTID` to restore to this instance.
				See `snapshot_list`.
				""",
			],
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/reverse_default_ipv4", [
		desc: """
		Set a reverse DNS entry for an IPv4 address of a virtual machine to the original setting.

		Upon success, DNS changes may take 6-12 hours to become active.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"ip" => [
				type: :string,
				desc: """
				IPv4 address used in the reverse DNS update.
				See `server_list_ipv4`.
				""",
			],
		},
	]

	request :post, "server/reverse_delete_ipv6", [
		desc: """
		Remove a reverse DNS entry for an IPv6 address of a virtual machine.

		Upon success, DNS changes may take 6-12 hours to become active.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"ip" => [
				type: :string,
				desc: """
				IPv6 address used in the reverse DNS update.
				See `server_list_ipv6`.
				""",
			],
		},
	]

	request :get, "server/reverse_list_ipv6", [
		desc: """
		List the IPv6 reverse DNS entries of a virtual machine.

		Reverse DNS entries are only available for virtual machines in the 'active' state.
		If the virtual machine does not have IPv6 enabled, then an empty array is returned.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/reverse_set_ipv4", [
		desc: """
		Set a reverse DNS entry for an IPv4 address of a virtual machine.

		Upon success, DNS changes may take 6-12 hours to become active.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"entry" => [
				type: :string,
				desc: """
				Reverse DNS entry.
				""",
			],
			"ip" => [
				type: :string,
				desc: """
				IPv4 address used in the reverse DNS update.
				See `server_list_ipv4`.
				""",
			],
		},
	]

	request :post, "server/reverse_set_ipv6", [
		desc: """
		Set a reverse DNS entry for an IPv6 address of a virtual machine.

		Upon success, DNS changes may take 6-12 hours to become active.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"entry" => [
				type: :string,
				desc: """
				Reverse DNS entry.
				""",
			],
			"ip" => [
				type: :string,
				desc: """
				IPv6 address used in the reverse DNS update.
				See `server_list_ipv6`.
				""",
			],
		},
	]

	request :post, "server/set_user_data", [
		desc: """
		Sets the cloud-init user-data for this subscription.

		Note that user-data is not supported on every operating system, and is generally only provided on instance startup.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"userdata" => [
				type: :string,
				desc: """
				Base64 encoded cloud-init user-data.
				""",
			],
		},
	]

	request :post, "server/start", [
		desc: """
		Start a virtual machine.

		If the machine is already running, it will be restarted.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	request :post, "server/upgrade_plan", [
		desc: """
		Upgrade the plan of a virtual machine.

		The virtual machine will be rebooted upon a successful upgrade.
		""",
		api_key: :required,
		required_access: :upgrade,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"VPSPLANID" => [
				type: :integer,
				desc: """
				The new plan.
				See `server_upgrade_plan_list`.
				""",
			],
		},
	]

	request :post, "server/upgrade_plan_list", [
		desc: """
		Retrieve a list of the VPSPLANIDs for which a virtual machine can be upgraded.

		An empty response array means that there are currently no upgrades available.
		""",
		api_key: :required,
		required_access: :upgrade,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
		},
	]

	##################################################
	# Snapshot

	request :post, "snapshot/create", [
		desc: """
		Create a snapshot from an existing virtual machine.

		The virtual machine does not need to be stopped.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SUBID" => [
				type: :integer,
				desc: """
				Unique identifier for this subscription.
				See `server_list`.
				""",
			],
			"description" => [
				type: :string,
				optional: true,
				desc: """
				Description of snapshot contents.
				""",
			],
		},
	]

	request :post, "snapshot/destroy", [
		desc: """
		Destroy (delete) a snapshot.

		There is no going back from this call.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SNAPSHOTID" => [
				type: :integer,
				desc: """
				Unique identifier for this snapshot.
				See `snapshot_list`.
				""",
			],
		},
	]

	request :get, "snapshot/list", [
		desc: """
		List all snapshots on the current account.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	##################################################
	# SSH Key

	request :post, "sshkey/create", [
		desc: """
		Create a new SSH Key.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"name" => [
				type: :string,
				desc: """
				Name of the SSH key.
				""",
			],
			"ssh_key" => [
				type: :string,
				desc: """
				SSH public key (in authorized_keys format).
				""",
			],
		},
	]

	request :post, "sshkey/destroy", [
		desc: """
		Remove a SSH key.

		Note that this will not remove the key from any machines that already have it.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SSHKEYID" => [
				type: :string,
				desc: """
				Unique identifier for this SSH key.
				See `sshkey_list`.
				""",
			],
		},
	]

	request :get, "sshkey/list", [
		desc: """
		List all the SSH keys on the current account.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	request :post, "sshkey/update", [
		desc: """
		Update an existing SSH Key.

		Note that this will only update newly installed machines.
		The key will not be updated on any existing machines.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SSHKEYID" => [
				type: :string,
				desc: """
				`SSHKEYID` of key to update.
				See `sshkey_list`.
				""",
			],
			"name" => [
				type: :string,
				optional: true,
				desc: """
				New name for the SSH key.
				""",
			],
			"ssh_key" => [
				type: :string,
				optional: true,
				desc: """
				New SSH key contents.
				""",
			],
		},
	]

	##################################################
	# Startup Script

	request :post, "startupscript/create", [
		desc: """
		Create a startup script.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"name" => [
				type: :string,
				desc: """
				Name of the newly created startup script.
				""",
			],
			"script" => [
				type: :string,
				desc: """
				Startup script contents.
				""",
			],
			"type" => [
				type: :string,
				optional: true,
				desc: """
				Type of startup script.
				Either boot or pxe.
				""",
			],
		},
	]

	request :post, "startupscript/destroy", [
		desc: """
		Remove a startup script.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SCRIPTID" => [
				type: :string,
				desc: """
				Unique identifier for this startup script.
				""",
			],
		},
	]

	request :get, "startupscript/list", [
		desc: """
		List all startup scripts on the current account.
		
		Scripts of type 'boot' are executed by the server's operating system on the first boot.
		Scripts of type 'pxe' are executed by iPXE when the server itself starts up.
		""",
		api_key: :required,
		required_access: :subscriptions,
	]

	request :post, "startupscript/update", [
		desc: """
		Update an existing startup script.
		""",
		api_key: :required,
		required_access: :subscriptions,
		params: %{
			"SCRIPTID" => [
				type: :string,
				desc: """
				`SCRIPTID` of script to update
				See `startupscript_list`.
				""",
			],
			"name" => [
				type: :string,
				optional: true,
				desc: """
				New name for the startup script.
				""",
			],
			"script" => [
				type: :string,
				optional: true,
				desc: """
				New startup script contents.
				""",
			],
		},
	]

	##################################################
	# User Management

	request :post, "user/create", [
		desc: """
		Create a new user.
		""",
		api_key: :required,
		required_access: :manage_users,
		params: %{
			"acls" => [
				type: :array,
				desc: """
				List of ACLs that this user should have.
				See `user_list` for information on possible ACLs.
				""",
			],
			"api_enabled" => [
				type: :yes_no,
				desc: """
				Whether or not this user's API key will work on `api.vultr.com`.
				""",
			],
			"email" => [
				type: :string,
				desc: """
				Email address for this user.
				""",
			],
			"name" => [
				type: :string,
				desc: """
				Name for this user.
				""",
			],
			"password" => [
				type: :string,
				desc: """
				Password for this user.
				""",
			],
		},
	]

	request :post, "user/delete", [
		desc: """
		Delete a user.
		""",
		api_key: :required,
		required_access: :manage_users,
		params: %{
			"USERID" => [
				type: :integer,
				desc: """
				ID of the user to delete.
				""",
			],
		},
	]

	request :get, "user/list", [
		desc: """
		Retrieve a list of any users associated with this account.
		
		ACLs will contain one or more of the following flags:

		- `manage_users`: Create, update, and delete other users. This will basically grant them all other permissions
		- `subscriptions`: Destroy and update any existing subscriptions (also supporting things, such as ISOs and SSH keys)
		- `provisioning`: Deploy new instances. Note this ACL requires the subscriptions ACL
		- `billing`: Manage and view billing information (invoices, payment methods)
		- `support`: Create and update support tickets. Users with this flag will be CC'd on any support interactions
		- `abuse`: If enabled on any user, only users with this flag enabled will receive abuse notifications (requires support flag)
		- `dns`: Create, update, and delete any forward DNS records (reverse is controlled by the subscriptions flag)
		- `upgrade`: If enabled, this user will be allowed to upgrade an instance's plan, or add paid features (such as DDOS protection or backups)
		""",
		api_key: :required,
		required_access: :manage_users,
	]

	request :post, "user/update", [
		desc: """
		Update the details for a user.
		""",
		api_key: :required,
		required_access: :manage_users,
		params: %{
			"USERID" => [
				type: :integer,
				desc: """
				ID of the user to update.
				""",
			],
			"acls" => [
				type: :array,
				optional: true,
				desc: """
				List of ACLs that this user should have.
				See `user_list` for information on possible ACLs.
				"""
			],
			"api_enabled" => [
				type: :yes_no,
				optional: true,
				desc: """
				Whether or not this user's API key will work on `api.vultr.com`.
				""",
			],
			"email" => [
				type: :string,
				optional: true,
				desc: """
				New email address for this user.
				""",
			],
			"name" => [
				type: :string,
				optional: true,
				desc: """
				New name for this user.
				""",
			],
			"password" => [
				type: :string,
				optional: true,
				desc: """
				New password for this user.
				""",
			],
		},
	]
end