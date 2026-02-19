if identifyexecutor then
    if string.find(string.lower(({identifyexecutor()})[1]), 'jjsploit') or string.find(string.lower(({identifyexecutor()})[1]), 'bytebreaker') then
        getgenv().identifyexecutor = function()
            return 'Xeno'
        end
    end
    if table.find({'Xeno', '5.0'}, ({identifyexecutor()})[1]) or not (debug.getupvalue or debug.getupvalues or debug.getproto or debug.getconstants or hookfunction or hookmetamethod or getconnections or require) then
        shared.badexecs = true
        return print("SobSense: Unsupported executor")
    end
end

if require then
    local cloneref = cloneref or function(val) return val end
    
    local lplr = cloneref(game:GetService('Players')).LocalPlayer
    local suc = pcall(function() return require(lplr.PlayerScripts.PlayerModule).controls end)

    if not suc then
        shared.badexecs = true
        return print("SobSense: Failed to initialize")
    end
end

local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
    writefile(file, '')
end

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

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in listfiles(path) do
        if file:find('loader') then continue end
        if isfile(file) and select(1, readfile(file):find('--SobSense watermark')) == 1 then
            delfile(file)
        end
    end
end

for _, folder in {'sobsense', 'sobsense/games', 'sobsense/profiles', 'sobsense/assets', 'sobsense/libraries', 'sobsense/guis', 'sobsense/cache'} do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

if not shared.SobSenseDeveloper then
    wipeFolder('sobsense')
    wipeFolder('sobsense/games')
    wipeFolder('sobsense/guis')
    wipeFolder('sobsense/libraries')
end

return loadstring(downloadFile('sobsense/main.lua'), 'main')()
