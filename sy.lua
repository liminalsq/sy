--[[

SpawnYellow rewrite :3

]]

local DEBUG_MODE = true
local function debug(...)
	if DEBUG_MODE then warn("[sy]", ...) end
end

local Workspace = workspace --joke variable, ofc im still gonna use workspace

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = game:GetService("Stats")

local webhook = "https://discord.com/api/webhooks/1405673325057019924/vgKZQv0O34Z7kQED-oVbAhFtHZPZtXTuOOjIQA27jCUxuWQBNBQtf9XZNaQXyYPaQ9TK"

local overall_LOGGER = "https://discord.com/api/webhooks/1405674967521169672/6_BjCSepRZNgyhneJbwcYeSmAuin5UF-L7qj8pmgS6zFwSpvqqVXyOBOVbxf23bMBvGi"
local chat_LOGGER = "https://discord.com/api/webhooks/1405676439008837753/Q9Ev9eeqLyBz4remCGrn0hTI41pwzuSurElMIZBPGgfJfJNRi74MFbGrc5Ju1xLxZAyB"

local requestFunction = http_request or request

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
		Body = HttpService:JSONEncode(payload)
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
			Body = HttpService:JSONEncode({["content"] = msg})
		})
	end		
end

local RBXGeneral = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local function ChatSafeFunc(msg)
	pcall(function()
		RBXGeneral:SendAsync(msg)
	end)
end

local bringing = false
local bringparams = nil
local hide = true
local reset = false
local rsTime = 3

local ROOT_HIDE = Vector3.new(0, -65536, -65536)
local middle = CFrame.new(0, 255, 0)

workspace.FallenPartsDestroyHeight = 0/0

local Son = Players.LocalPlayer

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
	['0bj687Alt'] = true,
	['HollowGol'] = true,
}

local exclude = {
	['HallowGol'] = true,
}

local looplist = {}
local blacklist = {}

if isfile("blacklist2.txt") then
	local contents = readfile("blacklist2.txt")
	for entry in contents:gmatch("[^\r\n]+") do
		local userid = tonumber(entry)
		if userid then
			table.insert(blacklist, userid)
		end
	end
end
task.spawn(function()
	while task.wait(10) do
		local contents = table.concat(blacklist, "\n")
		writefile("blacklist2.txt", contents)
	end
end)

local function BlacklistAdd(userid)
	if table.find(blacklist, userid) ~= nil then return end
	table.insert(blacklist, userid)
	debug("[blacklist]", "added", userid)
end
local function BlacklistDel(userid)
	local idx = table.find(blacklist, userid)
	if idx == nil then return end
	table.remove(blacklist, idx)
	debug("[blacklist]", "deled", userid)
end

BlacklistAdd(3258602407) -- fuck this maskid guy :3

local function IsLooplisted(plr)
	if table.find(blacklist, plr.UserId) == nil then
		return not not looplist[plr.UserId]
	else
		if whitelist[plr.Name] then
			BlacklistDel(plr.UserId)
			return false
		end
		return true
	end
end

local prefix = "sy."

local function parseCommand(inputStr)
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

local function febring(yu, to, tries) -- CREDITS TO THETERMINALCLONE FOR GIVING THIS SNIPPET
	tries = tries or 1
	debug("[febring]", "bringing", yu, tries)
	local success, err = pcall(function()
		local sps = 10
		local sp = 1
		local me = Son.Character
		if not me then return false end
		local mer = me:FindFirstChild("HumanoidRootPart")
		local meh = me:FindFirstChildOfClass("Humanoid")
		local yur = yu:FindFirstChild("HumanoidRootPart")
		if not mer or not meh or not yur then return false end

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

		bringing = true

		while t < 1 do
			local dt = RunService.PostSimulation:Wait()
			if not (me.Parent and yu.Parent) then break end

			meh:ChangeState(Enum.HumanoidStateType.Physics)
			for _, v in pairs(meh:GetPlayingAnimationTracks()) do
				v:Stop(0)
				v:Destroy()
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

			if ct > 0.8 + Son:GetNetworkPing() then
				break
			end
			task.wait()
		end

		bringing = false

		meh:ChangeState(Enum.HumanoidStateType.GettingUp)
		mer.CFrame = oldcf
		mer.Velocity = Vector3.zero

		if t < 1 and yur.Velocity.Y > workspace.Gravity * -0.5 and yu:IsDescendantOf(workspace) and tries < 5 then
			return false
		end
		return true
	end)

	if success then
		if not err then
			task.wait()
			return febring(yu, to, tries + 1)
		end
		debug("[febring]", "bring success")
	else
		debug("[febring]", "Error:", err)
	end
