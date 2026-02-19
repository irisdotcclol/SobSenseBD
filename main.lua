repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end
if shared.badexecs then return end

if identifyexecutor then
    if not table.find({'AWP', 'Volt', 'Zenith', 'Nihon', 'Seliware', 'Nucleus'}, ({identifyexecutor()})[1]) then
        getgenv().setthreadidentity = function(val)
            return val
        end
    end
end

local vape
local loadstring = function(...)
    local res, err = loadstring(...)
    if err and vape then
        vape:CreateNotification('SobSense', 'Failed to load : '..err, 30, 'alert')
    end
    return res
end
local queue_on_teleport = queue_on_teleport or queueonteleport or function() end
local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
    return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/irisdotcclol/SobSenseBD/main/'..select(1, path:gsub('sobsense/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        if path:find('.lua') then
            res = '--SobSense watermark\n'..res
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function finishLoading()
    vape.Init = nil
    vape:Load()
    task.spawn(function()
        repeat
            vape:Save()
            task.wait(10)
        until not vape.Loaded
    end)

    local teleportedServers
    vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
        if (not teleportedServers) and (not shared.VapeIndependent) then
            teleportedServers = true
            local teleportScript = [[
                shared.vapereload = true
                if shared.SobSenseDeveloper then
                    loadstring(readfile('sobsense/loader.lua'), 'loader')()
                else
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/irisdotcclol/SobSenseBD/main/loader.lua', true), 'loader')()
                end
            ]]
            if shared.SobSenseDeveloper then
                teleportScript = 'shared.SobSenseDeveloper = true\n'..teleportScript
            end
            vape:Save()
            queue_on_teleport(teleportScript)
        end
    end))

    if not shared.vapereload then
        if not vape.Categories then return end
        if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
            vape:CreateNotification('SobSense Loaded', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
        end
    end
end

if not isfile('sobsense/profiles/gui.txt') then
    writefile('sobsense/profiles/gui.txt', 'new')
end
local gui = readfile('sobsense/profiles/gui.txt')

if not isfolder('sobsense/assets/'..gui) then
    makefolder('sobsense/assets/'..gui)
end
vape = loadstring(downloadFile('sobsense/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

if not shared.VapeIndependent then
    loadstring(downloadFile('sobsense/games/universal.lua'), 'universal')()
    task.spawn(function(...)
        if isfile('sobsense/games/'..game.PlaceId..'.lua') then
            loadstring(readfile('sobsense/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
        else
            if not shared.SobSenseDeveloper then
                local suc, res = pcall(function()
                    return game:HttpGet('https://raw.githubusercontent.com/irisdotcclol/SobSenseBD/main/games/'..game.PlaceId..'.lua', true)
                end)
                if suc and res ~= '404: Not Found' then
                    loadstring(downloadFile('sobsense/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
                end
            end
        end
    end)
    finishLoading()
else
    vape.Init = finishLoading
    return vape
end
