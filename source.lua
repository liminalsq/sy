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

local float_part = Instance.new("Part")
float_part.Name = "f"
float_part.Anchored = true
float_part.Transparency = 0.9
float_part.CanCollide = true
float_part.Parent = repstor

local bad_mans = {}

local whitelist = {
	['PlayerEater9'] = true,
	['ColonThreeSpam'] = true,
	['TheTerminalClone'] = true,
	['SpawnYellow1'] = true,
	["s71pl"] = true,
	["RealPerson_0010"] = true,
	['skyjp'] = true,
	['cool0205p'] = true,
	['cashier9298'] = true,
	['d1sc0rd0'] = true,
	['d1sc0rd00'] = true,
	['adamxdd690'] = true,
	['redalert_E'] = true
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
			local name = bad_mans[i]
			local targetPlayer = players:FindFirstChild(name)
			if targetPlayer and targetPlayer.Character then
				local h = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
				local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if h and hrp then
					local tool = find_tool(currentChar)
					local handle = find_handle(tool)
					if tool and handle then
						tool:Activate()
						kill(handle, hrp)
					end
				end
			end
		end
	end
	if hiding then
		if root then
			root.CFrame = CFrame.new(0,-65536,65536)
		end
	else
		if root then
			lpos = root.CFrame
		end
	end
	if floating then
		float_part.Parent = workspace
		float_part.Position = root.Position - Vector3.new(0,3.95,0)
	else
		float_part.Parent = repstor
	end
end)

