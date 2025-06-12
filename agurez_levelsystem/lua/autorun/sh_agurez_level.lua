local plymeta = FindMetaTable("Player")

function plymeta:hasLevel(level)
    return self:getLevel() >= level
end

function plymeta:getLevel()
    return tonumber(self:getDarkRPVar("level"))
end

function plymeta:getXP()
    return tonumber(self:getDarkRPVar("xp"))
end

hook.Add("postLoadCustomDarkRPItems","agurez_levelsystem_register",function()
    DarkRP.registerDarkRPVar("xp", net.WriteDouble, net.ReadDouble)
    DarkRP.registerDarkRPVar("level", net.WriteDouble, net.ReadDouble)
end)

print("[agurez_levelsystem] sh loaded")
