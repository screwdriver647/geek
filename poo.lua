local players = game:GetService("Players")
local local_player = players.LocalPlayer
local local_player_get_rank_in_group = local_player.GetRankInGroup
local http_service = game:GetService("HttpService")
local starter_gui = game:GetService("StarterGui")

starter_gui:SetCore("SendNotification", {
    Title = "initializing",
    Text = "green bell pepper premium is preparing",
    Icon = "rbxassetid://10248739816",
    Duration = 5
})

local run_service = game:GetService("RunService")
local starter_player = game:GetService("StarterPlayer")
local user_input_service = game:GetService("UserInputService")
local teams = game:GetService("Teams")
local replicated_storage = game:GetService("ReplicatedStorage")

-- gui library --
starter_gui:SetCore("SendNotification", {
    Title = "please wait",
    Text = "green bell pepper premium is loading its gui",
    Icon = "rbxassetid://10248739816",
    Duration = 7
})

local gui_library_url = "https://raw.githubusercontent.com/Pepsied-5229/Pepsi-UI-Library/refs/heads/main/Pepsi-UI-Library.lua"

function get_gui_library_source()
    return game:HttpGet(gui_library_url)
end

function get_gui_library()
    return loadstring(get_gui_library_source())()
end

function attempt_getting_gui_library_until_done()
    local success

    while not success do
        success, gui_library = pcall(get_gui_library)
    end

    return gui_library
end

local gui_library = attempt_getting_gui_library_until_done()

-- spoof table --
local spoof_table = {
    humanoids = {},
    base_parts = {}
}

-- configuration table --
local configuration = {
    hitbox_extender = {
        extended_hitbox_size = 8,
        enabled = false
    },
    teleport_to_item = {
        name = "Revolver",
        teleport_back_once_obtained = true
    },
    teleport_to_player = {
        user_name = "greeksalad7",
        display_name = "greek_salad"
    },
    movement = {
        walk_speed = starter_player.CharacterWalkSpeed,
        run_speed = 24,
        crawl_speed = 8,
        jump_height = starter_player.CharacterJumpHeight,
        no_clip_enabled = false,
        float_enabled = false
    },
    general_esp = {
        name_display_distance = 64,
        health_display_distance = 64,
        enabled = false
    },
    chams = {
        enabled = false
    },
    defense = {
        anti_tase_enabled = false,
        anti_void_enabled = true
    },
    auto_respawn = {
        teleport_back_to_death_location = false,
        enabled = false
    },
    silent_aimbot = {
        field_of_view_size = 120,
        enabled = false
    },
    gun_modifiers = {
        spread_multiplier = 1,
        shotgun_reload_speed_multiplier = 1
    },
    attack_player = {
        player_string = ""
    }
}

-- silent aim drawings --
local cursor_drawing = Drawing.new("Line")
cursor_drawing.Thickness = 2
cursor_drawing.From = Vector2.new(0, 0)
cursor_drawing.To = Vector2.new(0, 0)
cursor_drawing.Transparency = 1
cursor_drawing.Color = Color3.new(1, 1, 1)
cursor_drawing.Visible = true

local field_of_view_circle = Drawing.new("Circle")
field_of_view_circle.Radius = configuration.silent_aimbot.field_of_view_size
field_of_view_circle.NumSides = 48
field_of_view_circle.Thickness = 2
field_of_view_circle.Filled = false
field_of_view_circle.Transparency = 1
field_of_view_circle.Color = Color3.new(1, 1, 1)
field_of_view_circle.Visible = false

-- metamethod hooking variables --
local raw_instance_index = nil
local raw_instance_newindex = nil
local raw_instance_namecall = nil

local function instance_index_hook(instance, key)
    if checkcaller() then
        return raw_instance_index(instance, key)
    end

    -- walk speed --
    if key == "WalkSpeed" and raw_instance_index(instance, "ClassName") == "Humanoid" and spoof_table["humanoids"][instance] and spoof_table["humanoids"][instance]["walk_speed"] then
        return spoof_table["humanoids"][instance]["walk_speed"]
    end

    if key == "WalkSpeed" and raw_instance_index(instance, "ClassName") == "Humanoid" then
        return starter_player.CharacterWalkSpeed
    end

    -- jump height --
    if key == "JumpHeight" and raw_instance_index(instance, "ClassName") == "Humanoid" and spoof_table["humanoids"][instance] and spoof_table["humanoids"][instance]["jump_height"] then
        return spoof_table["humanoids"][instance]["jump_height"]
    end

    if key == "JumpHeight" and raw_instance_index(instance, "ClassName") == "Humanoid" then
        return starter_player.CharacterJumpHeight
    end

    -- can collide --
    if key == "CanCollide" and instance:IsA("BasePart") and spoof_table["base_parts"][instance] and spoof_table["base_parts"][instance]["can_collide"] then
        return spoof_table["base_parts"][instance]["can_collide"]
    end

    if key == "CanCollide" and instance:IsA("BasePart") then
        return true
    end

    -- velocity --
    if key == "AssemblyLinearVelocity" or key == "Velocity" then
        return raw_instance_index(instance, key) * math.huge
    end

    return raw_instance_index(instance, key)
end

