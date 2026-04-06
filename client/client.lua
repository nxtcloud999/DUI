local cache = {}
local isDrawing = false

---@param duiId string
---@param scaleformName string
local function LoadScaleform(duiId, scaleformName)
    local handle = RequestScaleformMovie(scaleformName)
    local startTimer = GetGameTimer()

    while not HasScaleformMovieLoaded(handle) and (GetGameTimer() - startTimer) < 4000 do
        Citizen.Wait(0)
    end

    if not HasScaleformMovieLoaded(handle) then return nil end
    cache[duiId].scaleform = handle
    return handle
end

---@param duiId string
---@param url string
---@param width number
---@param height number
local function StartupDui(duiId, url, width, height)
    local txdName = 'txd_' .. duiId
    local txnName = 'txn_' .. duiId

    cache[duiId].dui = CreateDui(url, width, height)
    while not IsDuiAvailable(cache[duiId].dui) do Citizen.Wait(10) end

    local txd = CreateRuntimeTxd(txdName)
    local duiHandle = GetDuiHandle(cache[duiId].dui)
    CreateRuntimeTextureFromDuiHandle(txd, txnName, duiHandle)

    if cache[duiId].scaleform then
        PushScaleformMovieFunction(cache[duiId].scaleform, 'SET_TEXTURE')
        PushScaleformMovieMethodParameterString(txdName)
        PushScaleformMovieMethodParameterString(txnName)
        PushScaleformMovieFunctionParameterInt(0)
        PushScaleformMovieFunctionParameterInt(0)
        PushScaleformMovieFunctionParameterInt(width)
        PushScaleformMovieFunctionParameterInt(height)
        PopScaleformMovieFunctionVoid()
        cache[duiId].txd = true
    end
end

function Create3dNui(scaleformName, url, width, height)
    local handleId = "DUI_" .. math.random(1000, 9999)
    scaleformName = scaleformName or Config.DefaultScaleform

    cache[handleId] = {
        dui = nil,
        txd = false,
        scaleform = nil,
        show = false,
        coords = nil,
        scale = vector3(0.1, 0.1, 0.1),
        rotation = 0.0
    }

    LoadScaleform(handleId, scaleformName)

    if url then
        local fullUrl = url:match("http") and url or "nui://" .. GetCurrentResourceName() .. "/" .. url
        StartupDui(handleId, fullUrl, width, height)
    end

    local methods = {}

    function methods:show(coords, scale)
        cache[handleId].coords = coords
        cache[handleId].scale = scale or vector3(0.1, 0.1, 0.1)
        cache[handleId].show = true
        isDrawing = true
    end

    function methods:hide()
        cache[handleId].show = false
    end

    function methods:updatePosition(coords)
        cache[handleId].coords = coords
    end

    function methods:setRotation(rot)
        cache[handleId].rotation = rot or 0.0
    end

    function methods:destroy()
        if cache[handleId].dui then DestroyDui(cache[handleId].dui) end
        cache[handleId] = nil
    end

    return handleId, methods
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        if isDrawing then
            local pCoords = GetEntityCoords(PlayerPedId())
            local active = false

            for _, v in pairs(cache) do
                if v.show and v.coords and v.scaleform then
                    local dist = #(pCoords - v.coords)
                    if dist <= Config.DrawDistance then
                        active = true
                        sleep = 0
                        DrawScaleformMovie_3dNonAdditive(
                            v.scaleform,
                            v.coords.x, v.coords.y, v.coords.z,
                            0.0, 0.0, v.rotation,
                            0.0, 1.0, 0.0,
                            v.scale.x, v.scale.y, v.scale.z,
                            2
                        )
                    end
                end
            end
            if not active then sleep = 500 end
        end
        Citizen.Wait(sleep)
    end
end)

if Config.EnablePlaceCommand then
    RegisterCommand("placedui", function()
        local ped = PlayerPedId()
        local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
        local rot = GetEntityHeading(ped)

        local _, dui = Create3dNui(Config.DefaultScaleform, "ui/index.html", 800, 450)
        dui:show(pos, vector3(0.5, 0.3, 1.0))
        dui:setRotation(rot)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                local changed = false

                if IsControlPressed(0, 172) then pos = pos + vector3(0, 0.01, 0); changed = true end
                if IsControlPressed(0, 173) then pos = pos - vector3(0, 0.01, 0); changed = true end
                if IsControlPressed(0, 174) then pos = pos - vector3(0.01, 0, 0); changed = true end
                if IsControlPressed(0, 175) then pos = pos + vector3(0.01, 0, 0); changed = true end
                if IsControlPressed(0, 10)  then pos = pos + vector3(0, 0, 0.01); changed = true end
                if IsControlPressed(0, 11)  then pos = pos - vector3(0, 0, 0.01); changed = true end
                if IsControlPressed(0, 96)  then rot = rot + 0.5; changed = true end
                if IsControlPressed(0, 97)  then rot = rot - 0.5; changed = true end

                if changed then
                    dui:updatePosition(pos)
                    dui:setRotation(rot)
                end

                if IsControlJustReleased(0, 191) then
                    print(string.format("Final Coords: vector4(%.4f, %.4f, %.4f, %.4f)", pos.x, pos.y, pos.z, rot))
                    break
                end
            end
        end)
    end, false)
end