rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+space>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
rex.bind("ctrl+space>r", "client.config.reload")
rex.bind("ctrl+space>-", "pane.split", { direction = "down" })
rex.bind("ctrl+space>v", "pane.split", { direction = "right" })
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("ctrl+space>k", "pane.focus", { direction = "up" })
rex.bind("repeat/k", "pane.focus", { direction = "up" })
rex.bind("ctrl+space>j", "pane.focus", { direction = "down" })
rex.bind("repeat/j", "pane.focus", { direction = "down" })
rex.bind("ctrl+space>h", "pane.focus", { direction = "left" })
rex.bind("repeat/h", "pane.focus", { direction = "left" })
rex.bind("ctrl+space>l", "pane.focus", { direction = "right" })
rex.bind("repeat/l", "pane.focus", { direction = "right" })
rex.bind("ctrl+space>f", "client.tab.new")

rex.bind("ctrl+1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+6", "client.tab.goto", { index = 6 })

local function sessionizer_layer(view)
	if type(view) ~= "table" then
		return nil
	end
	for _, window in ipairs(view.windows or {}) do
		for _, layer in ipairs(window.layers or {}) do
			if layer.kind == "floating" then
				for _, block in ipairs(layer.blocks or {}) do
					if block.label == "sessionizer" then
						return layer.layer_id
					end
				end
			end
		end
	end
	return nil
end

-- Keys give the app as ctx.client_id. rex do from nvim gives the CLI.
local function app_client(session_id, preferred)
	local listed = rex.call("client.list")
	if type(listed) ~= "table" then
		return preferred
	end
	local apps = {}
	for _, client in ipairs(listed.clients or {}) do
		local info = client.info or {}
		local state = client.connection_state or "connected"
		if info.kind == "app" and state == "connected" and client.client_id ~= nil then
			apps[#apps + 1] = client
		end
	end
	if preferred ~= nil and preferred ~= "" then
		for _, client in ipairs(apps) do
			if client.client_id == preferred then
				return preferred
			end
		end
	end
	local fallback = nil
	for _, client in ipairs(apps) do
		if fallback == nil then
			fallback = client.client_id
		end
		for _, sid in ipairs(client.session_ids or {}) do
			if sid == session_id then
				return client.client_id
			end
		end
	end
	return fallback or preferred
end

rex.action({
	name = "sessionizer",
	title = "Sessionizer",
	description = "Open or enter a session from a project folder",
	run = function(ctx, _)
		local view = rex.session.view({})
		local layer_id = sessionizer_layer(view)
		if layer_id ~= nil then
			local _, err = rex.session.set_layer_state({
				layer_id = layer_id,
				state = "normal",
				focus = true,
			})
			if err ~= nil then
				error(err, 0)
			end
			return
		end

		local command = { "rex-sessionizer" }
		local client_id = app_client(ctx.session_id, ctx.client_id)
		if client_id ~= nil and client_id ~= "" then
			command[#command + 1] = "--client"
			command[#command + 1] = client_id
		end

		local created, err = rex.session.new_layer({
			bounds = { 0.15, 0.18, 0.70, 0.64 },
			focus = true,
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = {
					command = command,
					path_prepend = { (os.getenv("HOME") or "") .. "/.local/scripts" },
				},
			}),
		})
		if err ~= nil then
			error(err, 0)
		end

		local block_id = created and created.block_ids and created.block_ids[1]
		if block_id ~= nil then
			rex.session.set_block_label({ block_id = block_id, label = "sessionizer" })
		end
	end,
})

rex.action({
	name = "split_auto",
	title = "Split Auto",
	description = "Split right when the pane is wider than it is tall, otherwise down",
	run = function(_, _)
		local direction = "right"
		local size = rex.block.call("com.superlogical.terminal", "size")
		if type(size) == "table"
			and size.columns
			and size.rows
			and size.cell_width_px
			and size.cell_height_px
			and size.cell_width_px > 0
			and size.cell_height_px > 0
		then
			local width = size.columns * size.cell_width_px
			local height = size.rows * size.cell_height_px
			if height > width then
				direction = "down"
			end
		end
		rex.client.queue("pane.split", { direction = direction })
	end,
})

rex.bind("cmd+k", "sessionizer")
rex.bind("f1", "split_auto")
