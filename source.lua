--[[

ANTI-CHEAT BOT

by script_A/liminalsq

inspired by colonthreespam

]]

pcall(function()
	workspace.FallenPartsDestroyHeight = 0/0 or -1e6
end)

local players = game:GetService("Players")
local chatService = game:GetService("Chat")
local textCh = game:GetService("TextChatService")
local runs = game:GetService("RunService")
local tween = game:GetService("TweenService")
local teleportServ = game:GetService("TeleportService")
local httpsService = game:GetService("HttpService")
local repstor = game:GetService("ReplicatedStorage")

local monitortimer=0

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
		Body = httpsService:JSONEncode(payload)
	})
end

local function webhook_sendMsg(webhook, msg)
	requestFunction({
		Url = webhook,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = httpsService:JSONEncode({["content"] = msg})
	})
end

local channels = textCh:WaitForChild("TextChannels")
local rbxg = channels:WaitForChild("RBXGeneral")

local spawnPoint = nil

local player = players.LocalPlayer

if not player then
	pcall(function()
		player = players.LocalPlayer
	end)
end

local char = (player.Character or player.CharacterAdded:Wait())
local humanoid = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")

local loopkilling = false
local hiding = false
local floating = false
local bringing = false

local float_part = Instance.new("Part")
float_part.Name = "f"
float_part.Anchored = true
float_part.Transparency = 0.9
float_part.CanCollide = true
float_part.Parent = repstor

local bad_mans = {}

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
	['BorrowGoal'] = true
}
local confusion = {
	"whaaaa???",
	"huh",
	"what are u on abt",
	"command doesnt exist, sighhh",
	"did u know that you should add logic for that?",
	"na na na na",
	"?",
	"speak english loser",
	"404 command not found",
	"try again, no command here",
	"what did you just say?",
	"that command’s a ghost",
	"error: command missing",
	"nope, no command detected",
	"unknown command, try harder",
	"command not recognized",
	"uhhh… what?",
	"doesn’t compute",
	"invalid command input",
	"you typed nonsense",
	"command? what command?",
	"did you misclick?",
	"that command’s on vacation",
	"not a valid command, buddy",
	"input error: command not found",
	"did you mean something else?",
	"command missing, please retry",
	"can’t find that command anywhere",
	"error: syntax not valid",
	"try another command",
}

local dummy = {
	"urrrrp",
	"maowwwww",
	"ask colon instead 😝😝",
	"na na na na",
	"blah blah blah",
	"i cant hear you na na na na boo boo",
	"farts",
	"try again, loser",
	"access denied 😎",
	"not on the list, buddy",
	"nice try but nope",
	"you shall not pass!",
	"blocked like a pro",
	"who invited you?",
	"nope, no entry",
	"keep dreaming",
	"error 403: nope",
	"not today, pal",
	"permission denied",
	"access forbidden",
	"buzz off!",
	"you’re not in the club",
	"no whitelist, no welcome",
	"denied with prejudice",
	"no soup for you!",
	"sorry, no access",
	"try harder next time",
	"not cool, try later",
	"you don’t get a cookie",
	"not whitelisted, LOL"
}

local function add_to_table(t, any)
	table.insert(t, any)
end

local fps = 0
local frameCount = 0
local elapsedTime = 0

runs.RenderStepped:Connect(function(dt)
	frameCount += 1
	elapsedTime += dt
	if elapsedTime >= 1 then
		fps = frameCount
		frameCount = 0
		elapsedTime = 0
	end
end)

local function find_handle(tool)
	if tool and tool:IsA("Tool") then
		return tool:FindFirstChild("Handle")
	end
	return nil
end

local function find_tool(char)
	for _, item in ipairs(char:GetChildren()) do
		if item:IsA("Tool") and item:FindFirstChild("Handle") then
			return item
		end
	end

	local players = game:GetService("Players")
	local player = players:GetPlayerFromCharacter(char)
	if not player then return nil end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return nil end

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
			wait(1)
			return tool
		end
	end

	return nil
end

