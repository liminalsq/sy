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

local function webhook_sendMsg(webhooks, msg)
	if typeof(webhooks) == "string" then
		webhooks = {webhooks}
	end

	for _, url in ipairs(webhooks) do
		requestFunction({
			Url = url,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = httpsService:JSONEncode({["content"] = msg})
		})
	end
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
local hiding = true
local floating = false
local bringing = false
local aUnequip = true
local autoR = true
local autoThres = 3

local function generateNameVariants(plr)
	local variants = {}

	local function addVariants(str)
		if not str or str == "" then return end
		table.insert(variants, str)
		table.insert(variants, str:lower())

		for i = 1, #str do
			local sub = str:sub(i)
			if sub and sub ~= "" then
				table.insert(variants, sub)
				table.insert(variants, sub:lower())
			end
		end
	end

	addVariants(plr.Name)
	addVariants(plr.DisplayName)

	return variants
end

if char:FindFirstChild("Animate") then
	char.Animate:Remove()
end

if humanoid then
	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop(0)
	end
end

local CharacterAnimations = {
	cgirls = loadstring(game:HttpGet("https://raw.githubusercontent.com/liminalsq/SpawnYellowEmotes/refs/heads/main/CaliforniaGirls.lua"))
}

local function anim(char, animName) -- ALSO STEVE/TERMINAL CODE SNIPPET
	local ROOT_POSITION = Vector3.new(0, 65536, 0)
	local CHAR_POSITION = Vector3.new(0, 255, 0)

	local function SetMotor6DOffset(motor, trans)
		motor.MaxVelocity = 9e9
		motor:SetDesiredAngle(math.random() * math.pi)
		local axis, angle = trans:ToAxisAngle()
		pcall(sethiddenproperty, motor, "ReplicateCurrentOffset6D", trans.Position)
		pcall(sethiddenproperty, motor, "ReplicateCurrentAngle6D", axis * angle)
	end

	local CharacterAnimation = {
		Name = "",
		Time = 0,
		Keyframes = {},
	}
	local CharacterAnimationTime = 0
	local function LoadAnimation()
		if animName == CharacterAnimation.Name then return end
		local limbnames = {"Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
		local CharacterAnimationData = CharacterAnimations[animName]
		if CharacterAnimationData == nil then return end
		local ilikeit = {
			Name = animName,
			Time = CharacterAnimationData.Time or 0,
			Keyframes = {},
		}
		for t=0, CharacterAnimationData.Time, 1 / 30 do
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
							a = tween:GetValue(
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
	end

	LoadAnimation()
	while true do
		local dt = task.wait()
		CharacterAnimationTime = (CharacterAnimationTime + dt) % math.max(1e-6, CharacterAnimation.Time)
		local ckf = {}
		for i=1, #CharacterAnimation.Keyframes do
			ckf = CharacterAnimation.Keyframes[i]
			if ckf.Time > CharacterAnimationTime then break end
		end
		ckf = ckf.Poses or {}
		if I.Character ~= nil then
			local Char = char
			local Root = Char:FindFirstChild("HumanoidRootPart")
			if Root ~= nil then
				Root.CFrame = CFrame.new(ROOT_POSITION)
				Root.Velocity = Vector3.zero
				Root.RotVelocity = Vector3.zero
			end
			for _,v in pairs(Char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
					v.CanTouch = v.Name == "Handle"
					v.Massless = true
				end
				if v:IsA("Motor6D") and v.Part1 ~= nil then
					local cf = ckf[v.Part1.Name] or CFrame.identity
					if v.Name == "RootJoint" then
						cf += CHAR_POSITION - ROOT_POSITION
					end
					SetMotor6DOffset(v, cf)
				end
			end
		end
	end
end

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
	['JeremysCherryl'] = true,
	['STEVETheReal916'] = true,
	['TMKOC63'] = true
}

local blacklist = {
	['Dollmyaccdisabled686'] = true
}

if isfile("blacklist.txt") then
	local contents = readfile("blacklist.txt")
	for name in contents:gmatch("[^\r\n]+") do
		blacklist[name:lower()] = true
	end
end

for name in pairs(blacklist) do
	table.insert(bad_mans, name:lower())
end

local exclude = {}

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
		else
			if aUnequip then
				humanoid:UnequipTools()
				task.wait()
			end
		end 
	end
end)

local function kill(toolHandle, targetHumanoidRootPart)
	pcall(function() -- will have errors lol
		firetouchinterest(toolHandle, targetHumanoidRootPart, 0)
		firetouchinterest(toolHandle, targetHumanoidRootPart, 1)
	end)
end

local killCooldowns = {}
local lpos = root.CFrame

local resTimer = 0

local connections = {}

runs.Heartbeat:Connect(function()
	if humanoid and humanoid.Health > 0 then
		local hasTargets = false
		local targets = {}

		for name, _ in pairs(blacklist) do
			targets[name:lower()] = true
		end
		for _, name in ipairs(bad_mans) do
			targets[name:lower()] = true
		end

		for _, p in ipairs(players:GetPlayers()) do
			local pname = p.Name:lower()
			local dname = p.DisplayName:lower()
			if targets[pname] or targets[dname] then
				hasTargets = true
				break
			end
		end

		if not hasTargets then
			loopkilling = false
			for p, conn in pairs(connections) do
				if conn then conn:Disconnect() end
			end
			connections = {}
			return
		end

		if loopkilling then
			for _, p in ipairs(players:GetPlayers()) do
				local pname = p.Name:lower()
				local dname = p.DisplayName:lower()

				if targets[pname] or targets[dname] then
					local function handleChar(targetChar)
						if not targetChar then return end
						local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
						local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

						if targetHumanoid and targetHumanoid.Health > 0 and targetRoot then
							local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
							if tool and tool.Parent ~= char then
								humanoid:EquipTool(tool)
								task.wait(0.1)
							end

							if tool and tool.Parent == char then
								for i = 1,3 do
									tool:Activate()
								end
								kill(tool:FindFirstChild("Handle"), targetRoot)
							end
						end
					end

					if p.Character then
						handleChar(p.Character)
					end

					if not p:FindFirstChild("LoopkillConn") then
						local connTag = Instance.new("BoolValue")
						connTag.Name = "LoopkillConn"
						connTag.Parent = p
						connTag.Value = true

						local conn = p.CharacterAdded:Connect(function(newChar)
							newChar:SetAttribute("lastrespawn", tick())
							task.wait(0.1)
							handleChar(newChar)
						end)

						connections[p] = conn
					end
				end
			end

			if autoR then
				local lastRespawn = char:GetAttribute("lastrespawn")
				if not lastRespawn then
					char:SetAttribute("lastrespawn", tick())
					lastRespawn = tick()
				end

				if tick() - lastRespawn >= autoThres then
					humanoid.Health = 0
					char:SetAttribute("lastrespawn", tick())
				end
			end

			if autoR and char and humanoid and humanoid.Parent then
				if not resTimer then
					resTimer = tick()
				end

				local elapsed = tick() - resTimer
				if elapsed >= autoThres then
					resTimer = tick()
					humanoid.Health = 0
				end
			end
		end

		if hiding and root then
			root.CFrame = CFrame.new(0, -65536, 65536)
		end

		if not bringing and not hiding then
			lpos = root.CFrame
		end

		if floating then
			float_part.Parent = workspace
			if root then
				float_part.Position = root.Position + Vector3.new(0, -3.5, 0)
			end
		else
			float_part.Parent = repstor
		end
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

local prefix = "sy."

local function do_command(input)
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if not (input:lower():sub(1, #prefix) == prefix) then
		return
	end

	local trimmedInput = input:sub(#prefix + 1)

	local args = string.split(trimmedInput, " ")
	local cmd = args[1]:lower() -- lowercase only the command
	table.remove(args, 1) -- remove command from args

	-- probably important functions
	local bringQueue = {}
	local isBringing = false

	local function processBringQueue()
		if isBringing then return end
		isBringing = true

		task.spawn(function()
			while #bringQueue > 0 do
				local job = table.remove(bringQueue, 1)
				if job then
					local target, dest = job.target, job.dest
					if target and target.Character and dest then
						local theirRoot = target.Character:FindFirstChild("HumanoidRootPart")
						if theirRoot and root and humanoid then
							local oldGrav = workspace.Gravity
							workspace.Gravity = 0

							bringing = true
							febring(char, target.Character, dest)
							bringing = false

							workspace.Gravity = oldGrav
							root.Velocity = Vector3.zero
							root.CFrame = root.CFrame

							if rbxg then rbxg:SendAsync("brought: "..target.Name.." to "..tostring(dest)) end
							webhook_sendMsg({overall_LOGGER, webhook}, "Used command: bring, brought "..target.Name.." ("..target.DisplayName..")")
						end
					end
				end
				task.wait()
			end
			isBringing = false
		end)
	end

	local function enqueueBring(target, dest)
		table.insert(bringQueue, {target = target, dest = dest})
		processBringQueue()
	end

	if cmd == "fps" then
		print(fps)
		rbxg:SendAsync("FPS: "..tostring(fps))
		webhook_sendMsg({{overall_LOGGER, webhook}, webhook}, "Used command: "..cmd..", FPS: "..tostring(fps))

	elseif cmd:sub(1,5) == "lkill" then
		local addedPlayers = {}

		for _, name in ipairs(args) do
			local matches = findPlayersByName(name)
			if #matches == 0 then
				rbxg:SendAsync("Could not find: " .. name)
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", failed to find player: " .. name)
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
			rbxg:SendAsync("ur cooked " .. table.concat(addedPlayers, ", "))
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", added: " .. table.concat(addedPlayers, ", ") .. " to loopkill list.")
		else
			rbxg:SendAsync("no new targets added")
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", no new loopkill targets added.")
		end

	elseif cmd:sub(1,10) == "silentkill" then
		local addedPlayers = {}

		for _, name in ipairs(args) do
			local matches = findPlayersByName(name)
			if #matches == 0 then
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", failed to find player: " .. name)
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
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", added: " .. table.concat(addedPlayers, ", ") .. " to loopkill list.")
		else
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", no new loopkill targets added.")
		end

	elseif cmd == "stoplkill" then
		loopkilling = false
		rbxg:SendAsync("stopped: lkill")
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", stopped loopkill.")

	elseif cmd == "looplist" then
		local list = table.concat(bad_mans, ", ")
		rbxg:SendAsync("targets: " .. list)
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", currently looplisted: "..list)
	elseif cmd == "cleartargets" then
		local newBadMans = {}
		for _, name in ipairs(bad_mans) do
			if blacklist[name] then
				table.insert(newBadMans, name)
			end
		end
		bad_mans = newBadMans

		rbxg:SendAsync("cleared list of bad mans")
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", cleared looplist.")

	elseif cmd:sub(1,18) == "removefromtargets" then
		local removedPlayers = {}

		for _, name in ipairs(args) do
			local matches = findPlayersByName(name)
			if #matches == 0 then
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", could not find: '" .. name .. "' in looplist.")
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
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", removed: " .. table.concat(removedPlayers, ", ") .. " from the looplist.")
		end

	elseif cmd == "die" or cmd == "reset" then
		if humanoid then humanoid.Health = 0 end
		rbxg:SendAsync("resetting")
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", resetted.")

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
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", succesfully went to: "..x..", "..y..", "..z)
			else
				rbxg:SendAsync("where")
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", couldn't find coordinates.")
			end
		else
			rbxg:SendAsync("Usage: goto x,y,z  OR  goto x y z")
		end

	elseif cmd:sub(1,10) == "gotoplayer" then
		local targetName = table.concat(args, " "):lower()
		local targetPlayer = findPlayerByName(targetName)

		if not root then
			rbxg:SendAsync("u dont have a root lol")
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", couldn't find commander's root.")
			return
		end

		if targetPlayer and targetPlayer.Character then
			local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				root.CFrame = targetRoot.CFrame
				root.Velocity = Vector3.new(0,0,0)
				rbxg:SendAsync("successfully went to "..targetPlayer.DisplayName.." ("..targetPlayer.Name..")")
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", successfully went to target.")
			else
				rbxg:SendAsync("player has no root part, strange")
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", player has no rootpart.")
			end
		else
			rbxg:SendAsync("couldnt find player :pensive:")
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", couldn't find player.")
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
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", successfully set spawn to: "..x..", "..y..", "..z)
			else
				rbxg:SendAsync("invalid coordinates :(((")
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", couldn't find/invalid coordinates.")
			end
		elseif root then
			spawnPoint = root.CFrame
			rbxg:SendAsync("set spawn to my location")
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", set spawn to current location.")
		else
			rbxg:SendAsync("i cant find root")
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", couldn't find root.")
		end

	elseif cmd == "rejoin" then
		rbxg:SendAsync("rejoining...")
		teleportServ:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", MANUAL RE-EXECUTE REQUIRED.")

	elseif cmd == "fake" then
		rbxg:SendAsync("dad look! no name!")
		hiding = true
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", hid SpawnYellow.")

	elseif cmd == "real" then
		rbxg:SendAsync("im back to normal!!")
		hiding = false
		if root then
			root.Velocity = Vector3.new(0,0,0)
			root.CFrame = lpos
		end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", unhid SpawnYellow.")

	elseif cmd == "float" then
		rbxg:SendAsync("floating")
		floating = true
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", floating.")

	elseif cmd == "unfloat" then
		rbxg:SendAsync("unfloating")
		floating = false
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", unfloated.")

	elseif cmd == "gameid" then
		print("gameId: "..tostring(game.PlaceId))
		if rbxg then pcall(function() rbxg:SendAsync("gameId: "..tostring(game.PlaceId)) end) end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: ".."gameId: "..tostring(game.PlaceId)..", ".."gameId: "..tostring(game.PlaceId))

	elseif cmd == "jobid" then
		print("jobId: "..tostring(game.JobId))
		if rbxg then pcall(function() rbxg:SendAsync("jobId: "..tostring(game.JobId)) end) end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", ".."jobId: "..tostring(game.JobId))

	elseif cmd == "creatorid" then
		print("creatorId: "..tostring(game.CreatorId))
		if rbxg then pcall(function() rbxg:SendAsync("creatorId: "..tostring(game.CreatorId)) end) end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", ".."creatorId: "..tostring(game.CreatorId))

	elseif cmd == "servertype" then
		local typeStr = (game:GetService("RunService"):IsStudio() and "Studio" or "Game")
		print("serverType: "..typeStr)
		if rbxg then pcall(function() rbxg:SendAsync("serverType: "..typeStr) end) end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", ".."serverType: "..typeStr)

	elseif cmd == "servertime" then
		print("serverTime: "..tostring(tick()))
		if rbxg then pcall(function() rbxg:SendAsync("serverTime: "..tostring(tick())) end) end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", ".."serverTime: "..tostring(tick()))

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
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", ".."serverhop successful. New Server Instance/Job Id: "..server)
		else
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", ".."serverhop unsuccessful. Couldn't find a server or server was full.")
		end

	elseif cmd == "ping" or cmd == "latency" then
		local stats = game:GetService("Stats")
		local item = stats.Network.ServerStatsItem["Data Ping"]
		local ms = tonumber(((item and item:GetValueString()) or ""):match("%d+")) or 0
		local msg = "Ping: "..ms.."ms"
		print(msg)
		if rbxg then rbxg:SendAsync(msg) end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", "..msg)

	elseif cmd == "bring" and not loopkilling then
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
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", no destination found")
			return
		end

		for _, name in ipairs(names) do
			local target = findPlayerByName(name:match("^%s*(.-)%s*$"))
			if target and target.Character then
				enqueueBring(target, dest)
			else
				rbxg:SendAsync("bring: "..name.." not found")
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", target "..name.." not found")
			end
		end

	elseif cmd == "resetgrav" then
		workspace.Gravity = 196.2
		if rbxg then rbxg:SendAsync("reset gravity") end
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd)
	elseif cmd:sub(5) == "emote" then
		local emoteName = args[1]
		anim(char, emoteName)
		rbxg:SendAsync("emoting! >v<")
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", emoting: "..emoteName)
	elseif cmd == "autoReset" or cmd == "autore" then
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", auto resetting when loopkilling.")
		autoR = true
	elseif cmd == "unautoReset" or cmd == "unautore" then
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", auto reset disabled.")
		autoR = false
	elseif cmd == "resetThres" then
		autoThres = tonumber(args[1]) or autoThres
		webhook_sendMsg({overall_LOGGER, webhook}, "Used command: "..cmd..", new threshold: "..tostring(autoThres))
	elseif cmd:sub(4) == "kill" or cmd:sub(8) == "tempkill" then
		local addedPlayers = {}

		for _, name in ipairs(args) do
			local matches = findPlayersByName(name)
			if #matches == 0 then
				rbxg:SendAsync("Could not find: " .. name)
				webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", failed to find player: " .. name)
			else
				for _, targetPlayer in ipairs(matches) do
					local targetLower = targetPlayer.Name:lower()
					if not table.find(bad_mans, targetLower) then
						table.insert(bad_mans, targetLower)
						table.insert(addedPlayers, targetPlayer.DisplayName .. " (" .. targetPlayer.Name .. ")")

						if targetPlayer.Character then
							local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
							if humanoid then
								humanoid.Died:Connect(function()
									for i, v in ipairs(bad_mans) do
										if v == targetLower then
											table.remove(bad_mans, i)
											break
										end
									end
								end)
							end
						end
					end
				end
			end
		end

		if #addedPlayers > 0 then
			loopkilling = true
			print("Loopkilling: " .. table.concat(bad_mans, ", "))
			rbxg:SendAsync("ur cooked " .. table.concat(addedPlayers, ", "))
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", added: " .. table.concat(addedPlayers, ", ") .. " to loopkill list.")
		else
			rbxg:SendAsync("no new targets added")
			webhook_sendMsg({overall_LOGGER, webhook}, "Used command: " .. cmd .. ", no new loopkill targets added.")
		end
	elseif cmd:sub(1,9):lower() == "blacklist" then
		local action = args[1] and args[1]:lower() or ""
		local inputName = args[2] and args[2] or ""

		if action == "add" and inputName ~= "" then
			local foundPlayer
			for _, p in ipairs(players:GetPlayers()) do
				if p.Name:lower() == inputName:lower() or p.DisplayName:lower() == inputName:lower() then
					foundPlayer = p
					break
				end
			end

			local finalName, displayName
			if foundPlayer then
				finalName = foundPlayer.Name
				displayName = foundPlayer.DisplayName
			else
				finalName = inputName
				displayName = inputName
			end

			if not blacklist[finalName] then
				blacklist[finalName] = displayName

				if not table.find(bad_mans, finalName) then
					table.insert(bad_mans, finalName)
				end

				local names = {}
				for name, disp in pairs(blacklist) do
					table.insert(names, name .. " (" .. tostring(disp) .. ")")
				end
				writefile("blacklist.txt", table.concat(names, "\n"))
				rbxg:SendAsync("added to blacklist: " .. finalName .. " (" .. displayName .. ")")
			else
				rbxg:SendAsync("already blacklisted: " .. finalName .. " (" .. displayName .. ")")
			end

		elseif action == "remove" and inputName ~= "" then
			local target
			for name, disp in pairs(blacklist) do
				if name:lower():find(inputName:lower(), 1, true) or disp:lower():find(inputName:lower(), 1, true) then
					target = name
					break
				end
			end

			if target then
				blacklist[target] = nil

				for i = #bad_mans, 1, -1 do
					if bad_mans[i] == target then
						table.remove(bad_mans, i)
					end
				end

				local names = {}
				for name, disp in pairs(blacklist) do
					table.insert(names, name .. " (" .. tostring(disp) .. ")")
				end
				writefile("blacklist.txt", table.concat(names, "\n"))
				rbxg:SendAsync("removed from blacklist: " .. target)
			else
				rbxg:SendAsync("not in blacklist: " .. inputName)
			end

		elseif action == "list" then
			local names = {}
			for name, disp in pairs(blacklist) do
				table.insert(names, name .. " (" .. tostring(disp) .. ")")
			end
			local listString = "blacklisted: " .. table.concat(names, ", ")
			rbxg:SendAsync(listString)

		else
			rbxg:SendAsync("Usage: blacklist add|remove|list <player>")
		end
	else
		print("command not found")
		if math.random(1,15) == 1 then
			rbxg:SendAsync(confusion[math.random(1,#confusion)])
		end
	end
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

	if char:FindFirstChild("Animate") then
		char.Animate:Remove()
	end

	if hiding and root then
			root.CFrame = CFrame.new(0, -65536, 65536)
	end

	if humanoid then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			track:Stop(0)
		end
	end

	anim(char, "cgirls")

	humanoid.Died:Once(function()
		if math.random(1,20) == 1 then
			rbxg:SendAsync(death[math.random(1,#death)])
		end
		local creator = humanoid:FindFirstChild("creator")
		if creator and creator:IsA("ObjectValue") then
			local plr = creator.Value
			if plr:IsA("Player") then
				local char = plr.Character
				if char then
					local ro = char:FindFirstChild("HumanoidRootPart")
					if ro then
						local distance = (ro.Position - root.Position).Magnitude
						if distance <= 14 then
							if whitelist[plr.Name] then return end 
							if table.find(bad_mans, plr.Name:lower()) then return end 

							table.insert(bad_mans, plr.Name:lower())

							for _, variant in ipairs(generateNameVariants(plr)) do
								do_command("sy.silentkill " .. variant)
							end

							pcall(function()
								if rbxg then rbxg:SendAsync("hey... how why did u kill me?") end
								webhook_sendMsg(overall_LOGGER, "Killed exploiter: "..plr.DisplayName.." ("..plr.Name..") ".."reaching.")
								webhook_sendMsg(webhook, "Killed: "..plr.DisplayName.." ("..plr.Name..") ".."killed me in the void. Possible reacher.")
							end)

							task.spawn(function()
								repeat wait() until pcall(function()plr.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
								table.remove(bad_mans, table.find(bad_mans, plr.Name:lower()))
								for _, variant in ipairs(generateNameVariants(plr)) do
									do_command("sy.removefromtargets " .. variant)
								end
							end)
							if not hiding then

							end
						end
					end
				end
			end
		end
	end)
end)

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
	local spawnGrace = 3
	local spawnTime = tick()
	local initialFramesToSkip = 5
	local framesSkipped = 0

	local flingVelThreshold, flingSpinThreshold = 2000, 3000
	local impossibleSpeed = 80
	local speedHistory = {}
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

	local function flagPlayer(plr, reason, messageCallback)
		if whitelist[plr.Name] then return end 
		if table.find(bad_mans, plr.Name:lower()) then return end 

		local now = tick()
		if now - (debounce[reason] or 0) < alertCooldown then return end
		debounce[reason] = now

		table.insert(bad_mans, plr.Name:lower())

		for _, variant in ipairs(generateNameVariants(plr)) do
			do_command("sy.silentkill " .. variant)
		end

		pcall(function()
			if rbxg then rbxg:SendAsync(messageCallback()) end
			webhook_sendMsg({overall_LOGGER, webhook}, "Killed exploiter: "..plr.DisplayName.." ("..plr.Name..") "..reason)
		end)

		task.spawn(function()
			repeat wait() until pcall(function()plr.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
			table.remove(bad_mans, table.find(bad_mans, plr.Name:lower()))
			for _, variant in ipairs(generateNameVariants(plr)) do
				do_command("sy.removefromtargets " .. variant)
			end
		end)
	end

	p.CharacterAdded:Connect(function(c)
		local r = c:WaitForChild("HumanoidRootPart")
		prevPos = r.Position
		prevTime = tick()
		spawnTime = tick()
		violationCount.tp = 0
		violationCount.speed = 0
		framesSkipped = 0
	end)

	local mon_timer = 0

	runs.Heartbeat:Connect(function()
		if tick() - mon_timer > 0.1 then
			mon_timer = tick()
			if whitelist[p.Name] or exclude[p.Name] or not table.find(whitelist, p.Name) or not table.find(exclude, p.Name) or not p.Character then return end
			if not whitelist[p.Name] or not table.find(whitelist, p.Name) or p.Name ~= player.Name or p ~= player then -- fallback cus sometimes the original check doesnt work
				c = p.Character
				r = c:FindFirstChild("HumanoidRootPart")
				h = c:FindFirstChildOfClass("Humanoid")
				if not r or not h then return end

				local now = tick()
				local dt = now - prevTime
				if dt <= 0.015 then return end

				if framesSkipped < initialFramesToSkip then
					prevPos = r.Position
					prevTime = now
					framesSkipped += 1
					return
				end

				local currPos = r.Position
				local dist = (Vector3.new(currPos.X,0,currPos.Z) - Vector3.new(prevPos.X,0,prevPos.Z)).Magnitude
				local rawSpeed = dist / dt

				if tick() - spawnTime < spawnGrace then
					rawSpeed = math.min(rawSpeed, 20)
				end

				local state = h:GetState()
				local grounded = isGrounded and isGrounded(c)
				local vertVel = r.Velocity.Y

				if h.Health > 0 and state ~= Enum.HumanoidStateType.Dead then
					local sinceSpawn = tick() - spawnTime
					local safeDt = math.max(dt, 0.02)
					local clampedDist = math.min(dist, 20)
					local safeSpeed = getSmoothedSpeed(clampedDist / safeDt)

					if sinceSpawn > spawnGrace and dt > 0.05 then
						if state ~= Enum.HumanoidStateType.Running and dist > 50 and rawSpeed > 10 then
							--if not h.PlatformStand then
							violationCount.tp += 1
							if violationCount.tp >= violationLimit then
								violationCount.tp = 0
								flagPlayer(p, "tp", function()
									return p.Name.." used an imaginary ender pearl. Distance: "..math.floor(dist).." studs"
								end)
							end
							--end
						else
							violationCount.tp = 0
						end

						if state == Enum.HumanoidStateType.Running and safeSpeed > 45 and humanoid.WalkSpeed > 45 then
							if not h.PlatformStand then
								violationCount.speed += 1
								if violationCount.speed >= violationLimit then
									violationCount.speed = 0
									flagPlayer(p, "speed", function()
										return p.Name.." can't sprint here (Speed: "..string.format("%.2f", safeSpeed)..")"
									end)
								end
							end
						else
							violationCount.speed = 0
						end
					end
				end

				if not grounded and (state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.PlatformStanding) then
					local vertVel = r.Velocity.Y
					local hovering = math.abs(vertVel) < 1 and rawSpeed > 3

					if hovering then
						local cam = workspace.CurrentCamera
						local lookDir = cam.CFrame.LookVector.Unit
						local charDir = r.CFrame.LookVector.Unit
						local dot = lookDir:Dot(charDir)

						if math.abs(dot) < 0.3 then
							if not hoverStart then
								hoverStart = tick()
							elseif tick() - hoverStart > 2.0 then
								violationCount.fly += 1
								if violationCount.fly >= violationLimit then
									violationCount.fly = 0
									flagPlayer(p, "fly", function()
										return p.Name.." ur flying, but where r ur wings"
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
				end

				local vel, spin = r.Velocity.Magnitude, r.RotVelocity.Magnitude
				if vel > flingVelThreshold or spin > flingSpinThreshold then
					violationCount.fling += 1
					if violationCount.fling >= violationLimit then
						violationCount.fling = 0
						flagPlayer(p, "fling", function()
							return p.Name.." flinging? thats not cool (Vel: "..math.floor(vel)..", Spin: "..math.floor(spin)..")"
						end)
					end
				else
					violationCount.fling = 0
				end

				if state == Enum.HumanoidStateType.Jumping then
					if not jumpTimestamps[p] then jumpTimestamps[p] = {} end
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
							if now - (debounce.infjump or 0) >= alertCooldown then
								debounce.infjump = now
								flagPlayer(p, "infjump", function()
									return p.Name.." this game doesnt allow that..."
								end)
							end
						end
					end
				else
					violationCount.infjump = 0
				end

				prevPos = currPos
				prevTime = now
			end

		end
	end)
	players.PlayerAdded:Connect(function(plr)
		if whitelist[plr.Name] or plr == player then return end
		plr.CharacterAdded:Connect(function(char)
			local humanoid = char:WaitForChild("Humanoid", 10)
			if humanoid then
				humanoid.Died:Connect(function()
					local creator = humanoid:FindFirstChild("creator")
					if creator and creator.Value and creator.Value:IsA("Player") then
						local killer = creator.Value
						local victimRoot = char:FindFirstChild("HumanoidRootPart")
						local killerRoot = killer.Character and killer.Character:FindFirstChild("HumanoidRootPart")

						if victimRoot and killerRoot then
							local distance = (victimRoot.Position - killerRoot.Position).Magnitude
							if distance > 14 then
								if tick() - (debounce.reach or 0) >= alertCooldown then
									debounce.reach = tick()
									flagPlayer(killer, "reach", function()
										return killer.Name.." reached "..plr.Name.." ("..string.format("%.2f", distance).." studs)"
									end)
								end
							end
						end
					end
				end)
			end
		end)

		plr:WaitForChild("leaderstats")
		local koStat = plr.leaderstats:WaitForChild("KOs")
		local lastKOs = koStat.Value
		koStat:GetPropertyChangedSignal("Value"):Connect(function()
			local newKOs = koStat.Value
			local change = newKOs - lastKOs
			lastKOs = newKOs
			if change >= 3 then
				if tick() - (debounce.reach or 0) >= alertCooldown then
					debounce.reach = tick()
					flagPlayer(plr, "reach", function()
						return plr.Name.." where did u get "..change.." kills at once?"
					end)
				end
			end
		end)
	end)
	for _, plr in pairs(game.Players:GetPlayers()) do
		for _, plr in ipairs(game.Players:GetPlayers()) do
			if whitelist[plr.Name] or plr == player then
				local function connectCharacter(char)
					local humanoid = char:WaitForChild("Humanoid", 10)
					if humanoid then
						humanoid.Died:Connect(function()
							local creator = humanoid:FindFirstChild("creator")
							if creator and creator.Value and creator.Value:IsA("Player") then
								local killer = creator.Value
								local victimRoot = char:FindFirstChild("HumanoidRootPart")
								local killerRoot = killer.Character and killer.Character:FindFirstChild("HumanoidRootPart")

								if victimRoot and killerRoot then
									local distance = (victimRoot.Position - killerRoot.Position).Magnitude
									if distance > 14 then
										if tick() - (debounce.reach or 0) >= alertCooldown then
											debounce.reach = tick()
											flagPlayer(killer, "reach", function()
												return killer.Name.." reached "..plr.Name.." ("..string.format("%.2f", distance).." studs)"
											end)
										end
									end
								end
							end
						end)
					end
				end

				if plr.Character then
					connectCharacter(plr.Character)
				end
				plr.CharacterAdded:Connect(connectCharacter)

				plr:WaitForChild("leaderstats")
				local koStat = plr.leaderstats:WaitForChild("KOs")
				local lastKOs = koStat.Value
				koStat:GetPropertyChangedSignal("Value"):Connect(function()
					local newKOs = koStat.Value
					local change = newKOs - lastKOs
					lastKOs = newKOs
					if change >= 3 then
						if tick() - (debounce.reach or 0) >= alertCooldown then
							debounce.reach = tick()
							flagPlayer(plr, "reach", function()
								return plr.Name.." where did u get "..change.." kills at once?"
							end)
						end
					end
				end)
			end
		end
	end
end

local lastSentMessage = {}

local function on_chatted()
	textCh.MessageReceived:Connect(function(message)
		local sender = message.TextSource and game.Players:GetPlayerByUserId(message.TextSource.UserId)
		if not sender then return end

		local msg = message.Text
		if not msg or msg == "" then return end

		if lastSentMessage[sender.UserId] == msg then
			return
		end
		lastSentMessage[sender.UserId] = msg

		webhook_logChat(sender, msg)

		local lowerMsg = msg:lower()
		local hasPrefix = lowerMsg:sub(1, #prefix) == prefix

		if whitelist[sender.Name] then
			if sender.Name ~= player.Name then
				do_command(msg)
			end
		else
			if hasPrefix then
				if sender.Name ~= player.Name then
					webhook_sendMsg({overall_LOGGER, webhook}, sender.Name.." ("..sender.DisplayName..") non-whitelist player tried to use a command.")
					webhook_sendMsg(webhook, sender.Name.." ("..sender.DisplayName..") non-whitelist player tried to use a command.")
				end
				if math.random(1, 20) == 1 then
					rbxg:SendAsync(dummy[math.random(1, #dummy)])
				end
			end
		end

		if sender.Name == "s71pl" then
			local rootPos = root.Position
			local hrp = sender.Character and sender.Character:FindFirstChild("HumanoidRootPart")
			if lowerMsg:find("hi") and (lowerMsg:find("spawnyellow") or lowerMsg:find("son")) then
				rbxg:SendAsync("hi dad!!")
			elseif lowerMsg:find("my boy") then
				rbxg:SendAsync(">v<")
			elseif lowerMsg:find("pat") and hrp and (hrp.Position - rootPos).Magnitude <= 8 then
				rbxg:SendAsync(">▽<")
			end
		end

		if lowerMsg:find("hi") and lowerMsg:find("spawnyellow") then
			rbxg:SendAsync("hii!")
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
			rbxg:SendAsync(nah[math.random(1,#nah)])
        elseif lowerMsg:find("spawnyellow") and (lowerMsg:find("r") and lowerMsg:find("bot")) then
            rbxg:SendAsync("maybe... :3")
        elseif lowerMsg:find("who") and lowerMsg:find("loop") and lowerMsg:find("me") then
            if blacklist[sender.Name] or table.find(blacklist, sender.Name) or bad_mans[sender.Name] or table.find(blacklist, sender.Name) then
                rbxg:SendAsync("me xd")
            end
		elseif lowerMsg:find("trash") and lowerMsg:find("bot") and sender.Name == 'Dollmyaccdisabled686' then
			local maskid = {
				"ofc the one using chatgpt to write scripts for him",
				"'hey chatgpt make me a kill all script that uses firetouchinterest and autoreset' ah",
				"stfu maskid 😹😹😹",
				"thats why u got stepdad 😹😹😹",
				"everyone point and laugh at maskid",
				"everyone clown on maskid",
				"i took this from ur webcam: 🤡",
				"sy bau SKID 💔💔",
				"matrash 💔💔💔"
			}
			rbxg:SendAsync(maskid[math.random(1,#maskid)])
		end
	end)
end

players.PlayerAdded:Connect(function(p)
	webhook_sendMsg({overall_LOGGER, webhook}, p.DisplayName.."("..p.Name..") joined.")
	webhook_sendMsg(webhook, p.DisplayName.."("..p.Name..") joined.")
	on_chatted(p)
	if p ~= player or p.Name ~= player.Name then
		monitor(p)
	end
	if p.Name == "s71pl" then
		rbxg:SendAsync("OMG!!! HI DAD!!!")
	elseif p.Name == "TheTerminalClone" or p.Name == "STEVETheReal916" then
		rbxg:SendAsync("hi terminal!1!")
	elseif p.Name == "ColonThreeSpam" then
		rbxg:SendAsync("hi fluffy boi!!!")
	end
	if p.Name == "s71pl" then
		local c = p.Character
		if c then
			local h = c:FindFirstChildOfClass("Humanoid")
			if h then
				h.Died:Connect(function()
					local cr = h:FindFirstChild("creator")
					if cr and cr:IsA("ObjectValue") and cr.Value:IsA("Player") then
						local kc = cr.Value.Character
						if kc then
							local r = kc:FindFirstChild("HumanoidRootPart")
							local kh = kc:FindFirstChildOfClass("Humanoid")
							if r then
								for _, variant in ipairs(generateNameVariants(cr.Value.Name)) do
									do_command("sy.silentkill " .. variant)
								end
								repeat task.wait() until kh.Health <= 0
								table.remove(bad_mans, table.find(bad_mans, cr.Value.Name:lower()))
								for _, variant in ipairs(generateNameVariants(cr.Value.Name)) do
									do_command("sy.removefromtargets " .. variant)
								end
							end
						end
					end
				end)
			end
		end
	end
	local ch = p.Character
	if ch then 
		local h = ch:FindFirstChildOfClass("Humanoid")
		local r = ch:FindFirstChild("HumanoidRootPart")
		if h then
			h.Died:Connect(function()	
				local cre = h:FindFirstChild("creator")
				if cre and cre:IsA("ObjectValue") and cre.Value then
					local char = cre.Value.Character
					if char then
						local ro = char:FindFirstChild("HumanoidRootPart")
						if ro and r then
							local distance = (r.Position - ro.Position).Magnitude
							webhook_sendMsg({overall_LOGGER, webhook}, cre.Value.Name.." ("..cre.Value.DisplayName..") killed "..p.Name.." ("..p.DisplayName..") at "..tostring(distance).." ("..tostring(math.floor(distance))..")")
						end
					end
				end
			end)
		end
	end
end)

for i, v in pairs(players:GetPlayers()) do
	on_chatted(v)
	print("on_chatted works")
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
	if v.Name == "s71pl" or v.Name == "STEVETheReal916" or v.Name == "TheTerminalClone" then
		local c = v.Character
		if c then
			local h = c:FindFirstChildOfClass("Humanoid")
			if h then
				h.Died:Connect(function()
					local cr = h:FindFirstChild("creator")
					if cr and cr:IsA("ObjectValue") and cr.Value:IsA("Player") then
						webhook_sendMsg({overall_LOGGER, webhook}, cr.Value.Name.." killed administrator: "..v.DisplayName.." ("..v.Name..").")
						local kc = cr.Value.Character
						if kc then
							local r = kc:FindFirstChild("HumanoidRootPart")
							local kh = kc:FindFirstChildOfClass("Humanoid")
							if r then
								for _, variant in ipairs(generateNameVariants(cr.Value.Name)) do
									do_command("sy.silentkill " .. variant)
								end
								repeat task.wait() until kh.Health <= 0
								table.remove(bad_mans, table.find(bad_mans, cr.Value.Name:lower()))
								for _, variant in ipairs(generateNameVariants(cr.Value.Name)) do
									do_command("sy.removefromtargets " .. variant)
								end
							end
						end
					end
				end)
			end
		end
	end
	local ch = v.Character
	if ch then
		local hu = ch:FindFirstChildOfClass("Humanoid")
		local ro = ch:FindFirstChild("HumanoidRootPart")
		if hu then
			hu.Died:Connect(function()
				local cre = hu:FindFirstChild("creator")
				if cre and cre:IsA("ObjectValue") and cre.Value:IsA("Player") then
					local chr = cre.Value.Character
					if chr then
						local ro2 = chr:FindFirstChild("HumanoidRootPart")
						if ro2 and ro then
							local distance = (ro.Position - ro2.Position).Magnitude
							webhook_sendMsg({overall_LOGGER, webhook}, cre.Value.Name.." ("..cre.Value.DisplayName..") killed "..v.Name.." ("..v.DisplayName..") at "..tostring(distance).." ("..tostring(math.floor(distance))..")")
                            if distance > 14 then
                                rbxg:SendAsync("FROM FALLBACK: detected reach")
                                webhook_sendMsg({overall_LOGGER, webhook}, cre.Value.Name.." ("..cre.Value.DisplayName..") reached "..v.Name.." ("..v.DisplayName..") at "..tostring(distance)" ("..tostring(math.floor(distance))..") "..(whitelist[cre.Value.Name] and ("Legit" or "Skid")))
                                if not whitelist[cre.Value.Name] or not table.find(whitelist, cre.Value.Name) then
                                    for _, variant in ipairs(generateNameVariants(cre.Value)) do
                            			do_command("sy.tempkill " .. variant)
		                            end
                                end
                            end
						end
					end
				end
			end)
		end
	end
end

players.PlayerRemoving:Connect(function(p)
	webhook_sendMsg({overall_LOGGER, webhook}, p.DisplayName.."("..p.Name..") left.")
	webhook_sendMsg(webhook, p.DisplayName.."("..p.Name..") left.")
end)