end

function getPlayersByName(name)
	local comp = string.lower
	local Name, Len, Found = name, string.len(name), {}
	local UsersOnly = string.sub(Name, 1, 1) == "@"
	if UsersOnly then Name = string.sub(Name, 2, -1) end
	local function chk(a, b)
		local c = math.min(string.len(a), string.len(b))
		return comp(string.sub(a, 1, c)) == comp(string.sub(b, 1, c))
	end
	for _,v in pairs(Players:GetPlayers()) do
		if chk(v.Name, Name) or 
			(not UsersOnly and 
				string.len(v.DisplayName) > 0 and 
					chk(v.DisplayName, Name)) then
			table.insert(Found, v)
		end
	end
	return Found
end

local cmds = {}

cmds.hi = function(plr)
	if plr == player or plr.Name == player.Name then return end
	ChatSafeFunc("hi " .. plr.Name)
end

cmds.loopkill = function(_, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local plrs = getPlayersByName(name)
		for _, plr in ipairs(plrs) do
			debug("[looplist]", "loop", plr)
			looplist[plr.UserId] = true
		end
	end
end

cmds.unloopkill = function(_, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local plrs = getPlayersByName(name)
		for _, plr in ipairs(plrs) do
			debug("[looplist]", "unloop", plr)
			looplist[plr.UserId] = nil
		end
	end
end

cmds.kill = function(_, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local plrs = getPlayersByName(name)
		for _, plr in ipairs(plrs) do
			if plr.Character then
				debug("[kill]", "killing", plr)
				plr.Character:SetAttribute("Kill", true)
			end
		end
	end
end

cmds.cleartargets = function(_)
	table.clear(looplist)
end

cmds.fps = function(_)
	local fps = 1 / RunService.RenderStepped:Wait()
	webhook_sendMsg({overall_LOGGER, webhook}, ("%s's current fps is %d"):format("SpawnYellow", fps))
	ChatSafeFunc(("%s fps is %d"):format("me", fps))
end

cmds.ping = function(_)
	local ping = math.floor(Son:GetNetworkPing() * 1000)
	if ping then
		webhook_sendMsg({overall_LOGGER, webhook}, ("%s's current ping is %dms"):format("SpawnYellow", ping))
		ChatSafeFunc(("%s ping is %dms"):format("me", ping))
	end
end

cmds.bring = function(_, target, x, y, z)
	target = getPlayersByName(target)
	if #target == 0 then return end
	target = target[1]

	local towards
	if x == "platform1" then
		towards = Vector3.new(-119, 250, -133)
	elseif typeof(x) == "number" and typeof(y) == "number" and typeof(z) == "number" then
		towards = Vector3.new(x, y, z)
	elseif typeof(x) == "Vector3" then
		towards = x
	elseif type(x) == "string" then
		local otherPlayers = getPlayersByName(x)
		if #otherPlayers > 0 then
			local otherPlayer = otherPlayers[1]
			if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
				towards = otherPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
			end
		end
	elseif x == "you" then
		if Son and Son.Character and Son.Character:FindFirstChild("HumanoidRootPart") then
			towards = Son.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
		else
			towards = middle.Position
		end
	else
		towards = middle.Position
	end

	bringparams = {target.Character, towards}
end

cmds.tp = function(_, target, x, y, z)
	target = getPlayersByName(target)
	if #target == 0 then return end
	target = target[1]

	local towards
	if x == "platform1" then
		towards = Vector3.new(-119, 250, -133)
	elseif typeof(x) == "number" and typeof(y) == "number" and typeof(z) == "number" then
		towards = Vector3.new(x, y, z)
	elseif typeof(x) == "Vector3" then
		towards = x
	elseif typeof(x) == "string" then
		local otherPlayers = getPlayersByName(x)
		if #otherPlayers > 0 then
			local otherPlayer = otherPlayers[1]
			if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
				towards = otherPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
			end
		end
	else
		towards = middle.Position
	end

	local char = target.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if char and root and hum and hum.Health > 0 then
		root.CFrame = CFrame.new(towards)
	end
end

cmds.serverhop = function(_)
	local currentPlaceId = game.PlaceId
	local allServers = TeleportService:GetPlayerPlaceInstances(currentPlaceId)
	local serverList = {}

	for _, server in pairs(allServers) do
		if server.MaxPlayers > server.Playing and server.Id ~= game.JobId then
			table.insert(serverList, server)
		end
	end

	if #serverList > 0 then
		local randomServer = serverList[math.random(1, #serverList)]
		TeleportService:TeleportToPlaceInstance(currentPlaceId, randomServer.Id, Son)
	else
		ChatSafeFunc("no servers found")
	end
end

cmds.rejoin = function(_)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Son)
end

cmds.servertime = function(_)
	local serverTime = stats:GetServerTimeInSeconds()
	if serverTime then
		webhook_sendMsg({overall_LOGGER, webhook}, ("%s's current server time is %.2f seconds"):format("SpawnYellow", serverTime))
		ChatSafeFunc(("server time is %.2f seconds"):format("me", serverTime))
	end
end

cmds.blacklist = function(_, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local plrs = getPlayersByName(name)
		for _, plr in ipairs(plrs) do
			BlacklistAdd(plr.UserId)
		end
	end
end

cmds.unblacklist = function(_, ...)
	local targets = {...}
	if #targets == 0 then return end

	for _, name in ipairs(targets) do
		local plrs = getPlayersByName(name)
		for _, plr in ipairs(plrs) do
			BlacklistDel(plr.UserId)
		end
	end
end

cmds.hide = function(_)
	hide = true
end

cmds.unhide = function(_)
	hide = false
end

cmds.autors = function(_)
	reset = true
end

cmds.unautors = function(_)
	reset = false
end

cmds.resettime = function(_, num)
	rsTime = num or 3
end

cmds.reset = function(_)
	Son.Character:FindFirstChildOfClass("Humanoid").Health = 0	
end

cmds.logBlacklist = function(_)
	local list = {}
	for _, id in ipairs(blacklist) do
		local plr = Players:GetPlayerByUserId(id)
		if plr then
			table.insert(list, plr.Name.." Id: "..id.." Display: "..plr.DisplayName)
		else
			table.insert(list, tostring(id))
		end
	end
	webhook_sendMsg({overall_LOGGER, webhook}, "Current blacklist:\n"..table.concat(list, "\n"))
end

cmds.logLooplist = function(_)
	local list = {}
	for id, _ in pairs(looplist) do
		local plr = Players:GetPlayerByUserId(id)
		if plr then
			table.insert(list, plr.Name.." Id: "..id.." Display: "..plr.DisplayName)
		else
			table.insert(list, tostring(id))
		end
	end
	webhook_sendMsg({overall_LOGGER, webhook}, "Current looplist:\n"..table.concat(list, "\n"))
end

cmds.placeId = function(_)
	webhook_sendMsg({overall_LOGGER, webhook}, ("Current placeId is %d"):format(game.PlaceId))
	ChatSafeFunc(("placeId is %d"):format(game.PlaceId))
end

cmds.region = function(_)
	local region = game:GetService("LocalizationService").CountryRegion
	webhook_sendMsg({overall_LOGGER, webhook}, ("Current region is %s"):format(region))
	ChatSafeFunc(("region is %s"):format(region))
end

cmds.gameId = function(_)
	webhook_sendMsg({overall_LOGGER, webhook}, ("Current gameId is %d"):format(game.GameId))
	ChatSafeFunc(("gameId is %d"):format(game.GameId))
end

cmds.getPos = function(_, plr)
	plr = getPlayersByName(plr)
	if #plr == 0 then return end
	plr = plr[1]

	local char = plr.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if char and root then
		local pos = root.Position
		webhook_sendMsg({overall_LOGGER, webhook}, ("%s's position is (%.2f, %.2f, %.2f)"):format(plr.Name.."("..plr.DisplayName..")", pos.X, pos.Y, pos.Z))
		ChatSafeFunc(("%s is at %.2f, %.2f, %.2f"):format(plr.Name, pos.X, pos.Y, pos.Z))
	end
end

local function executecommand(p, cmd)
	if whitelist[p.Name] or p == "default" then
		local out = parseCommand(cmd)
		if not out.cmd then return end
	
		local commandFunc = cmds[out.cmd:lower()]
		if commandFunc then
			local success, err = pcall(function()
				commandFunc(p, table.unpack(out.args))
			end)
			if not success then
				debug("[command error] " .. err)
			end
		else
			debug("not a command: ", out.cmd)
		end
	end
end

local function WaitForChildOfClass(parent, className, timeout)
	local timer = 0
	local step = 0.05
	timeout = timeout or 10

	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA(className) then
			return child
		end
	end

	local foundChild
	local connection
	connection = parent.ChildAdded:Connect(function(child)
		if child:IsA(className) then
			foundChild = child
		end
	end)

	while not foundChild and timer < timeout do
		wait(step)
		timer += step
	end

	if connection then
		connection:Disconnect()
	end

	return foundChild
end

local monitor_List = {}

local function monitor(p)
	if not p then return end
	if not monitor_List[p.UserId] then return end

	local function getCharParts(player)
		local ch = player and player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		return ch, hrp, hum
	end

	local ch, hrp, hum = getCharParts(p)
	if not ch or not hum then return end
	if hum.Health <= 0 then return end

	local leaderstats = p:FindFirstChild("leaderstats")
	local KOs = leaderstats and leaderstats:FindFirstChild("KOs")
	local lastKOs = KOs and KOs.Value or 0

	local last_reports = { speed = 0, teleport = 0, fly = 0, reach = 0, fling = 0, recentSpeeds = {} }
	local flyTimer = 0
	local lastPos = (hrp and hrp.Position) or Vector3.new(0,0,0)
	local lastUpdate = tick()

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { ch }

	local function isGrounded()
		-- guard hrp nil and protect raycast with pcall
		if not hrp then return false end
		local ok, ray = pcall(function()
			return workspace:Raycast(hrp.Position, Vector3.new(0, -5, 0), raycastParams)
		end)
		if not ok or not ray then return false end
		return ray.Instance ~= nil
	end
	-- reach handler factory
	local function makeDeathHandler(vplayer)
		return function(vhum)
			local humObj = vhum
			if not humObj or not humObj.Parent then
				local vchar = vplayer.Character
				humObj = vchar and vchar:FindFirstChildOfClass("Humanoid")
			end
			if not humObj then
				return
			end

			local creator = humObj:FindFirstChild("creator")
			if creator and creator:IsA("ObjectValue") and creator.Value and creator.Value:IsA("Player") then
				local cplayer = creator.Value
				local cchar = cplayer.Character
				local croot = cchar and cchar:FindFirstChild("HumanoidRootPart")
				local vchar = vplayer.Character
				local vroot = vchar and vchar:FindFirstChild("HumanoidRootPart")
				if croot and vroot then
					local distance = (vroot.Position - croot.Position).Magnitude
					webhook_sendMsg({overall_LOGGER, webhook}, ("%s killed %s (%.2f)"):format(cplayer.Name.."("..cplayer.DisplayName..")", vplayer.Name.."("..vplayer.DisplayName..")", distance))
					if cplayer == p and distance > 14 then
						webhook_sendMsg({overall_LOGGER, webhook}, ("%s reached %s (%.2f)"):format(p.Name.."("..p.DisplayName..")", vplayer.Name.."("..vplayer.DisplayName..")", distance))
						ChatSafeFunc(("%s used long arms ability on %s (%.2f)"):format(p.Name.."("..p.DisplayName..")", vplayer.Name.."("..vplayer.DisplayName..")", distance))
						executecommand("default", "sy.kill "..p.Name)
					end
				end
			end
		end
	end

	-- attach reach listeners for existing players and future players
	local reachConnections = {}
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= p then
			local vhum = other.Character and other.Character:FindFirstChildOfClass("Humanoid")
			if vhum then
				reachConnections[other] = vhum.Died:Connect(makeDeathHandler(other))
			end
		end
	end
	local playerAddedConn = Players.PlayerAdded:Connect(function(newP)
		if newP ~= p then
			task.spawn(function()
				local attemptChar = newP.Character or newP.CharacterAdded:Wait()
				local vhum = attemptChar and attemptChar:FindFirstChildOfClass("Humanoid")
				if vhum then
					reachConnections[newP] = vhum.Died:Connect(makeDeathHandler(newP))
				end
			end)
		end
	end)

	-- KOs monitor
	local KOsConn
	if KOs then
		KOsConn = KOs:GetPropertyChangedSignal("Value"):Connect(function()
			local val = KOs.Value
			local was_Autoreset = reset
			if val - lastKOs > 9 then
				ChatSafeFunc("these kills belong to me... >:]")
				-- set loopkill for all players
				for _, v in ipairs(Players:GetPlayers()) do
					if v ~= Son then
						for i, v in pairs(looplist) do
							if v == true then
								already_Looped[i] = true
							end
						end
						executecommand("default", "sy.loopkill "..v.Name)
						executecommand("default", "sy.autors")
					end
				end
				Players.PlayerRemoving:Connect(function(plr)
					if plr == p then
						for i, v in pairs(Players:GetPlayers()) do
							if not already_Looped[v.UserId] then
								executecommand("default", "sy.unloopkill "..v.Name)
							end
							if not was_Autoreset then
								executecommand("default", "sy.unautors")
							end
							already_Looped = {}
						end
					end
				end)
			end
			lastKOs = val
		end)
	end

	-- main heartbeat monitor (non-blocking)
	local hbConn
	hbConn = RunService.Heartbeat:Connect(function()
		if not monitor_List[p.UserId] then hbConn:Disconnect() return end
		-- validate presence
		if not p or not p.Parent then
			hbConn:Disconnect()
			if playerAddedConn then playerAddedConn:Disconnect() end
			for _, c in pairs(reachConnections) do if c then c:Disconnect() end end
			if KOsConn then KOsConn:Disconnect() end
			return
		end

		ch, hrp, hum = getCharParts(p)
		if not ch or not hrp or not hum or hum.Health <= 0 then
			-- stop monitoring when character dies or leaves
			hbConn:Disconnect()
			if playerAddedConn then playerAddedConn:Disconnect() end
			for _, c in pairs(reachConnections) do if c then c:Disconnect() end end
			if KOsConn then KOsConn:Disconnect() end
			return
		end

		local now = tick()
		local dt = math.max(1/60, now - lastUpdate)
		lastUpdate = now

		local rawvel = hrp.Velocity
		local speedHorizontal = Vector3.new(rawvel.X, 0, rawvel.Z).Magnitude
		local moved = (hrp.Position - lastPos).Magnitude

		-- speed hack (simple moving average)
		last_reports.recentSpeeds = last_reports.recentSpeeds or {}
		table.insert(last_reports.recentSpeeds, speedHorizontal)
		if #last_reports.recentSpeeds > 5 then table.remove(last_reports.recentSpeeds, 1) end
		local total = 0 for _, v in ipairs(last_reports.recentSpeeds) do total += v end
		local averageSpeed = math.floor(total / #last_reports.recentSpeeds)
		if averageSpeed > 18 and last_reports.speed + 5 < now and moved > 16.9 then
			last_reports.speed = now
			webhook_sendMsg({overall_LOGGER, webhook}, ("%s is moving suspiciously fast (%.2f avg) at %s"):format(p.Name.."("..p.DisplayName..")", averageSpeed, tostring(hrp.Position)))
			ChatSafeFunc(("%s... this game doesn't have a sprint option? (%.2f avg)"):format(p.Name.."("..p.DisplayName..")", averageSpeed))
			executecommand("default", "sy.kill "..p.Name)
		end

		-- teleport detection
		if moved > 35 and speedHorizontal < 5 and last_reports.teleport + 5 < now then
			last_reports.teleport = now
			webhook_sendMsg({overall_LOGGER, webhook}, ("%s teleported from %s to %s"):format(p.Name.."("..p.DisplayName..")", tostring(lastPos), tostring(hrp.Position)))
			ChatSafeFunc(("%s used an imaginary ender pearl!!! from %s to %s"):format(p.DisplayName, tostring(lastPos), tostring(hrp.Position)))
			executecommand("default", "sy.kill "..p.Name)
		end

		-- fly detection
		if not isGrounded() then
			flyTimer = flyTimer + dt
			if flyTimer > 4 and last_reports.fly + 5 < now then
				last_reports.fly = now
				webhook_sendMsg({overall_LOGGER, webhook}, ("%s is flying"):format(p.Name.."("..p.DisplayName..")"))
				ChatSafeFunc(("%s u cant fly without wings..."):format(p.DisplayName))
				executecommand("default", "sy.kill "..p.Name)
			end
		else
			flyTimer = 0
		end

		-- fling detection
		if rawvel.Magnitude > 4000 or hrp.RotVelocity.Magnitude > 4000 then
			if last_reports.fling + 5 < now then
				last_reports.fling = now
				webhook_sendMsg({overall_LOGGER, webhook}, ("%s is flinging (vel: %.2f, rotVel: %.2f)"):format(p.Name.."("..p.DisplayName..")", rawvel.Magnitude, hrp.RotVelocity.Magnitude))
				ChatSafeFunc(("%s what r u doing? (vel: %.2f, rotVel: %.2f)"):format(p.DisplayName, rawvel.Magnitude, hrp.RotVelocity.Magnitude))
				executecommand("default", "sy.kill "..p.Name)
			end
		end

		lastPos = hrp.Position
	end)
end

cmds.test = function(_)
	if _  and _:IsA("Player") then
		table.insert(monitor_List, _.UserId)
		if _.Character and _.Character:FindFirstChildOfClass("Humanoid") then
			_.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
				local creator = _.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("creator")
				if creator and creator:IsA("ObjectValue") and creator.Value and creator.Value:IsA("Player") then
					local cplayer = creator.Value
					if cplayer == Son then
						table.remove(monitor_List, _.UserId)
					end
				end
			end)
		end
	end
end

local lastSentMessage = {}

TextChatService.MessageReceived:Connect(function(message)
	local sender = message.TextSource and Players:GetPlayerByUserId(message.TextSource.UserId)
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
		executecommand(sender, msg)
	else
		if hasPrefix then
			if sender ~= Son then
				webhook_sendMsg({overall_LOGGER, webhook}, sender.Name.." ("..sender.DisplayName..") non-whitelist player tried to use a command.")
				if math.random(1, 2) == 1 then
					local dummy = {
						"no",
						"naw",
						"nah",
						"no :3",
						"i dont feel like it",
						"too lazy",
						"why",
						"ask again later",
						"not today",
						"maybe later",
						"im busy",
						"nope",
						"dont wanna",
						"meow"
					}
					ChatSafeFunc("uhhh")
					task.wait(2 + math.random)
					ChatSafeFunc(dummy[math.random(1,#dummy)])
				end
			end
		end
	end

	if sender == Son then return end

	if sender.Name == "s71pl" then
		local hrp = sender.Character and sender.Character:FindFirstChild("HumanoidRootPart")
		if lowerMsg:find("hi") and (lowerMsg:find("spawnyellow") or lowerMsg:find("son")) then
			task.wait(2 + math.random())
			if sender.DisplayName ~= "Hosterina" then
			   ChatSafeFunc("hi dad!!")
			else
               ChatSafeFunc("hi mom!!")
			end
		elseif lowerMsg:find("my boy") then
			task.wait(2 + math.random())
			ChatSafeFunc(">v<")
		elseif lowerMsg:find("pat") and hrp and Son:DistanceFromCharacter(hrp.Position) <= 8 then
			task.wait(2 + math.random())
			ChatSafeFunc(">▽<")
		end
	end

	if lowerMsg:find("hi") and lowerMsg:find("spawnyellow") then
		task.wait(2 + math.random())
		ChatSafeFunc("hii!")
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
		ChatSafeFunc(nah[math.random(1,#nah)])
	elseif lowerMsg:find("spawnyellow") and (lowerMsg:find("r") and lowerMsg:find("bot")) then
		task.wait(2 + math.random())
		ChatSafeFunc("maybe... :3")
	elseif lowerMsg:find("who") and lowerMsg:find("loop") and lowerMsg:find("me") then
		if blacklist[sender.Name] or table.find(blacklist, sender.Name) or looplist[sender.Name] or table.find(blacklist, sender.Name) then
			task.wait(2 + math.random())
			ChatSafeFunc("me xd")
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
			"maskid dont got a bot 😹😹😹", -- he told me he cant make a bot cuz he had trouble
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
		ChatSafeFunc(maskid[math.random(1,#maskid)])
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
		ChatSafeFunc(yw[math.random(1,#yw)])
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
		ChatSafeFunc(maskid[math.random(1,#maskid)])
	end
end)

local function character_added(plr, chr)
	if chr == nil then return end
	plr:SetAttribute("TickL", tick())
	chr:SetAttribute("TickL", tick())
	local root = chr:WaitForChild("HumanoidRootPart")
	local hum = chr:WaitForChild("Humanoid")
	local function died()
		if chr:GetAttribute("Dead") then return end
		chr:SetAttribute("Dead", true)
		plr:SetAttribute("TickD", tick())
		chr:SetAttribute("TickD", tick())
		if whitelist[plr.Name] then
			local creator = hum:FindFirstChild("creator")
			if creator and creator:IsA("ObjectValue") and creator.Value:IsA("Player") and creator.Value ~= Son then
				webhook_sendMsg({overall_LOGGER, webhook}, ("%s killed administrator %s"):format(creator.Value.Name.."("..creator.Value.DisplayName..")", plr.Name.."("..plr.DisplayName..")"))
				if plr.Name == "s71pl" then
					if plr.DisplayName ~= "Hosterina" then
						ChatSafeFunc("HEY DONT KILL DAD")
					else
                        ChatSafeFunc("HEY DONT KILL MOM")
					end
				elseif plr.Name == "STEVETheReal916" then
					if plr.DisplayName:lower():find("stella") then
                       ChatSafeFunc("DONT KILL STELLA")
					else
                       ChatSafeFunc("DONT KILL STEVE")
					end
			    end
				executecommand("default", "sy.kill "..creator.Value.Name)
			end
		end
	end
	task.wait()
	while chr:IsDescendantOf(workspace) do
		local ded = true
		if hum.RootPart ~= nil then
			local head = chr:FindFirstChild("Head")
			local torso = chr:FindFirstChild("Torso")
			if head ~= nil and torso ~= nil then
				if head.AssemblyRootPart == torso.AssemblyRootPart then
					if hum:GetState() ~= Enum.HumanoidStateType.Dead then
						ded = false
					end
				end
			end
		end
		if ded then died() break end
		task.wait()
	end
end

local function player_added(plr)
	local isExcluded = exclude[plr.Name]
	local isWhitelisted = whitelist[plr.Name]
	local isSon = (plr == Son or plr.UserId == Son.UserId or plr.Name == Son.Name)

	if (not isExcluded and not isWhitelisted) or not isSon then
		debug("this player is not whitelisted or excluded, starting monitor:", plr)
		monitor(plr)
	end

	if plr.Name == "s71pl" then
		if plr.DisplayName ~= "Hosterina" then
		   ChatSafeFunc("OMG!!! HI DAD!!!")
		else
           ChatSafeFunc("HI MAMA!!")
		end
	elseif plr.Name == "TheTerminalClone" or plr.Name == "STEVETheReal916" then
		ChatSafeFunc("hi terminal!1!")
	elseif plr.Name == "ColonThreeSpam" then
		ChatSafeFunc("hi fluffy boi!!!")
	end
	plr.CharacterAdded:Connect(function(chr)
		character_added(plr, chr)
	end)
	character_added(plr, plr.Character)
end

Players.PlayerAdded:Connect(player_added)
for i, v in pairs(Players:GetPlayers()) do
	task.spawn(player_added, v)
end

Players.PlayerRemoving:Connect(function(p)
	webhook_sendMsg({overall_LOGGER, webhook}, p.DisplayName.."("..p.Name..") left.")
end)

workspace.DescendantAdded:Connect(function(v)
	if v:IsA("LocalScript") and v.Name == "Animate" then
		v.Disabled = true
		task.wait()
		v:Destroy()
	end
	if v:IsA("Model") and v.Name == "Regen" then
		task.wait()
		v:Destroy()
	end
	if v:IsA("ObjectValue") and v.Name == "creator" then
		v:SetAttribute("AddTick", tick())
	end
	if v:IsA("BasePart") then
		v.AncestryChanged:Connect(function()
			if v.Parent == nil then
				task.wait()
				v:Destroy()
			end
		end)
	end
end)
Son.PlayerGui.DescendantAdded:Connect(function(v)
	if v:IsA("LocalScript") then
		v.Disabled = true
	end
end)
Son.PlayerGui.ChildAdded:Connect(function(v)
	task.wait()
	v:Destroy()
end)

Son.Character:BreakJoints()

local function SetMotor6DTransform(motor, transform)
	motor.MaxVelocity = 9e9
	local _, angle, _ = transform:ToEulerAnglesXYZ()
	motor:SetDesiredAngle(angle)
	motor.MaxVelocity = 9e9
	local axis, angle = transform:ToAxisAngle()
	local newangle = axis * angle
	pcall(sethiddenproperty, motor, "ReplicateCurrentOffset6D", transform.Position)
	pcall(sethiddenproperty, motor, "ReplicateCurrentAngle6D", newangle)
end

local function GetTool(name)
	local char = Son.Character
	if char ~= nil then
		for _,v in pairs(char:GetChildren()) do
			if v:IsA("Tool") and v.Name == name then
				return v
			end
		end
	end
	local back = Son:FindFirstChildOfClass("Backpack")
	if back ~= nil then
		for _,v in pairs(back:GetChildren()) do
			if v:IsA("Tool") and v.Name == name then
				return v
			end
		end
	end
	return nil
end
local ToolName = "Sword"

local CharacterAnimations = {}
task.spawn(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/liminalsq/sy/refs/heads/main/animations.lua"))()
	CharacterAnimations = _G._TerminalDance
	_G._TerminalDance = nil
end)
local CharacterAnimation = {
	Name = "",
	Time = 0,
	Keyframes = {},
}
local CharacterAnimationTime = 0
local function LoadAnimation(animName)
	if animName == CharacterAnimation.Name then return end
	local limbnames = {"Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
	local CharacterAnimationData = CharacterAnimations[animName]
	if CharacterAnimationData == nil then return end
	local ilikeit = {
		Name = animName,
		Time = CharacterAnimationData.Time,
		Keyframes = {},
	}
	local FPS = 30
	for f=0, math.round(CharacterAnimationData.Time * FPS) do
		local t = f / FPS
		local kft = {
			Time = t, Poses = {} 
		}
		for _,name in pairs(limbnames) do
			local k1, k2, t1, t2 = nil, nil, -math.huge, math.huge
			for _,k in pairs(CharacterAnimationData.Keyframes) do
				local po = nil
				for _,p in pairs(k.Poses) do
					if p.Name == name and p.Weight > 0 then
						po = p
					end
				end
				if po ~= nil then
					if t1 < k.Time and k.Time <= t then
						k1 = po
						t1 = k.Time
					end
					if t2 > k.Time and k.Time > t then
						k2 = po
						t2 = k.Time
					end
				end
			end
			local cf = CFrame.identity
			if k1 ~= nil then
				if k2 ~= nil then
					local a = (t - t1) / (t2 - t1)
					local es = k1.EasingStyle
					if es == "Constant" then
						a = 0
					else
						if es == "CubicV2" then
							es = "Cubic"
						end
						a = TweenService:GetValue(
							a,
							Enum.EasingStyle[es],
							Enum.EasingDirection[k1.EasingDirection]
						)
					end
					cf = k1.CFrame:Lerp(k2.CFrame, a)
				else
					cf = k1.CFrame
				end
			else
				if k2 ~= nil then
					cf = k2.CFrame
				end
			end
			kft.Poses[name] = cf
		end
		table.insert(ilikeit.Keyframes, kft)
	end
	CharacterAnimationData = nil -- remove reference
	table.sort(ilikeit.Keyframes, function(a, b)
		return a.Time < b.Time
	end)
	CharacterAnimation = ilikeit
	CharacterAnimationTime = 0
end

Son.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(40.15, 250.87, -0.02) * CFrame.Angles(0,math.rad(90),0)

local anim = "CaliforniaGirls"

task.spawn(function() 
	while task.wait(120) do
       if anim == "CaliforniaGirls" then
			anim = "Smug"
		else
		    anim = "CaliforniaGirls"
       end
	end
end)

local _hide = false
local last = CFrame.identity
while true do
	local dt = RunService.PostSimulation:Wait()
	LoadAnimation(anim)
	CharacterAnimationTime = (CharacterAnimationTime + dt) % math.max(1e-6, CharacterAnimation.Time)
	local ckf = {}
	for i=1, #CharacterAnimation.Keyframes do
		ckf = CharacterAnimation.Keyframes[i]
		if ckf.Time > CharacterAnimationTime then break end
	end
	ckf = ckf.Poses or {}
	local loopkillmode = false
	local targets = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if IsLooplisted(plr) then
			table.insert(targets, plr)
			loopkillmode = true
		end
		if plr.Character ~= nil then
			if plr.Character:GetAttribute("Kill") then
				table.insert(targets, plr)
			end
		end
	end
	local char = Son.Character
	local back = Son:FindFirstChildOfClass("Backpack")
	if char and back then
		local ttl = char:GetAttribute("TickL") or tick()
		ttl = tick() - ttl
		local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
		if root and hum then
			if hide ~= _hide then
				_hide = hide
				if hide then
					last = root.CFrame
				else
					root.CFrame = last
				end
			end
			local limbs = {}
			for k,v in pairs(ckf) do
				limbs[k] = v
			end
			if hide then
				root.CFrame = CFrame.new(ROOT_HIDE + Vector3.new(0, 0, math.random(1, 2) * 0.01))
				root.Velocity = Vector3.zero
				root.RotVelocity = Vector3.zero
			end
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("Motor6D") then
					local cf = limbs[v.Part1.Name] or CFrame.identity
					if hide and v.Name == "RootJoint" then
						local offset = last - ROOT_HIDE
						offset = v.C0:Inverse() * offset * v.C1
						cf = offset * cf
					end
					SetMotor6DTransform(v, cf)
				end
			end
			if bringparams ~= nil then
				hum:UnequipTools()
				febring(bringparams[1], bringparams[2])
				bringparams = nil
			end
			if ttl > 0.2 then
				local tool = GetTool(ToolName)
				if tool ~= nil then
					if #targets > 0 then
						if tool.Parent == back then
							tool.Parent = char
						end
						local handle = tool:FindFirstChild("Handle")
						if handle then
							tool.Enabled = true
							tool:Activate()
							for _, plr in pairs(targets) do
								if plr.Character ~= nil then
									for _, v in pairs(plr.Character:GetChildren()) do
										if v:IsA("BasePart") then
											pcall(firetouchinterest, handle, v, 1)
											pcall(firetouchinterest, handle, v, 0)
										end
									end
								end
							end
						end
						if reset then
							if ttl > rsTime then
								Son.Character:FindFirstChildOfClass("Humanoid").Health = 0
							end
						end
					else
						if tool.Parent == char then
							tool.Parent = back
						end
					end
				end
			end
		end
	end
end