local function instance_newindex_hook(instance, key, value)
    if checkcaller() then
        return raw_instance_newindex(instance, key, value)
    end

    -- walk speed --
    if key == "WalkSpeed" and instance.ClassName == "Humanoid" then
        if not spoof_table["humanoids"][instance] then
            spoof_table["humanoids"][instance] = {}
        end

        raw_instance_newindex(instance, key, value)
        spoof_table["humanoids"][instance]["walk_speed"] = raw_instance_index(instance, key)

        if not spoof_table["humanoids"][instance]["property_changed_bindable_events"] then
            return
        end

        if not spoof_table["humanoids"][instance]["property_changed_bindable_events"][key] then
            return
        end

        spoof_table["humanoids"][instance]["property_changed_bindable_events"][key]:Fire()

        return
    end

    -- jump height --
    if key == "JumpHeight" and instance.ClassName == "Humanoid" then
        if not spoof_table["humanoids"][instance] then
            spoof_table["humanoids"][instance] = {}
        end

        raw_instance_newindex(instance, key, value)
        spoof_table["humanoids"][instance]["jump_height"] = raw_instance_index(instance, key)

        if not spoof_table["humanoids"][instance]["property_changed_bindable_events"] then
            return
        end

        if not spoof_table["humanoids"][instance]["property_changed_bindable_events"][key] then
            return
        end

        spoof_table["humanoids"][instance]["property_changed_bindable_events"][key]:Fire()

        return
    end

    -- can collide --
    if key == "CanCollide" and instance:IsA("BasePart") then
        if not spoof_table["base_parts"][instance] then
            spoof_table["base_parts"][instance] = {}
        end

        spoof_table["base_parts"][instance]["can_collide"] = value 
        return
    end

    return raw_instance_newindex(instance, key, value)
end

local remote_events = {}

