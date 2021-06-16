PSCore = nil
TriggerEvent('PSCore:GetObject', function(obj) PSCore = obj end)

PSCore.Functions.CreateCallback('ps-radio:server:GetItem', function(source, cb)
    local Player = PSCore.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName("radio")

    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)