local function do_command(input)
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	local args = string.split(string.lower(input), " ")
	local cmd = args[1]
	table.remove(args, 1)

	if cmd == "fps" then
		print(fps)
		rbxg:SendAsync("FPS: "..tostring(fps))
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", FPS: "..tostring(fps))
	elseif cmd:sub(1,5) == "lkill" then
		local argsStr = cmd:sub(7)
		for name in argsStr:gmatch("[^,%s]+") do
			if not table.find(bad_mans, name) then
				table.insert(bad_mans, name)
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", Added: ".."'"..name.."' to the looplist and set loopkilling to true.")
			end
		end
		loopkilling = true
		print("killing " .. table.concat(bad_mans, ", "))
		rbxg:SendAsync("ur cooked, " .. table.concat(bad_mans, ", "))

	elseif cmd == "stoplkill" then
		loopkilling = false
		rbxg:SendAsync("stopped: lkill")
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", stopped loopkill.")
	elseif cmd == "cleartargets" then
		bad_mans = {}
		rbxg:SendAsync("cleared list of bad mans!!")
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", cleared: "..table.concat(bad_mans, ", ").." from the looplist.")
	elseif cmd:sub(1,18) == "removefromtargets" then
		local argsStr = cmd:sub(20)
		for name in argsStr:gmatch("[^,%s]+") do
			local index = table.find(bad_mans, name)
			if index then
				table.remove(bad_mans, index)
				webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", Removed: ".."'"..name.."' from the looplist.")
			end
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
				tween:Create(root, TweenInfo.new(3), {CFrame = CFrame.new(x, y, z)}):Play()
				tween:Create(root, TweenInfo.new(3), {CFrame = CFrame.new(x, y, z)}).Completed:Wait()
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
	elseif cmd == "setspawn" then
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
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", didn't put any coordinates, set spawn to current location instead.")
		else
			rbxg:SendAsync("i cant find root")
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find root.")
		end
	elseif cmd == "rejoin" then
		rbxg:SendAsync("rejoining...")
		teleportServ:Teleport(game.PlaceId, player)
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", MANUAL RE-EXECUTE REQUIRED.")
	elseif cmd == "hide" then
		rbxg:SendAsync("you cant find me now!!!")
		hiding = true
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", hid SpawnYellow.")
	elseif cmd == "unhide" then
		rbxg:SendAsync("alright you win")
		hiding = false
		if root then
			rroot.Velocity = Vector3.new(0,0,0)
			root.CFrame = lpos
		end
		webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", unhid SpawnYellow.")
	elseif cmd:sub(1,10) == "gotoplayer" then
		local targetName = table.concat(args, " ")
		local targetPlayer = game.Players:FindFirstChild(targetName)

		if not root then
			rbxg:SendAsync("u dont have a root lol")
			webhook_sendMsg(overall_LOGGER, "Used command: "..cmd..", couldn't find commander's root..")
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
	else
		print("command not found")
		--webhook_sendMsg(overall_LOGGER, "Invalid/nonexistant command.")
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

	local flingVelThreshold, flingSpinThreshold = 2000, 3000
	local impossibleSpeed = 80
	local speedHistory = {}
	local maxHistory = 5

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
				if rbxg then
					rbxg:SendAsync(p.Name.." used imaginary ender pearl ("..math.floor(dist).." studs)")
					webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") teleported")
				end
				table.insert(bad_mans, p.Name)
				loopkilling = loopkilling or true
				webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
			end
		else
			violationCount.tp = 0
		end

		if rawSpeed <= impossibleSpeed then
			local speed = getSmoothedSpeed(rawSpeed)
			if state == Enum.HumanoidStateType.Running and speed > 75 and now - debounce.speed > 3 then
				violationCount.speed += 1
				if violationCount.speed >= violationLimit then
					debounce.speed = now
					violationCount.speed = 0
					if rbxg then
						rbxg:SendAsync(p.Name.." u cant sprint here dummy (Speed: "..string.format("%.2f", speed)..")")
						webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") used speed exploits.")
					end
					table.insert(bad_mans, p.Name)
					loopkilling = loopkilling or true
					webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
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
						if rbxg then
							rbxg:SendAsync(p.Name.." u dont look like a bird... seems sus...")
							webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") is flying.")
						end
						table.insert(bad_mans, p.Name)
						loopkilling = loopkilling or true
						webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
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
					if rbxg then
						rbxg:SendAsync(p.Name.." what r u doing (Vel: "..math.floor(vel).." / Spin: "..math.floor(spin)..")")
						webhook_sendMsg(overall_LOGGER, p.DisplayName.." ("..p.Name..") is using fling exploits.")
					end
					table.insert(bad_mans, p.Name)
					loopkilling = loopkilling or true
					webhook_sendMsg(overall_LOGGER, "Added "..p.DisplayName.." ("..p.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
				end
			end
		else
			violationCount.fling = 0
		end

		prevPos = currPos
		prevTime = now

		for _, attacker in pairs(players:GetPlayers()) do
			if attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart") then
				local attackerRoot = attacker.Character.HumanoidRootPart
				local attackerHumanoid = attacker.Character:FindFirstChildOfClass("Humanoid")

				for _, target in pairs(players:GetPlayers()) do
					if target ~= attacker and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
						for _, part in ipairs(attacker.Character:GetChildren()) do
							if part:IsA("BasePart") then
								for _, touched in ipairs(part:GetTouchingParts()) do
									if touched:IsDescendantOf(target.Character) then
										local d = (attackerRoot.Position - target.Character.HumanoidRootPart.Position).Magnitude
										if d > 12 then
											local key = attacker.Name..":"..target.Name
											violationCount.reach[key] = violationCount.reach[key] or 0
											if now - violationCount.reach[key] > 3 then
												violationCount.reach[key] = now
												if attackerHumanoid and attackerHumanoid.Parent and attackerHumanoid.Parent:FindFirstChild("HumanoidRootPart") then
													webhook_sendMsg(overall_LOGGER, attacker.Name.." reached "..target.Name.." at ("..string.format("%.2f", d)..")")
													if now - monitortimer > 0.5 then
														monitortimer = now
														rbxg:SendAsync(attacker.Name.." reached "..target.Name.." ("..string.format("%.2f", d)..")")
													end
												end
												table.insert(bad_mans, attacker.Name)
												loopkilling = loopkilling or true
												webhook_sendMsg(overall_LOGGER, "Added "..attacker.DisplayName.." ("..attacker.Name..") to the looplist. (TEMPORARY. IF SPAWNYELLOW DISCONNECTS IN ANY WAY, THE LOOPLIST WILL RESET.)")
											end
										end
									end
								end
							end
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
			do_command(msg)	
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