local function instance_namecall_hook(instance, ...)
    local arguments = {...}
    local method = getnamecallmethod()

    if checkcaller() then
        return raw_instance_namecall(instance, ...)
    end

    -- animation track play modifier --
    if method == "Play" and instance.ClassName == "AnimationTrack" and instance.Priority.Value > 1 and instance.Priority.Value < 1000 then
        local character = local_player.Character

        if character == nil then
            return raw_instance_namecall(instance, ...)
        end

        setnamecallmethod("FindFirstChildWhichIsA")

        local tool = raw_instance_namecall(character, "Tool")

        setnamecallmethod("Play")

        if tool == nil then
            return raw_instance_namecall(instance, ...)
        end

        if tool.Name ~= "SPAS" and tool.Name ~= "DB Shotgun" then
            return raw_instance_namecall(instance, ...)
        end

        local shotgun_reload_speed_multiplier = configuration.gun_modifiers.shotgun_reload_speed_multiplier

        raw_instance_namecall(instance, 0.1, 1, shotgun_reload_speed_multiplier)

        return
    end

    -- join team remote event capture --
    if method == "FireServer" and #arguments == 1 and remote_events.join_team_remote_event == nil then
        local team = arguments[1]

        if typeof(team) ~= "Instance" then
            return raw_instance_namecall(instance, ...)
        end

        if team.ClassName ~= "Team" then
            return raw_instance_namecall(instance, ...)
        end

        remote_events.join_team_remote_event = instance

        return raw_instance_namecall(instance, ...)
    end
    
    -- use melee weapon capture --
    if method == "FireServer" and #arguments == 2 and remote_events.use_melee_weapon_remote_event == nil then
        local melee_weapon = arguments[1]

        if typeof(melee_weapon) ~= "Instance" then
            return raw_instance_namecall(instance, ...)
        end

        if melee_weapon.ClassName ~= "Tool" then
            return raw_instance_namecall(instance, ...)
        end
        
        local hit_body_part = arguments[2]
        
        if typeof(hit_body_part) ~= "Instance" then
            return raw_instance_namecall(instance, ...)
        end

        remote_events.use_melee_weapon_remote_event = instance

        return raw_instance_namecall(instance, ...)
    end

    -- get mouse location spoofing --
    if method == "GetMouseLocation" and instance.ClassName == "UserInputService" then
        local mouse_viewport_position = raw_instance_namecall(user_input_service)

        if not configuration.silent_aimbot.enabled then
            return mouse_viewport_position
        end

        local closest_viewport_position = nil

        local current_camera = workspace.CurrentCamera

        if current_camera == nil then
            return mouse_viewport_position
        end

        local current_camera_cframe = current_camera.CFrame

        setnamecallmethod("GetPlayers")
        local targets = raw_instance_namecall(players)

        for index, player in ipairs(targets) do
            if player == local_player then
                continue
            end

            if player.Team == local_player.Team then
                continue
            end

            local character = player.Character

            if character == nil then
                continue
            end

            setnamecallmethod("FindFirstChildWhichIsA")
            local humanoid = raw_instance_namecall(character, "Humanoid")

            if humanoid == nil then
                continue
            end

            if humanoid.Health <= 0 then
                continue
            end

            setnamecallmethod("FindFirstChild")
            local torso = raw_instance_namecall(character, "Torso")

            if torso == nil then
                continue
            end

            local head = raw_instance_namecall(character, "Head")

            if head == nil then
                continue
            end

            local left_arm = raw_instance_namecall(character, "Left Arm")

            if left_arm == nil then
                continue
            end

            local right_arm = raw_instance_namecall(character, "Right Arm")

            if right_arm == nil then
                continue
            end

            local left_leg = raw_instance_namecall(character, "Left Leg")

            if left_leg == nil then
                continue
            end

            local right_leg = raw_instance_namecall(character, "Right Leg")

            if right_leg == nil then
                continue
            end

            local function get_side_cframes_from_part(part)
                local part_cframe = part.CFrame
                local part_size = part.Size

                local part_front_side_cframe = (part_cframe * CFrame.new(Vector3.zAxis * part_size.Z / 2))
                local part_back_side_cframe = (part_cframe * CFrame.new(Vector3.zAxis * -(part_size.Z / 2)))
                local part_right_side_cframe = (part_cframe * CFrame.new(Vector3.xAxis * part_size.X / 2))
                local part_left_side_cframe = (part_cframe * CFrame.new(Vector3.xAxis * -(part_size.X / 2)))
                local part_top_side_cframe = (part_cframe * CFrame.new(Vector3.yAxis * part_size.Y / 2))
                local part_bottom_side_cframe = (part_cframe * CFrame.new(Vector3.yAxis * -(part_size.Y / 2)))

                return {part_front_side_cframe, part_back_side_cframe, part_right_side_cframe, part_left_side_cframe, part_top_side_cframe, part_bottom_side_cframe}
            end

            local side_cframes = {}

            for key, value in pairs(get_side_cframes_from_part(torso)) do
                table.insert(side_cframes, value)
            end

            for key, value in pairs(get_side_cframes_from_part(head)) do
                table.insert(side_cframes, value)
            end

            for key, value in pairs(get_side_cframes_from_part(left_arm)) do
                table.insert(side_cframes, value)
            end

            for key, value in pairs(get_side_cframes_from_part(right_arm)) do
                table.insert(side_cframes, value)
            end

            for key, value in pairs(get_side_cframes_from_part(left_leg)) do
                table.insert(side_cframes, value)
            end

            for key, value in pairs(get_side_cframes_from_part(right_leg)) do
                table.insert(side_cframes, value)
            end

            for _, side_cframe in pairs(side_cframes) do
                setnamecallmethod("WorldToViewportPoint")
                local viewport_position, in_viewport = raw_instance_namecall(current_camera, side_cframe.Position)

                if not in_viewport then
                    continue
                end

                local depth = viewport_position.Z

                viewport_position = Vector2.new(viewport_position.X, viewport_position.Y)

                local raycast_parameters = RaycastParams.new()
                raycast_parameters.IgnoreWater = true
                raycast_parameters.FilterDescendantsInstances = {character, local_player.Character}
                raycast_parameters.FilterType = Enum.RaycastFilterType.Blacklist

                setnamecallmethod("Raycast")
                local raycast_result = raw_instance_namecall(workspace, current_camera_cframe.Position, (side_cframe.Position - current_camera_cframe.Position), raycast_parameters)

                if raycast_result ~= nil then
                    continue
                end

                if closest_viewport_position == nil then
                    closest_viewport_position = viewport_position
                    continue
                end

                if (mouse_viewport_position - viewport_position).Magnitude < (mouse_viewport_position - closest_viewport_position).Magnitude then
                    closest_viewport_position = viewport_position
                    continue
                end
            end
        end

        if closest_viewport_position and (mouse_viewport_position - closest_viewport_position).Magnitude > configuration.silent_aimbot.field_of_view_size then
            closest_viewport_position = mouse_viewport_position
        end

        cursor_drawing.From = mouse_viewport_position
        cursor_drawing.To = closest_viewport_position or mouse_viewport_position

        setnamecallmethod("GetMouseLocation")
        return cursor_drawing.To
    end

    if method == "GetPropertyChangedSignal" and instance.ClassName == "Humanoid" then
        local property_name = arguments[1]

        if not spoof_table["humanoids"][instance] then
            spoof_table["humanoids"][instance] = {}
        end

        if not spoof_table["humanoids"][instance]["property_changed_bindable_events"] then
            spoof_table["humanoids"][instance]["property_changed_bindable_events"] = {}
        end

        local bindable_event = Instance.new("BindableEvent")

        spoof_table["humanoids"][instance]["property_changed_bindable_events"][property_name] = bindable_event

        return bindable_event.Event
    end

    return raw_instance_namecall(instance, ...)
end

-- function hooking --
local raw_math_random

local function math_random_hook(...)
    local spread_multiplier = configuration.gun_modifiers.spread_multiplier
    local arguments = {...}

    if #arguments == 0 then
        return raw_math_random() * spread_multiplier
    end

    return raw_math_random(...)
end

raw_math_random = hookfunction(math.random, math_random_hook)

local character = local_player.Character
local humanoid = character ~= nil and character:FindFirstChildWhichIsA("Humanoid")

if humanoid then
    starter_gui:SetCore("SendNotification", {
        Title = "reset",
        Text = "you were reset so green bell pepper premium loads correctly",
        Icon = "rbxassetid://10248739816",
        Duration = 5
    })

    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    local_player.CharacterAdded:Wait()
end

raw_instance_index = hookmetamethod(game, "__index", newcclosure(instance_index_hook))
raw_instance_newindex = hookmetamethod(game, "__newindex", newcclosure(instance_newindex_hook))
raw_instance_namecall = hookmetamethod(game, "__namecall", newcclosure(instance_namecall_hook))