player.CharacterAdded:Connect(function(c)
	char = c
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")

	if spawnPoint then
		root.CFrame = spawnPoint
	end

	if loopkilling then
		local tool = find_tool(char)
		if tool then
			local handle = find_handle(tool)
			if handle then
				wait(0.9)
				humanoid:EquipTool(tool)
			end
		end
	end 

	humanoid.Died:Connect(function()
		rbxg:SendAsync("oww!!! >-<")
	end)
end)

task.spawn(function()
	while wait(0.9) do
		if loopkilling then
			local tool = find_tool(char)
			if tool then
				local handle = find_handle(tool)
				if handle then
					wait(0.9)
					humanoid:EquipTool(tool)
				end
			end
		end 
	end
end)

local function kill(toolHandle, targetHumanoidRootPart)
	pcall(function()
		firetouchinterest(toolHandle, targetHumanoidRootPart, 0)
		firetouchinterest(toolHandle, targetHumanoidRootPart, 1)
	end)
end

local killCooldowns = {}
local lpos = root.CFrame

runs.RenderStepped:Connect(function()
	if loopkilling then
		local currentChar = player.Character
		if not currentChar then return end
		local currentHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
		local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
		if not currentHumanoid or not currentRoot then return end

		for i = #bad_mans, 1, -1 do
			local targetName = bad_mans[i]
			local targetPlayer

			for _, p in ipairs(players:GetPlayers()) do
				if p.Name:lower() == targetName or p.DisplayName:lower() == targetName then
					targetPlayer = p
					break
				end
			end

			if targetPlayer and targetPlayer.Character then
				local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

				if targetHumanoid and targetHumanoid.Health > 0 and targetRoot then
					local tool = find_tool(currentChar)
					local handle = tool and find_handle(tool)

					if tool and handle then
						tool:Activate()
						kill(handle, targetRoot)
					end
				end
			end
		end
	end

	if hiding then
		if root then
			if not bringing then
				root.CFrame = CFrame.new(0, -65536, 65536)
			end
		end
	else
		if root then
			lpos = root.CFrame
		end
	end

	if not bringing then
		lpos = root.CFrame
	end

	if floating then
		float_part.Parent = workspace
		if root then
			float_part.Position = root.Position + Vector3.new(0, 3.5, 0)
		end
	else
		float_part.Parent = repstor
	end
end)

local function findPlayerByName(nameLower)
	for _, plr in ipairs(game.Players:GetPlayers()) do
		local nameLowered = plr.Name:lower()
		local displayLowered = plr.DisplayName:lower()
		if nameLowered == nameLower or displayLowered == nameLower then
			return plr
		elseif nameLowered:find(nameLower, 1, true) or displayLowered:find(nameLower, 1, true) then
			return plr
		end
	end
end

local function findPlayersByName(query)
	local matches = {}
	query = query:lower()
	for _, p in pairs(game.Players:GetPlayers()) do
		local nameLower = p.Name:lower()
		local displayLower = p.DisplayName:lower()
		if nameLower:find(query, 1, true) or displayLower:find(query, 1, true) then
			table.insert(matches, p)
		end
	end
	return matches
end

local function febring(me, yu, to, tries) --CREDITS TO THETERMINALCLONE FOR GIVING THIS SNIPPET
	tries = tries or 1
	local sps = 10
	local sp = 1
	local mer = me:FindFirstChild("HumanoidRootPart")
	local meh = me:FindFirstChildOfClass("Humanoid")
	local yur = yu:FindFirstChild("HumanoidRootPart")
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
		meh:ChangeState(Enum.HumanoidStateType.Physics)
		for _,v in pairs(meh:GetPlayingAnimationTracks()) do
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
		for i,v in pairs(coins) do
			if (yur.Position - v).Magnitude < 3 then
				ct = 0
				coins[i] = v + Vector3.new(0, 10000, 0)
			end
		end
		if ct > 0.8 + player:GetNetworkPing() then
			break
		end
	end
	meh:ChangeState(Enum.HumanoidStateType.GettingUp)
	mer.CFrame = oldcf
	mer.Velocity = Vector3.zero
	if t < 1 and yur.Velocity.Y > workspace.Gravity * -0.5 and yu:IsDescendantOf(workspace) and tries < 5 then
		return febring(yu, to, tries + 1)
	end
