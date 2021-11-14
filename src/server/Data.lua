-- game data functions
-- uncomment code when published

local playerService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local dataService = game:GetService("DataStoreService")     -- used to save data to Roblox servers
local store = dataService:GetDataStore("DataStoreV1_47")   -- create a new GlobalDataStore instance, this is persistent with the key

local sessionData = {}  -- holds a dictionary containing data on current players with UserIds as indices
local dataMod = {}
local AUTOSAVE_INTERVAL = 120

dataMod.recursiveCopy = function(dataTable)
    -- creates a copy of a data table
    local tableCopy = {}

    for index, value in pairs(dataTable) do
        if type(value) == "table" then
            value = dataMod.recursiveCopy(value)
        end

        tableCopy[index] = value
    end

    return tableCopy
end

-- set the default values
local defaultData = {
    Coins = 0,
    Stage = 1,
    Deaths = 0,
    StageDeaths = 0,
}

dataMod.load = function(player)
-- get player data using their player id as a key

    local key = player.UserId
    local data

    local success, err = pcall(function()
        -- ensure connection to server is successful
        data = store:GetAsync(key)
    end)

    if not success then
        data = dataMod.load(player)
    end

    --local data = nil
    return data
end

dataMod.setupData = function(player)
    -- loads stored data for a player
    local key = player.UserId   -- set key to the players user id
    local data = dataMod.load(player)   -- load the data for that player

    sessionData[key] = dataMod.recursiveCopy(defaultData)   -- create a copy of the default values table

    if data then    -- if there is stored data for the player
        for index, value in pairs(data) do  -- load the stored data
            print(player, index, value)
            dataMod.set(player, index, value)
        end

        print(player.Name.. "'s data has been loaded!")
    else
        print(player.Name.. " is a new player!")
    end
end

playerService.PlayerAdded:Connect(function(player)
    -- calls setupData new player joins the game
    local folder = Instance.new("Folder")   -- use the leaderstats system to display
    folder.Name = "leaderstats"             -- the players current stats
    folder.Parent = player

    local coins = Instance.new("IntValue")  -- set the players coins to the default
    coins.Name = "Coins"                    -- value
    coins.Parent = folder
    coins.Value = defaultData.Coins

    local stage = Instance.new("IntValue")  -- set the players stage to the default
    stage.Name = "Stage"                    -- value
    stage.Parent = folder
    stage.Value = defaultData.Stage

    local deaths = Instance.new("IntValue")  -- set the players stage to the default
    deaths.Name = "Deaths"                    -- value
    deaths.Parent = folder
    deaths.Value = defaultData.Deaths

    local hiddenData = Instance.new("Configuration",player)
	hiddenData.Name = 'HiddenData'

    local deathsOnStage = Instance.new("IntValue")
    deathsOnStage.Name = "StageDeaths"
    deathsOnStage.Parent = hiddenData
    deathsOnStage.Value = defaultData.StageDeaths

    dataMod.setupData(player)   -- load stored data

    -- set up spawn location for a player based on their current stage
    local playerStage = dataMod.get(player, "Stage")
    if playerStage then
        for _, descendant in pairs(workspace.SpawnParts:GetDescendants()) do
            if playerStage == descendant:GetAttribute("Stage") then
                player.RespawnLocation = descendant
            end
        end
    else
        player.RespawnLocation = workspace.SpawnParts.Stage1
    end

    player.CharacterAdded:Connect(function(character)
        -- Detect when a player dies and increase their death count
		character:WaitForChild("Humanoid").Died:Connect(function()
			dataMod.increment(player, "Deaths", 1)
            dataMod.increment(player, "StageDeaths", 1)

            if dataMod.get(player, "StageDeaths") == 3 then
                -- fire event to prompt to skip stage
                wait(2)
                replicatedStorage.PromptSkip:FireClient(player)
            end
		end)
    end)
end)

dataMod.set = function(player, stat, value)
    -- set [stat] for [player] to [value] in sessionData
    local key = player.UserId
    sessionData[key][stat] = value
    if stat == "Stage" or stat == "Deaths" or stat == "Coins" then -- if stat belongs in leaderstats
        player.leaderstats[stat].Value = value
    else    
        player.HiddenData[stat].Value = value
    end
end

dataMod.increment = function(player, stat, value)
    -- increment [stat] for [player] by [value] in sessionData
    local key = player.UserId
    sessionData[key][stat] = dataMod.get(player, stat) + value
    if stat == "Stage" or stat == "Deaths" or stat == "Coins" then  -- if stat belongs in leaderstats
        player.leaderstats[stat].Value = dataMod.get(player, stat)
    else
        player.HiddenData[stat].Value = dataMod.get(player, stat)
    end
end

dataMod.get = function(player, stat)
    -- retrieve data from the sessionData table
    local key = player.UserId
    return sessionData[key][stat]
end

dataMod.save = function(player)
    -- save player data from sessionData to store
    local key = player.UserId
    local data = dataMod.recursiveCopy(sessionData[key])

    local success, err = pcall(function()
        -- ensure connection to server is successful
        store:SetAsync(key, data)
    end)

    if success then
        print(player.Name.. "'s data has been saved!")
    else
        dataMod.save(player)
    end
end

dataMod.removeSessionData = function(player)
    -- remove a players data from sessionData
    local key = player.UserId
    sessionData[key] = nil
end

playerService.PlayerRemoving:Connect(function(player)
    -- call the functions when a player leaves the game
    dataMod.save(player)
    dataMod.removeSessionData(player)
end)

game:BindToClose(function()
    -- Save data upon server shut-down
    for _, player in pairs(playerService:GetPlayers()) do
        dataMod.save(player)
        player:Kick("Shutting down game. All data saved.")
    end
end)

local function autoSave()
    while wait(AUTOSAVE_INTERVAL) do
        print("Auto-saving data for all players")
        
        for key, dataTable in pairs(sessionData) do
            local player = playerService:GetPlayerByUserId(key)
            dataMod.save(player)
        end
    end
end

--spawn(autoSave) -- initialise autosave loop

return dataMod