local item_folder = nil
local teleport_item_name = nil
local teleport_item_back = true
local teleport_player_user_name = nil

-- get item folder --
for _, child in pairs(workspace:GetChildren()) do
    if not child:IsA("Folder") then
        continue
    end

    local revolver = child:FindFirstChild("Revolver")

    if not revolver then
        continue
    end

    item_folder = revolver.Parent
    break
end

local function evaluate_single_player_string(player_string)
    local target_player = nil

    if string.sub(player_string, 1, 1) == "@" then
        player_string = string.sub(player_string, 2, -1)

        if #player_string == 0 then
            return
        end

        for _, player in pairs(players:GetPlayers()) do
            if string.sub(player.Name, 1, #player_string) == player_string then
                target_player = player
                continue
            end
        end

        return target_player
    end

    if string.sub(player_string, 1, 1) == "#" then
        player_string = string.sub(player_string, 2, -1)

        if #player_string == 0 then
            return
        end

        for _, player in pairs(players:GetPlayers()) do
            if player.Name == player_string then
                target_player = player
                continue
            end
        end

        return target_player
    end

    if #player_string == 0 then
        return
    end

    for _, player in pairs(players:GetPlayers()) do
        if string.sub(player.DisplayName, 1, #player_string) == player_string then
            target_player = player
            continue
        end
    end

    return target_player
end

local function hit_player_with_melee_weapon()
    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local root_part = humanoid.RootPart

    if not root_part then
        return
    end

    local target_player = nil
    local player_string = configuration.attack_player.player_string

    local target_player = evaluate_single_player_string(player_string)

    if not target_player then
        return
    end

    local player_character = target_player.Character

    if not player_character then
        return
    end

    local player_humanoid = player_character:FindFirstChildWhichIsA("Humanoid")

    if not player_humanoid then
        return
    end

    local player_root_part = player_humanoid.RootPart

    if not player_root_part then
        return
    end

    local use_melee_weapon_remote_event = remote_events.use_melee_weapon_remote_event

    if not use_melee_weapon_remote_event then
        return
    end

    use_melee_weapon_remote_event.Parent = replicated_storage

    use_melee_weapon_remote_event:FireServer(character:FindFirstChildWhichIsA("Tool"), player_root_part)

    use_melee_weapon_remote_event.Parent = nil
end

local function teleport_to_player()
    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local root_part = humanoid.RootPart

    if not root_part then
        return
    end

    local target_player = nil
    local player_string = configuration.teleport_to_player.player_string

    local target_player = evaluate_single_player_string(player_string)

    if not target_player then
        return
    end

    local player_character = target_player.Character

    if not player_character then
        return
    end

    local player_humanoid = player_character:FindFirstChildWhichIsA("Humanoid")

    if not player_humanoid then
        return
    end

    local player_root_part = player_humanoid.RootPart

    if not player_root_part then
        return
    end

    local previous_root_part_cframe = root_part.CFrame

    root_part.AssemblyLinearVelocity = Vector3.new(1, 1, 1)
    root_part.CFrame = player_root_part.CFrame

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

local function teleport_to_item()
    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local root_part = humanoid.RootPart

    if not root_part then
        return
    end

    local item_name = configuration.teleport_to_item.name
    local item = item_folder:FindFirstChild(item_name)

    if not item then
        return
    end

    local item_cframe = item:GetPivot()
    local previous_root_part_cframe = root_part.CFrame

    root_part.AssemblyLinearVelocity = Vector3.new(1, 1, 1)
    root_part.CFrame = item_cframe

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

    local tool = local_player.Backpack:FindFirstChild(item_name)

    while tool == nil do
        tool = local_player.Backpack:FindFirstChild(item_name)

        local teleport_back_once_obtained = configuration.teleport_to_item.teleport_back_once_obtained

        if not teleport_back_once_obtained then
            return
        end

        run_service.Stepped:Wait()
    end

    root_part.AssemblyLinearVelocity = Vector3.new(1, 1, 1)
    root_part.CFrame = previous_root_part_cframe

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

local function create_teleport_function(cframe)
    local function teleport_function()
        local character = local_player.Character

        if not character then
            return
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")

        if not humanoid then
            return
        end

        local root_part = humanoid.RootPart

        if not root_part then
            return
        end

        root_part.AssemblyLinearVelocity = Vector3.new(1, 1, 1)
        root_part.CFrame = cframe

        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    return teleport_function
end

local function create_table_changing_function(target_table, key)
    local function table_changing_function(value, previous_value)
        target_table[key] = value
    end

    return table_changing_function
end

gui_library.colors.main = Color3.fromRGB(0x44, 0x74, 0x3D)
gui_library.colors.innerBorder = Color3.fromRGB(0x1C, 0x18, 0x18)
gui_library.designerelements = {}
gui_library.elements = {}
gui_library.flags["__Designer.Background.UseBackgroundImage"] = true
gui_library.flags["__Designer.Background.ImageAssetID"] = "rbxassetid://12361274255"
gui_library.flags["__Designer.Background.ImageTransparency"] = 98

local main_esp_gui = Instance.new("ScreenGui")

main_esp_gui.Parent = game:GetService("CoreGui")

local window = gui_library:CreateWindow({
    Name = "green bell pepper premium",
    HideTheme = true
})

local general_tab = window:CreateTab({
    Name = "general"
})

local hitbox_extender_section = general_tab:CreateSection({
    Name = "hitbox extender"
})

local silly_section = general_tab:CreateSection({
    Name = "silly"
})

local attack_player_section = general_tab:CreateSection({
    Name = "attack player",
    Side = "Right"
})

local silent_aimbot_section = general_tab:CreateSection({
    Name = "silent aimbot",
    Side = "Right"
})

local gun_modifiers_section = general_tab:CreateSection({
    Name = "gun modifiers"
})

local teleports_tab = window:CreateTab({
    Name = "teleports"
})

local character_tab = window:CreateTab({
    Name = "character"
})

local visuals_tab = window:CreateTab({
    Name = "visuals"
})

local backpack_esp_section = visuals_tab:CreateSection({
    Name = "backpack esp"
})

local general_esp_section = visuals_tab:CreateSection({
    Name = "general esp"
})

local chams_section = visuals_tab:CreateSection({
    Name = "chams"
})

local movement_section = character_tab:CreateSection({
    Name = "movement"
})

local defense_section = character_tab:CreateSection({
    Name = "defense",
    Side = "Right"
})

local auto_respawn_section = character_tab:CreateSection({
    Name = "auto respawn"
})

local items_section = teleports_tab:CreateSection({
    Name = "item"
})

local players_section = teleports_tab:CreateSection({
    Name = "player",
    Side = "Right"
})

local locations_section = teleports_tab:CreateSection({
    Name = "locations"
})

local function activate_all_vending_machines()
    for _, descendant in ipairs(game:GetDescendants()) do
        if not descendant:IsA("ClickDetector") then
            continue
        end

        fireclickdetector(descendant)
    end
end

silly_section:AddButton({
    Name = "use all vending machines",
    Callback = activate_all_vending_machines
})

locations_section:AddButton({
    Name = "criminal base",
    Callback = create_teleport_function(CFrame.new(-1, 76, 980))
})

locations_section:AddButton({
    Name = "cafeteria",
    Callback = create_teleport_function(CFrame.new(-9, 79, 41))
})

locations_section:AddButton({
    Name = "yard",
    Callback = create_teleport_function(CFrame.new(108, 77, 198))
})

locations_section:AddButton({
    Name = "armory",
    Callback = create_teleport_function(CFrame.new(-20, 79, 153))
})

locations_section:AddButton({
    Name = "cell block",
    Callback = create_teleport_function(CFrame.new(102, 79, 50))
})

locations_section:AddButton({
    Name = "ufo spawn",
    Callback = create_teleport_function(CFrame.new(-1143, 183, 849))
})

locations_section:AddButton({
    Name = "prison rooftop",
    Callback = create_teleport_function(CFrame.new(13, 109, 68))
})

attack_player_section:AddTextBox({
    Name = "player string",
    Value = "",
    Callback = create_table_changing_function(configuration.attack_player, "player_string")
})

local attack_target_label = attack_player_section:AddLabel({
    Value = "target"
})

attack_player_section:AddButton({
    Name = "hit player with melee weapon",
    Callback = hit_player_with_melee_weapon
})

-- teleport to player --
players_section:AddTextBox({
    Name = "player string",
    Value = "",
    Callback = create_table_changing_function(configuration.teleport_to_player, "player_string")
})

local target_label = players_section:AddLabel({
    Value = "target"
})

players_section:AddButton({
    Name = "teleport to",
    Callback = teleport_to_player
})

-- teleport to item --
items_section:AddTextBox({
    Name = "item name",
    Value = "Revolver",
    Callback = create_table_changing_function(configuration.teleport_to_item, "name")
})

items_section:AddButton({
    Name = "teleport to",
    Callback = teleport_to_item
})

items_section:AddToggle({
    Name = "teleport back once obtained",
    Value = true,
    Callback = create_table_changing_function(configuration.teleport_to_item, "teleport_back_once_obtained")
})

-- hitbox extender --
hitbox_extender_section:AddSlider({
    Name = "hitbox size",
    Value = 8,
    Precise = 1,
    Min = 4,
    Max = 20,
    Callback = create_table_changing_function(configuration.hitbox_extender, "extended_hitbox_size")
})

hitbox_extender_section:AddToggle({
    Name = "enabled",
    Value = false,
    Callback = create_table_changing_function(configuration.hitbox_extender, "enabled")
})

-- silent aimbot --
silent_aimbot_section:AddSlider({
    Name = "field of view",
    Value = 120,
    Min = 40,
    Max = 1080,
    Callback = create_table_changing_function(configuration.silent_aimbot, "field_of_view_size")
})

silent_aimbot_section:AddToggle({
    Name = "enabled",
    Value = false,
    Callback = create_table_changing_function(configuration.silent_aimbot, "enabled")
})

-- gun modifiers section --
gun_modifiers_section:AddSlider({
    Name = "spread",
    Value = 1,
    Precise = 2,
    Min = 0,
    Max = 1,
    Callback = create_table_changing_function(configuration.gun_modifiers, "spread_multiplier")
})

gun_modifiers_section:AddSlider({
    Name = "shotgun reload speed",
    Value = 1,
    Precise = 1,
    Min = 1,
    Max = 10,
    Callback = create_table_changing_function(configuration.gun_modifiers, "shotgun_reload_speed_multiplier")
})

-- movement --
movement_section:AddSlider({
    Name = "walk speed",
    Value = starter_player.CharacterWalkSpeed,
    Min = 8,
    Max = 256,
    Callback = create_table_changing_function(configuration.movement, "walk_speed")
})

movement_section:AddSlider({
    Name = "run speed",
    Value = 24,
    Min = 12,
    Max = 384,
    Callback = create_table_changing_function(configuration.movement, "run_speed")
})

movement_section:AddSlider({
    Name = "crawl speed",
    Value = 8,
    Min = 4,
    Max = 128,
    Callback = create_table_changing_function(configuration.movement, "crawl_speed")
})

movement_section:AddSlider({
    Name = "jump height",
    Value = starter_player.CharacterJumpHeight,
    Precise = 1,
    Min = 4,
    Max = 64,
    Callback = create_table_changing_function(configuration.movement, "jump_height")
})

movement_section:AddToggle({
    Name = "no clip",
    Value = false,
    Callback = create_table_changing_function(configuration.movement, "no_clip_enabled"),
    Keybind = {
        Value = Enum.KeyCode.Z
    }
})

movement_section:AddToggle({
    Name = "float",
    Value = false,
    Callback = create_table_changing_function(configuration.movement, "float_enabled"),
    Keybind = {
        Value = Enum.KeyCode.X
    }
})

-- defense section --
defense_section:AddToggle({
    Name = "anti tase",
    Value = false,
    Callback = create_table_changing_function(configuration.defense, "anti_tase_enabled")
})

defense_section:AddToggle({
    Name = "anti void",
    Value = true,
    Callback = create_table_changing_function(configuration.defense, "anti_void_enabled")
})

-- auto respawn section --
auto_respawn_section:AddToggle({
    Name = "teleport back to grave",
    Value = false,
    Callback = create_table_changing_function(configuration.auto_respawn, "teleport_back_to_death_location")
})

auto_respawn_section:AddToggle({
    Name = "enabled",
    Value = false,
    Callback = create_table_changing_function(configuration.auto_respawn, "enabled")
})

-- general esp section --
general_esp_section:AddSlider({
    Name = "name display distance",
    Value = 64,
    Min = 0,
    Max = 256,
    Callback = create_table_changing_function(configuration.general_esp, "name_display_distance")
})

general_esp_section:AddSlider({
    Name = "health display distance",
    Value = 64,
    Min = 0,
    Max = 256,
    Callback = create_table_changing_function(configuration.general_esp, "health_display_distance")
})

general_esp_section:AddToggle({
    Name = "enabled",
    Value = false,
    Callback = create_table_changing_function(configuration.general_esp, "enabled")
})

-- chams section --
chams_section:AddToggle({
    Name = "enabled",
    Value = false,
    Callback = create_table_changing_function(configuration.chams, "enabled")
})

local function extend_hitboxes(delta_time)
    local extended_hitbox_size = configuration.hitbox_extender.extended_hitbox_size

    if extended_hitbox_size == nil then
        return print("why?")
    end

    local hitbox_extender_enabled = configuration.hitbox_extender.enabled

    local character = local_player.Character
 
    if character == nil then
        return
    end
 
    local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
 
    if humanoid_root_part == nil then
        return
    end

    local held_tool = character:FindFirstChildWhichIsA("Tool")
    local handle = held_tool and held_tool:FindFirstChild("Handle")
    local muzzle = handle and handle:FindFirstChild("Muzzle")
 
    for _, player in pairs(players:GetPlayers()) do
        if player == local_player then
            continue
        end
 
        local player_character = player.Character
        
        if player_character == nil then
            continue
        end
 
        local player_humanoid_root_part = player_character:FindFirstChild("HumanoidRootPart")
        local player_humanoid = player_character:FindFirstChild("Humanoid")
        local player_head = player_character:FindFirstChild("Head")

        if player_humanoid_root_part == nil or player_head == nil or player_humanoid == nil then
            continue
        end

        if not hitbox_extender_enabled then
            player_humanoid_root_part.Transparency = 1
            player_humanoid_root_part.CanQuery = false
            player_humanoid_root_part.CollisionGroupId = 0
            continue
        end

        player_humanoid_root_part.CanCollide = false
        player_humanoid_root_part.Shape = Enum.PartType.Ball
        player_humanoid_root_part.BrickColor = player.Team.TeamColor
        player_humanoid_root_part.Size = Vector3.new(extended_hitbox_size, extended_hitbox_size, extended_hitbox_size)

        if player_humanoid.Health <= 0 then
            player_humanoid_root_part.Transparency = 1
            player_humanoid_root_part.CanQuery = false
            player_humanoid_root_part.CollisionGroupId = 0
            continue
        end

        if player.Team == local_player.Team then
            player_humanoid_root_part.Transparency = 0.95
            player_humanoid_root_part.CanQuery = false
            player_humanoid_root_part.CollisionGroupId = 0
            continue
        end

        if muzzle == nil then
            player_humanoid_root_part.Transparency = 0.7
            player_humanoid_root_part.CanQuery = true
            player_humanoid_root_part.CollisionGroupId = player_head.CollisionGroupId
            continue
        end

        local distance = (muzzle.WorldPosition - player_humanoid_root_part.Position).Magnitude

        if distance <= extended_hitbox_size / 2 then
            player_humanoid_root_part.Transparency = 0.95
            player_humanoid_root_part.CanQuery = false
            player_humanoid_root_part.CollisionGroupId = 0
            continue
        end
 
        player_humanoid_root_part.Transparency = 0.7
        player_humanoid_root_part.CanQuery = true
        player_humanoid_root_part.CollisionGroupId = player_head.CollisionGroupId
    end
end

local function apply_no_clip(delta_time)
    local character = local_player.Character
 
    if character == nil then
        return
    end

    local no_clip_enabled = configuration.movement.no_clip_enabled
 
    if not no_clip_enabled then
        return
    end

    for _, child in pairs(character:GetChildren()) do
        if not child:IsA("BasePart") then
            continue
        end

        child.CanCollide = false
    end
end

local float_platform_part = Instance.new("Part")

float_platform_part.Parent = workspace
float_platform_part.CanCollide = false
float_platform_part.Transparency = 1
float_platform_part.Anchored = true

local function apply_float(delta_time)
    local float_enabled = configuration.movement.float_enabled
 
    float_platform_part.CanCollide = float_enabled

    if not float_enabled then
        return
    end

    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local root_part = humanoid.RootPart

    if not root_part then
        return
    end

    float_platform_part.Size = Vector3.new(2, 0.2, 1.5)
    float_platform_part.CFrame = root_part.CFrame * CFrame.new(0, -3.1, 0)
end

local function apply_walk_speed(delta_time)
    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local walk_speed = configuration.movement.walk_speed
    local run_speed = configuration.movement.run_speed
    local crawl_speed = configuration.movement.crawl_speed

    humanoid.WalkSpeed = ((humanoid.WalkSpeed == 16 or humanoid.WalkSpeed == 10) and walk_speed) or ((humanoid.WalkSpeed == 24 or humanoid.WalkSpeed == 18) and run_speed) or (humanoid.WalkSpeed == 8 and crawl_speed) or 0
end

local function apply_camera_subject(delta_time)
    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local current_camera = workspace.CurrentCamera

    current_camera.CameraSubject = humanoid
end

local function apply_jump_height(delta_time)
    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local jump_height = configuration.movement.jump_height

    humanoid.JumpHeight = jump_height
end

local anti_tase_enabled_bool_value = Instance.new("BoolValue")

local function apply_anti_tase(delta_time)
    anti_tase_enabled_bool_value.Value = configuration.defense.anti_tase_enabled
end

local function apply_anti_void(delta_time)
    if not configuration.defense.anti_void_enabled then
        return
    end

    local character = local_player.Character

    if not character then
        return
    end

    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return
    end

    local root_part = humanoid.RootPart

    if not root_part then
        return
    end

    if root_part.Position.Y < -60 then
        root_part.AssemblyLinearVelocity = Vector3.new(0, 1, 0)
    end
end

local default_chat_system_events = replicated_storage:WaitForChild("DefaultChatSystemChatEvents")
local say_message_request = default_chat_system_events:WaitForChild("SayMessageRequest")
local on_message_done_filtering = default_chat_system_events:WaitForChild("OnMessageDoneFiltering")
local network_client = game:GetService("NetworkClient")
local script_context = game:GetService("ScriptContext")

local player_gui = local_player:WaitForChild("PlayerGui")
local chat_gui = player_gui:WaitForChild("Chat")
local frame = chat_gui:WaitForChild("Frame")
local chat_channel_parent_frame = frame:WaitForChild("ChatChannelParentFrame")
local message_log_display_frame = chat_channel_parent_frame:WaitForChild("Frame_MessageLogDisplay")
local scroller = message_log_display_frame:WaitForChild("Scroller")

local function render_silent_aimbot(delta_time)
    field_of_view_circle.Visible = false
    cursor_drawing.Visible = false

    if not configuration.silent_aimbot.enabled then
        return
    end

    local character = local_player.Character

    if not character then
        return
    end

    local tool = character:FindFirstChildWhichIsA("Tool")

    if not tool then
        return
    end

    local handle = tool:FindFirstChild("Handle")

    if not handle then
        return
    end

    local muzzle = handle:FindFirstChild("Muzzle")

    if not muzzle and tool.Name ~= "Handcuffs" then
        return
    end

    field_of_view_circle.Visible = true
    cursor_drawing.Visible = true
    field_of_view_circle.Radius = configuration.silent_aimbot.field_of_view_size
    field_of_view_circle.Position = user_input_service:GetMouseLocation()
end

local function render_general_esp(delta_time)
    if not configuration.general_esp.enabled then
        for _, player in pairs(players:GetPlayers()) do
            local character = player.Character

            if not character then
                continue
            end

            local humanoid = character:FindFirstChildWhichIsA("Humanoid")

            if not humanoid then
                continue
            end

            humanoid.NameDisplayDistance = 64
            humanoid.HealthDisplayDistance = 64
            humanoid.NameOcclusion = Enum.NameOcclusion.OccludeAll
            humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
        end

        return
    end

    for _, player in pairs(players:GetPlayers()) do
        local character = player.Character

        if not character then
            continue
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")

        if not humanoid then
            continue
        end

        humanoid.NameDisplayDistance = configuration.general_esp.name_display_distance
        humanoid.HealthDisplayDistance = configuration.general_esp.health_display_distance
        humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
    end
end

local function update_player_string_text_label(delta_time)
    local function teleport_to_player_player_string()
        local player = evaluate_single_player_string(configuration.teleport_to_player.player_string)

        if player then
            return target_label:Set("@" .. player.Name .. " (" .. player.DisplayName .. ")")
        end

        target_label:Set("no one")
    end

    teleport_to_player_player_string()

    local function attack_player_player_string()
        local player = evaluate_single_player_string(configuration.attack_player.player_string)

        if player then
            return attack_target_label:Set("@" .. player.Name .. " (" .. player.DisplayName .. ")")
        end

        attack_target_label:Set("no one")
    end

    attack_player_player_string()
end

local function render_chams(delta_time)
    if not configuration.chams.enabled then
        for _, player in ipairs(players:GetPlayers()) do
            if player == local_player then
                continue
            end

            local character = player.Character

            if character == nil then
                continue
            end

            local chams_highlight = character:FindFirstChild("chams_highlight")

            if chams_highlight == nil then
                continue
            end

            chams_highlight:Destroy()
        end

        return
    end

    for _, player in ipairs(players:GetPlayers()) do
        if player == local_player then
            continue
        end

        local character = player.Character

        if character == nil then
            continue
        end

        local chams_highlight = character:FindFirstChild("chams_highlight") or Instance.new("Highlight")

        chams_highlight.Parent = character
        chams_highlight.Name = "chams_highlight"
        chams_highlight.Adornee = nil
        chams_highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        chams_highlight.Enabled = true
        chams_highlight.OutlineTransparency = 1
        chams_highlight.FillTransparency = 0.5
        chams_highlight.FillColor = player.TeamColor.Color
    end
end

local function on_render_stepped(delta_time)
    update_player_string_text_label(delta_time)
    apply_camera_subject(delta_time)
    apply_walk_speed(delta_time)
    apply_jump_height(delta_time)
    render_silent_aimbot(delta_time)
    render_general_esp()
    apply_float(delta_time)
    extend_hitboxes(delta_time)
    apply_anti_void(delta_time)
    render_chams(delta_time)
end

local function on_stepped(_, delta_time)
    apply_anti_tase(delta_time)
    apply_no_clip(delta_time)
end

local root_part_death_cframe
local camera_death_cframe

local function on_character_added(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root_part = humanoid.RootPart
    local disabled_connections_which_unequip_tools = {}

    local function on_humanoid_died()
        if not configuration.auto_respawn.enabled then
            return
        end

        local join_team_remote_event = remote_events.join_team_remote_event

        if join_team_remote_event == nil then
            return
        end

        local current_camera = workspace.CurrentCamera

        root_part_death_cframe = root_part.CFrame
        camera_death_cframe = current_camera.CFrame

        join_team_remote_event.Parent = replicated_storage

        join_team_remote_event:FireServer(teams:FindFirstChild("Neutral"))
        join_team_remote_event:FireServer(local_player.Team)

        join_team_remote_event.Parent = nil
    end

    humanoid.Died:Connect(on_humanoid_died)

    local function auto_respawn_teleport_back_to_death_location()
        if not configuration.auto_respawn.teleport_back_to_death_location then
            return
        end

        if root_part_death_cframe == nil then
            return
        end

        local current_camera = workspace.CurrentCamera

        root_part.CFrame = root_part_death_cframe
        current_camera.CFrame = camera_death_cframe
    end

    auto_respawn_teleport_back_to_death_location()

    run_service.Heartbeat:Wait()

    local function disable_connections_which_unequip_tools()
        local folders = {}

        for _, instance in pairs(getnilinstances()) do
            if instance:IsA("Folder") then
                table.insert(folders, instance)
            end
        end

        for _, folder in ipairs(folders) do
            for _, descendant in pairs(folder:GetDescendants()) do
                if not descendant:IsA("RemoteEvent") then
                    continue
                end

                for _, connection in pairs(getconnections(descendant.OnClientEvent)) do
                    local connected_function = connection.Function

                    if not connected_function then
                        continue
                    end

                    if iscclosure(connected_function) then
                        continue
                    end

                    local connected_function_constants = getconstants(connected_function)

                    if not table.find(connected_function_constants, "UnequipTools") then
                        continue
                    end

                    connection:Disable()

                    table.insert(disabled_connections_which_unequip_tools, connection)
                end
            end
        end
    end

    local function enable_connections_which_unequip_tools()
        for index, connection in ipairs(disabled_connections_which_unequip_tools) do
            connection:Enable()

            table.remove(disabled_connections_which_unequip_tools, index)
        end
    end

    local function on_anti_tase_enabled_bool_value_changed(value)
        if value then
            return disable_connections_which_unequip_tools()
        end

        return enable_connections_which_unequip_tools()
    end

    anti_tase_enabled_bool_value.Changed:Connect(on_anti_tase_enabled_bool_value_changed)

    if not configuration.defense.anti_tase_enabled then
        return
    end

    disable_connections_which_unequip_tools()
end

run_service.RenderStepped:Connect(on_render_stepped)
run_service.Stepped:Connect(on_stepped)
local_player.CharacterAdded:Connect(on_character_added)

starter_gui:SetCore("SendNotification", {
    Title = "loaded",
    Text = "green bell pepper premium loaded without any issues",
    Icon = "rbxassetid://10248739816",
    Duration = 7
})