end

local function do_command(input)
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	local args = string.split(input, " ")
	local cmd = args[1]:lower() -- lowercase only the command
	table.remove(args, 1) -- remove command from args

	if cmd == "fps" then
		print(fps)
		rbxg:SendAsync("FPS: "..tostring(fps))
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", FPS: "..tostring(fps))

	elseif cmd:sub(1,5) == "lkill" then
		local addedPlayers = {}

		for _, name in ipairs(args) do
			local matches = findPlayersByName(name)
			if #matches == 0 then
				rbxg:SendAsync("Could not find: " .. name)
				webhook_sendMsg(overall_LOGGER, "Used command: " .. cmd .. ", failed to find player: " .. name)
			else
				for _, targetPlayer in ipairs(matches) do
					local targetLower = targetPlayer.Name:lower()
					if not table.find(bad_mans, targetLower) then
						table.insert(bad_mans, targetLower)
						table.insert(addedPlayers, targetPlayer.DisplayName .. " (" .. targetPlayer.Name .. ")")
					end
				end
			end
		end

		if #addedPlayers > 0 then
			loopkilling = true
			print("Loopkilling: " .. table.concat(bad_mans, ", "))
			rbxg:SendAsync("Ur cooked: " .. table.concat(addedPlayers, ", "))
			webhook_sendMsg(overall_LOGGER, "Used command: " .. cmd .. ", added: " .. table.concat(addedPlayers, ", ") .. " to loopkill list.")
		else
			rbxg:SendAsync("No new targets added.")
			webhook_sendMsg(overall_LOGGER, "Used command: " .. cmd .. ", no new loopkill targets added.")
		end

	elseif cmd == "stoplkill" then
		loopkilling = false
		rbxg:SendAsync("stopped: lkill")
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", stopped loopkill.")

	elseif cmd == "cleartargets" then
		bad_mans = {}
		rbxg:SendAsync("cleared list of bad mans!!")
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", cleared looplist.")

	elseif cmd:sub(1,18) == "removefromtargets" then
		local removedPlayers = {}

		for _, name in ipairs(args) do
			local matches = findPlayersByName(name)
			if #matches == 0 then
				webhook_sendMsg(overall_LOGGER, "Used command: " .. cmd .. ", could not find: '" .. name .. "' in looplist.")
			else
				for _, targetPlayer in ipairs(matches) do
					local idx = table.find(bad_mans, targetPlayer.Name:lower())
					if idx then
						table.remove(bad_mans, idx)
						table.insert(removedPlayers, targetPlayer.DisplayName .. " (" .. targetPlayer.Name .. ")")
					end
				end
			end
		end

		if #removedPlayers > 0 then
			webhook_sendMsg(overall_LOGGER, "Used command: " .. cmd .. ", removed: " .. table.concat(removedPlayers, ", ") .. " from the looplist.")
		end

	elseif cmd == "die" or cmd == "reset" then
		if humanoid then humanoid.Health = 0 end
		rbxg:SendAsync("resetting")
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", resetted.")

	elseif cmd == "goto" then
		local x, y, z
		if args[1] then
			local xyzString = args[1]
			x, y, z = xyzString:match("(-?%d+%.?%d*),?%s*(-?%d+%.?%d*),?%s*(-?%d+%.?%d*)")
		end
		if not (x and y and z) and #args >= 3 then
			x, y, z = args[1], args[2], args[3]
		end
		if x and y and z then
			x, y, z = tonumber(x), tonumber(y), tonumber(z)
			if x and y and z and root then
				floating = true
				local tw = tween:Create(root, TweenInfo.new(3), {CFrame = CFrame.new(x, y, z)})
				tw:Play()
				tw.Completed:Wait()
				floating = false
				root.Velocity = Vector3.new(0,0,0)
				rbxg:SendAsync("went to "..x..", "..y..", "..z)
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", succesfully went to: "..x..", "..y..", "..z)
			else
				rbxg:SendAsync("where")
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find coordinates.")
			end
		else
			rbxg:SendAsync("Usage: goto x,y,z  OR  goto x y z")
		end

	elseif cmd:sub(1,10) == "gotoplayer" then
		local targetName = table.concat(args, " "):lower()
		local targetPlayer = findPlayerByName(targetName)

		if not root then
			rbxg:SendAsync("u dont have a root lol")
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find commander's root.")
			return
		end

		if targetPlayer and targetPlayer.Character then
			local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				root.CFrame = targetRoot.CFrame
				root.Velocity = Vector3.new(0,0,0)
				rbxg:SendAsync("successfully went to "..targetPlayer.DisplayName.." ("..targetPlayer.Name..")")
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", successfully went to target.")
			else
				rbxg:SendAsync("player has no root part, strange")
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", player has no rootpart.")
			end
		else
			rbxg:SendAsync("couldnt find player :pensive:")
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find player.")
		end

	elseif cmd == "setspawn" then
		local x, y, z
		if #args > 0 then
			local xyzString = table.concat(args, " ")
			x, y, z = xyzString:match("(-?%d+%.?%d*),?%s*(-?%d+%.?%d*),?%s*(-?%d+%.?%d*)")
		end
		if x and y and z then
			x, y, z = tonumber(x), tonumber(y), tonumber(z)
			if x and y and z then
				spawnPoint = CFrame.new(x, y, z)
				rbxg:SendAsync("i will now spawn at: "..x..", "..y..", "..z)
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", successfully set spawn to: "..x..", "..y..", "..z)
			else
				rbxg:SendAsync("invalid coordinates :(((")
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find/invalid coordinates.")
			end
		elseif root then
			spawnPoint = root.CFrame
			rbxg:SendAsync("set spawn to my location")
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", set spawn to current location.")
		else
			rbxg:SendAsync("i cant find root")
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find root.")
		end

	elseif cmd == "rejoin" then
		rbxg:SendAsync("rejoining...")
		teleportServ:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", MANUAL RE-EXECUTE REQUIRED.")

	elseif cmd == "hide" then
		rbxg:SendAsync("you cant find me now!!!")
		hiding = true
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", hid SpawnYellow.")

	elseif cmd == "unhide" then
		rbxg:SendAsync("alright you win")
		hiding = false
		if root then
			root.Velocity = Vector3.new(0,0,0)
			root.CFrame = lpos
		end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", unhid SpawnYellow.")

	elseif cmd == "float" then
		rbxg:SendAsync("floating")
		floating = true
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", floating.")

	elseif cmd == "unfloat" then
		rbxg:SendAsync("unfloating")
		floating = false
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", unfloated.")

	elseif cmd == "gameid" then
		print("gameId: "..tostring(game.PlaceId))
		if rbxg then pcall(function() rbxg:SendAsync("gameId: "..tostring(game.PlaceId)) end) end
		webhook_sendMsg(overall_LOGGER, "Used command: ".."gameId: "..tostring(game.PlaceId)..", ".."gameId: "..tostring(game.PlaceId))

	elseif cmd == "jobid" then
		print("jobId: "..tostring(game.JobId))
		if rbxg then pcall(function() rbxg:SendAsync("jobId: "..tostring(game.JobId)) end) end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", ".."jobId: "..tostring(game.JobId))

	elseif cmd == "creatorid" then
		print("creatorId: "..tostring(game.CreatorId))
		if rbxg then pcall(function() rbxg:SendAsync("creatorId: "..tostring(game.CreatorId)) end) end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", ".."creatorId: "..tostring(game.CreatorId))

	elseif cmd == "servertype" then
		local typeStr = (game:GetService("RunService"):IsStudio() and "Studio" or "Game")
		print("serverType: "..typeStr)
		if rbxg then pcall(function() rbxg:SendAsync("serverType: "..typeStr) end) end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", ".."serverType: "..typeStr)

	elseif cmd == "servertime" then
		print("serverTime: "..tostring(tick()))
		if rbxg then pcall(function() rbxg:SendAsync("serverTime: "..tostring(tick())) end) end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", ".."serverTime: "..tostring(tick()))

	elseif cmd == "serverhop" then
		local TeleportService = game:GetService("TeleportService")
		local HttpService = game:GetService("HttpService")
		local LocalPlayer = game.Players.LocalPlayer
		local placeId = game.PlaceId

		local function getAvailableServers(cursor)
			local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
			if cursor then url = url .. "&cursor=" .. cursor end
			local success, res = pcall(function() return HttpService:GetAsync(url) end)
			if success and res then
				return HttpService:JSONDecode(res)
			else
				warn("Failed to fetch server list")
				return nil
			end
		end

		local serversData = getAvailableServers()
		if serversData and serversData.data then
			local myJobId = game.JobId
			local targetServer
			for _, server in ipairs(serversData.data) do
				if server.playing < server.maxPlayers and server.id ~= myJobId then
					targetServer = server.id
					break
				end
			end

			if targetServer then
				local msg = "serverhopping to server ID: "..targetServer
				print(msg)
				if rbxg then pcall(function() rbxg:SendAsync(msg) end) end
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", "..msg)
				if LocalPlayer then
					TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
				else
					warn("LocalPlayer not found, cannot teleport")
				end
			else
				local msg = "no available servers found"
				print(msg)
				if rbxg then pcall(function() rbxg:SendAsync(msg) end) end
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", "..msg)
			end
		end

	elseif cmd == "ping" or cmd == "latency" then
		local stats = game:GetService("Stats")
		local item = stats.Network.ServerStatsItem["Data Ping"]
		local ms = tonumber(((item and item:GetValueString()) or ""):match("%d+")) or 0
		local msg = "Ping: "..ms.."ms"
		print(msg)
		if rbxg then rbxg:SendAsync(msg) end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", "..msg)

	elseif cmd == "bring" then
		local target = findPlayerByName(args[1] or "")
		if not target or not target.Character then
			if rbxg then rbxg:SendAsync("bring: target not found") end
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", target not found")
			return
		end

		local dest
		if args[2] then
			if args[2]:match("^%-?%d+[, ]%s*%-?%d+[, ]%s*%-?%d+") then
				local posStr = table.concat(args, " ")
				local x, y, z = posStr:match("(-?%d+%.?%d*)[%s,]+(-?%d+%.?%d*)[%s,]+(-?%d+%.?%d*)")
				if x and y and z then
					dest = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
				end
		
			elseif args[2]:lower() == "spawn" and spawnPoint then
				dest = spawnPoint.Position
		
			elseif args[2]:lower() == "platform1" then
				dest = Vector3.new(-119, 250, -133)
		
			elseif findPlayerByName(args[2]) then
				local other = findPlayerByName(args[2])
				if other and other.Character then
					local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
					if otherRoot then
						dest = otherRoot.Position
					end
				end
			end
		end

		if not dest then
			if rbxg then rbxg:SendAsync("bring: no destination found") end
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", no destination found")
			return
		end

		local theirRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if not theirRoot then return end

		if not (humanoid and root) then return end
		local oldGrav = workspace.Gravity
		workspace.Gravity = 0

		bringing = true

		febring(char, target.Character, dest)

		bringing = false
		workspace.Gravity = oldGrav
		root.Velocity = Vector3.zero
		root.CFrame = root.CFrame

		if rbxg then rbxg:SendAsync("bring: "..target.Name) end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", brought "..target.Name)

	elseif cmd == "resetgrav" then
		workspace.Gravity = 196.2
		if rbxg then rbxg:SendAsync("reset gravity") end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd)
	else
		print("command not found")
		if math.random(1,15) == 1 then
			rbxg:SendAsync(confusion[math.random(1,#confusion)])
		end
	end
end

local function isGrounded(char)
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local rayOrigin = root.Position
	local rayDirection = Vector3.new(0, -5, 0)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {char}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(rayOrigin, rayDirection, params)
	return result ~= nil
end

local function monitor(p)
	local c = p.Character or p.CharacterAdded:Wait()
	if not c then return end

	local root = c:FindFirstChild("HumanoidRootPart")
	local humanoid = c:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end

	local prevPos, prevTime = root.Position, tick()
	local hoverStart = nil

	local violationLimit = 3
	local violationCount = {tp = 0, speed = 0, fly = 0, fling = 0, reach = {}}
	local debounce = {tp = 0, speed = 0, fly = 0, fling = 0}
	local lastAlert = {}

	local flingVelThreshold, flingSpinThreshold = 2000, 3000
	local impossibleSpeed = 80
	local speedHistory = {}
	local maxHistory = 5
	local alertCooldown = 5

	local threshold = 10

	local function getSmoothedSpeed(newSpeed)
		table.insert(speedHistory, newSpeed)
		if #speedHistory > maxHistory then
			table.remove(speedHistory, 1)
		end
		local total = 0
		for _, s in ipairs(speedHistory) do
			total += s
		end
		return total / #speedHistory
	end

	runs.RenderStepped:Connect(function()
		if whitelist[p.Name] or not p.Character or (player and p == player) then return end
		c = p.Character
		root = c and c:FindFirstChild("HumanoidRootPart")
		humanoid = c and c:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return end

		local now = tick()
		local currPos = root.Position
		local dt = now - prevTime
		if dt <= 0.015 then return end

		local dist = (Vector3.new(currPos.X, 0, currPos.Z) - Vector3.new(prevPos.X, 0, prevPos.Z)).Magnitude
		local rawSpeed = dist / dt
		local state = humanoid:GetState()

		local grounded = isGrounded and isGrounded(c)
		local vertVel = math.abs(root.Velocity.Y)

		if state == Enum.HumanoidStateType.Running and dist > 50 and rawSpeed > 10 and now - debounce.tp > 5 then
			violationCount.tp += 1
			if violationCount.tp >= violationLimit then
				debounce.tp = now
				violationCount.tp = 0
				local k = p.Name.."_tp"
				if not lastAlert[k] or now - lastAlert[k] > alertCooldown then
					lastAlert[k] = now
					table.insert(bad_mans, p.Name)
					loopkilling = loopkilling or true
					pcall(function()
						if rbxg then
							rbxg:SendAsync(p.Name.." used imaginary ender pearl ("..math.floor(dist).." studs)")
						end
						webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") teleported")
						webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
					end)
				end
			end
		else
			violationCount.tp = 0
		end

		if rawSpeed <= impossibleSpeed then
			local speed = getSmoothedSpeed(rawSpeed)
			if state == Enum.HumanoidStateType.Running and speed > 65 and now - debounce.speed > 3 then
				violationCount.speed += 1
				if violationCount.speed >= violationLimit then
					debounce.speed = now
					violationCount.speed = 0
					local k = p.Name.."_speed"
					if not lastAlert[k] or now - lastAlert[k] > alertCooldown then
						lastAlert[k] = now
						table.insert(bad_mans, p.Name)
						loopkilling = loopkilling or true
						pcall(function()
							if rbxg then
								rbxg:SendAsync(p.Name.." u cant sprint here dummy (Speed: "..string.format("%.2f", speed)..")")
							end
							webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") used speed exploits.")
							webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
						end)
					end
				end
			else
				violationCount.speed = 0
			end
		end

		if not grounded then
			if vertVel < 2 and rawSpeed > 3 then
				if not hoverStart then
					hoverStart = now
				elseif now - hoverStart > 1.5 and now - debounce.fly > 5 then
					violationCount.fly += 1
					if violationCount.fly >= violationLimit then
						debounce.fly = now
						violationCount.fly = 0
						local k = p.Name.."_fly"
						if not lastAlert[k] or now - lastAlert[k] > alertCooldown then
							lastAlert[k] = now
							table.insert(bad_mans, p.Name)
							loopkilling = loopkilling or true
							pcall(function()
								if rbxg then
									rbxg:SendAsync(p.Name.." u dont look like a bird... seems sus...")
								end
								webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") is flying.")
								webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
							end)
						end
					end
				end
			else
				hoverStart = nil
				violationCount.fly = 0
			end
		else
			hoverStart = nil
			violationCount.fly = 0
		end

		local vel, spin = root.Velocity.Magnitude, root.RotVelocity.Magnitude
		if vel > flingVelThreshold or spin > flingSpinThreshold then
			if now - debounce.fling > 3 then
				violationCount.fling += 1
				if violationCount.fling >= violationLimit then
					debounce.fling = now
					violationCount.fling = 0
					local k = p.Name.."_fling"
					if not lastAlert[k] or now - lastAlert[k] > alertCooldown then
						lastAlert[k] = now
						table.insert(bad_mans, p.Name)
						loopkilling = loopkilling or true
						pcall(function()
							if rbxg then
								rbxg:SendAsync(p.Name.." what r u doing (Vel: "..math.floor(vel).." / Spin: "..math.floor(spin)..")")
							end
							webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") is using fling exploits.")
							webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
						end)
					end
				end
			end
		else
			violationCount.fling = 0
		end

		prevPos = currPos
		prevTime = now

		for _, attacker in pairs(players:GetPlayers()) do
			if attacker ~= p and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") then
				local attackerRoot = attacker.Character.HumanoidRootPart
				for _, target in pairs(players:GetPlayers()) do
					if target ~= attacker and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
						local targetRoot = target.Character.HumanoidRootPart
						local tooFarHit = false
						local closestDistance = math.huge

						local limbNames
						if attacker.Character:FindFirstChild("RightHand") then
							limbNames = {"RightHand","RightLowerArm","RightUpperArm","LeftHand","LeftLowerArm","LeftUpperArm"}
							threshold = 12
						else
							limbNames = {"RightArm","LeftArm"}
							threshold = 10
						end

						for _, limbName in ipairs(limbNames) do
							local limb = attacker.Character:FindFirstChild(limbName)
							if limb and limb:IsA("BasePart") then
								local d = (limb.Position - targetRoot.Position).Magnitude
								if d > threshold then
									tooFarHit = true
								end
								if d < closestDistance then
									closestDistance = d
								end
							end
						end

						if tooFarHit then
							local key = attacker.Name..":"..target.Name
							violationCount.reach[key] = (violationCount.reach[key] or 0) + 1

							if violationCount.reach[key] >= 2 then
								local now = tick()
								local k = attacker.Name.."_reach"
								if not lastAlert[k] or now - lastAlert[k] > alertCooldown then
									lastAlert[k] = now
									table.insert(bad_mans, attacker.Name)
									loopkilling = loopkilling or true
									pcall(function()
										if rbxg then
											rbxg:SendAsync(attacker.Name.." reached "..target.Name.." ("..string.format("%.2f", closestDistance).." studs)")
										end
										webhook_sendMsg(overall_LOGGER, attacker.DisplayName.." ("..attacker.Name..") used reach exploit on "..target.Name)
										webhook_sendMsg(overall_LOGGER, "Added "..attacker.DisplayName.." ("..attacker.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
									end)
								end
								violationCount.reach[key] = 0
							end
						else
							violationCount.reach[attacker.Name..":"..target.Name] = 0
						end
					end
				end
			end
		end
	end)
end

local function on_chatted(p)
	p.Chatted:Connect(function(msg)
		webhook_logChat(p,msg)
		if whitelist[p.Name] then
			if p.Name ~= player.Name then
				do_command(msg)	
			end
		else
			print('no')
			--if p.Name ~= player.Name then
			--	webhook_sendMsg(overall_LOGGER, p.Name.." non-whitelist player tried to use a command.")
			--end
			if math.random(1,20) == 1 then
				rbxg:SendAsync(dummy[math.random(1,#dummy)])
			end
		end
	end)
end

players.PlayerAdded:Connect(function(p)
	webhook_sendMsg(overall_LOGGER, p.DisplayName.."("..p.Name..") joined.")
	on_chatted(p)
	monitor(p)
	if p.Name == "s71pl" then
		rbxg:SendAsync("OMG!!! HI DAD!!!")
	end
end)

for i, v in pairs(players:GetPlayers()) do
	on_chatted(v)
	monitor(v)
	if v.Name == "s71pl" then
		rbxg:SendAsync("OMG!!! HI DAD!!!")
	end
end

players.PlayerRemoving:Connect(function(p)
	webhook_sendMsg(overall_LOGGER, p.DisplayName.."("..p.Name..") left.")
end)
