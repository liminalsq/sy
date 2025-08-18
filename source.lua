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
	['BorrowGoal'] = true,
	['JeremysCherryl'] = true
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

local death = {
	"oww!!! >-<",
	"IM TELLING DAD",
	"*wails loudly*",
	"aughh!!! ;-;",
	"DADDDDD",
	"DADD HE HIT ME",
	"UGHH!!",
	"OUCH!!",
	"dad i have a boo boo 😭😭😭",
	"i just wanted to be friends :("
}

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

	humanoid.Died:Once(function()
		rbxg:SendAsync(death[math.random(1,#death)])
	end)
end)

task.spawn(function()
	while wait(0.9) do
		if loopkilling then
			local tool = find_tool(player.Backpack)
			if tool then
				local handle = find_handle(tool)
				if handle then
					wait(0.9)
					if tool.Parent ~= char then
						humanoid:EquipTool(tool)
					end
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
	end

	if not bringing and not hiding then
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

local function do_command(input)
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	local args = string.split(input, " ")
	local cmd = args[1]:lower() -- lowercase only the command
	table.remove(args, 1) -- remove command from args
	
	--probably important functions
	local bringQueue = {}
	local isBringing = false

	local function processBringQueue()
		if isBringing or #bringQueue == 0 then return end
		isBringing = true

		while #bringQueue > 0 do
			local job = table.remove(bringQueue, 1)
			local target, dest = job.target, job.dest

			if target and target.Character then
				local theirRoot = target.Character:FindFirstChild("HumanoidRootPart")
				if theirRoot and humanoid and root then
					local oldGrav = workspace.Gravity
					workspace.Gravity = 0

					bringing = true
					febring(char, target.Character, dest)
					bringing = false

					workspace.Gravity = oldGrav
					root.Velocity = Vector3.zero
					root.CFrame = root.CFrame

					if rbxg then rbxg:SendAsync("brought: "..target.Name.." to "..tostring(dest)) end
					webhook_sendMsg(overall_LOGGER, "Used command: bring, brought "..target.Name.." ("..target.DisplayName..")")
				end
			end
		end

		isBringing = false
	end

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
		local servers = {}
		local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
		local body = httpsService:JSONDecode(req)

		if body and body.data then
			for i, v in next, body.data do
				if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
					table.insert(servers, 1, v.id)
				end
			end
		end

		if #servers > 0 then
			local server = servers[math.random(1, #servers)]
			teleportServ:TeleportToPlaceInstance(game.PlaceId, server, player)
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", ".."serverhop successful. New Server Instance/Job Id: "..server)
		else
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", ".."serverhop unsuccessful. Couldn't find a server or server was full.")
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
		local rawNames = args[1] or ""
		local names = string.split(rawNames, ",")
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
			if rbxg then rbxg:SendAsync("where do u want me to bring u") end
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", no destination found")
			return
		end

		for _, name in ipairs(names) do
			name = name:match("^%s*(.-)%s*$") -- trim spaces
			local target = findPlayerByName(name)
			if target and target.Character then
				table.insert(bringQueue, {target = target, dest = dest})
			else
				if rbxg then rbxg:SendAsync("bring: "..name.." not found") end
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", target "..name.." not found")
			end
		end

		processBringQueue()
	
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

	local r = c:FindFirstChild("HumanoidRootPart")
	local h = c:FindFirstChildOfClass("Humanoid")
	if not r or not h then return end

	local prevPos, prevTime = r.Position, tick()
	local hoverStart = nil
	local violationLimit = 3
	local violationCount = {tp = 0, speed = 0, fly = 0, fling = 0, infjump = 0, reach = {}}
	local debounce = {tp = 0, speed = 0, fly = 0, fling = 0, infjump = 0}
	local lastAlert = {}
	local bad_mans = {}

	local flingVelThreshold, flingSpinThreshold = 2000, 3000
	local impossibleSpeed = 80
	local speedHistory = {}
	local maxHistory = 5
	local alertCooldown = 5
	local jumpTimestamps = {}
	local jumpCooldown = 0.25
	local maxRapidJumps = 3

	local function getSmoothedSpeed(newSpeed)
		speedHistory = speedHistory or {}
		table.insert(speedHistory, newSpeed)
		if #speedHistory > 5 then table.remove(speedHistory, 1) end
		local total = 0
		for _, s in ipairs(speedHistory) do total += s end
		return total / #speedHistory
	end

	local function flagPlayer(player, reason, messageCallback)
		local now = tick()
		if now - (debounce[reason] or 0) < alertCooldown then return end
		debounce[reason] = now

		do_command("lkill "..player.Name)
		pcall(function()
			if rbxg then rbxg:SendAsync(messageCallback()) end
			webhook_sendMsg(overall_LOGGER, player.DisplayName.." ("..player.Name..") "..reason)
		end)
	end

	runs.RenderStepped:Connect(function()
		if whitelist[p.Name] or not p.Character then return end
		c = p.Character
		r = c:FindFirstChild("HumanoidRootPart")
		h = c:FindFirstChildOfClass("Humanoid")
		if not r or not h then return end

		local now = tick()
		local dt = now - prevTime
		if dt <= 0.015 then return end

		local currPos = r.Position
		local dist = (Vector3.new(currPos.X,0,currPos.Z) - Vector3.new(prevPos.X,0,prevPos.Z)).Magnitude
		local rawSpeed = dist / dt
		local state = h:GetState()
		local grounded = isGrounded and isGrounded(c)
		local vertVel = r.Velocity.Y

		if state ~= Enum.HumanoidStateType.Running and dist > 50 and rawSpeed > 10 then
			violationCount.tp += 1
			if violationCount.tp >= violationLimit then
				violationCount.tp = 0
				flagPlayer(p, "tp", function()
					return p.Name.." teleported "..math.floor(dist).." studs"
				end)
			end
		else
			violationCount.tp = 0
		end

		local speed = getSmoothedSpeed(rawSpeed)
		if state == Enum.HumanoidStateType.Running and speed > 65 then
			violationCount.speed += 1
			if violationCount.speed >= violationLimit then
				violationCount.speed = 0
				flagPlayer(p, "speed", function()
					return p.Name.." suspicious sprinting (Speed: "..string.format("%.2f", speed)..")"
				end)
			end
		else
			violationCount.speed = 0
		end

		if not grounded then
			local hovering = math.abs(vertVel) < 1 and rawSpeed > 3
			if hovering then
				if not hoverStart then hoverStart = now
				elseif now - hoverStart > 1.5 then
					violationCount.fly += 1
					if violationCount.fly >= violationLimit then
						violationCount.fly = 0
						flagPlayer(p, "fly", function()
							return p.Name.." is flying"
						end)
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

		local vel, spin = r.Velocity.Magnitude, r.RotVelocity.Magnitude
		if vel > 2000 or spin > 3000 then
			violationCount.fling += 1
			if violationCount.fling >= violationLimit then
				violationCount.fling = 0
				flagPlayer(p, "fling", function()
					return p.Name.." is using fling (Vel: "..math.floor(vel)..", Spin: "..math.floor(spin)..")"
				end)
			end
		else
			violationCount.fling = 0
		end
		
		if state == Enum.HumanoidStateType.Jumping then
			if not jumpTimestamps[p] then jumpTimestamps[p] = {} end

			local now = tick()
			local lastJump = jumpTimestamps[p][#jumpTimestamps[p]]
			if not lastJump or now - lastJump > jumpCooldown then
				table.insert(jumpTimestamps[p], now)
			end

			for i = #jumpTimestamps[p], 1, -1 do
				if now - jumpTimestamps[p][i] > jumpCooldown then
					table.remove(jumpTimestamps[p], i)
				end
			end

			if #jumpTimestamps[p] > maxRapidJumps then
				violationCount.infjump += 1
				if violationCount.infjump >= violationLimit then
					violationCount.infjump = 0
					local now = tick()
					if now - (debounce.infjump or 0) >= alertCooldown then
						debounce.infjump = now
						flagPlayer(p, "infjump", function()
							return p.Name.." is using infinite jump."
						end)
					end
				end
			end
		else
			violationCount.infjump = 0
		end

		prevPos = currPos
		prevTime = now
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
		if p.Name == "s71pl" then
			if msg:lower():find("spawnyellow") or msg:lower():find("son") then
				rbxg:SendAsync("hi dad!!")
			elseif msg:lower():find("my boy") then
				rbxg:SendAsync(">v<")
			elseif msg:lower():find("pat") and (p.Character:WaitForChild("HumanoidRootPart").Position - root.Position).Magnitude <= 8 then
				rbxg:SendAsync(">⏑<")
			end
		end
	end)
end

players.PlayerAdded:Connect(function(p)
	webhook_sendMsg(overall_LOGGER, p.DisplayName.."("..p.Name..") joined.")
	on_chatted(p)
	if p ~= player or p.Name ~= player.Name then
		monitor(p)
	end
	if p.Name == "s71pl" then
		rbxg:SendAsync("OMG!!! HI DAD!!!")
	elseif p.Name == "TheTerminalClone" then
		rbxg:SendAsync("hi terminal!1!")
	elseif p.Name == "ColonThreeSpam" then
		rbxg:SendAsync("hi fluffy boi!!!")
	end
end)

for i, v in pairs(players:GetPlayers()) do
	on_chatted(v)
	if v ~= player or v.Name ~= player.Name then
		monitor(v)
	end
	if v.Name == "s71pl" then
		rbxg:SendAsync("OMG!!! HI DAD!!!")
	elseif v.Name == "TheTerminalClone" then
		rbxg:SendAsync("hi terminal!1!")
	elseif v.Name == "ColonThreeSpam" then
		rbxg:SendAsync("hi fluffy boi!!!")
	end
end

players.PlayerRemoving:Connect(function(p)
	webhook_sendMsg(overall_LOGGER, p.DisplayName.."("..p.Name..") left.")
end)
