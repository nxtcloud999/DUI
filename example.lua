Citizen.CreateThread(function()
    -- Warte kurz, bis das System bereit ist
    Citizen.Wait(1000)

    for i, data in ipairs(Config.StaticScreens) do
        local _, screen = Create3dNui(Config.DefaultScaleform, data.url, 800, 450)
        
        screen:show(data.pos, data.scale)
        screen:setRotation(data.rot)
        
        print(string.format("^2[Example] Screen #%s erfolgreich geladen.^0", i))
    end
end)