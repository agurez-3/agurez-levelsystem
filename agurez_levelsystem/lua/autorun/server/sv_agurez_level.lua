hook.Add("PostGamemodeLoaded","agurez_levelsystem",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS agurez_levelsystem( steamid TEXT, steamid64 TEXT, exp INT, lvl INT )")
    --SteamID64 to link it to a playername with darkrp_player table
    if res == false then
        error(sql.LastError())
    end
end)

local plymeta = FindMetaTable("Player")

function plymeta:setLevel(level)
    self:setDarkRPVar("level",level)
end

function plymeta:setXP(xp)
    self:setDarkRPVar("xp",xp)
end

function plymeta:addXP(amount)
    if agurez_XP_DISABLE_WHILE_AFK and self:getDarkRPVar("AFK",false) then return end
    local getxp = amount
    local mult = hook.Run("agurezLevelMultXP",self,amount)
    if tonumber(mult) then
        getxp = getxp*mult
    end
    getxp = getxp*agurez_LEVEL_XP_MULTIPLIER
    
    local curXP = self:getXP() + getxp
    local curLevel = self:getLevel()
    local oldLevel = curLevel
    DarkRP.notify(self,0,5,"You received "..getxp.." XP!")
    while curXP >= agurezLevelRequiredXP(curLevel)  do
        curXP = curXP - agurezLevelRequiredXP(curLevel)
        curLevel = curLevel + 1
        DarkRP.notify(self,0,5,"You reached Lv."..curLevel.."!")
    end
    self:setXP(curXP)
    self:setLevel(curLevel)
    agurezLevelSave(self)
    hook.Run("agurezLevelGained",self,getxp,curLevel-oldLevel)
end

plymeta.AddXP = plymeta.addXP

--internal functions from now on

local function sSID(ply)
    if agurez_XP_PERJOB then
        return sql.SQLStr(ply:SteamID()..team.GetName(ply:Team()))
    else
        return sql.SQLStr(ply:SteamID())
    end
end

function agurezLevelSave(ply)
    local res = sql.Query("UPDATE agurez_levelsystem SET exp = "..ply:getXP()..", lvl = "..ply:getLevel().." WHERE steamid = "..sSID(ply))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
end

function agurezLevelLoad(ply)
    ply:setLevel(1)
    ply:setXP(0)
    local res = sql.QueryRow("SELECT * FROM agurez_levelsystem WHERE steamid = "..sSID(ply))
    if res == false then
        error(sql.LastError())
    end
    if res then
        ply:setLevel(tonumber(res.lvl))
        ply:setXP(tonumber(res.exp))
        print("[agurez_levelsystem] User successfully loaded!")
    else
        local res = sql.Query("INSERT INTO agurez_levelsystem(steamid,steamid64,exp,lvl) VALUES("..sSID(ply)..","..sql.SQLStr(ply:SteamID64())..",0,1)")
        if res == false then
            error(sql.LastError())
        end
        print("[agurez_levelsystem] New user successfully inserted!")
    end
end

hook.Add("OnPlayerChangedTeam", "agurez_levelsystem", function(ply,before,after)
    if agurez_XP_PERJOB then
        agurezLevelLoad(ply)
    end
end)

hook.Add("PlayerDisconnected", "agurez_levelsystem", function(ply)
    agurezLevelSave(ply)
    timer.Remove("levelload_"..ply:SteamID())
end)
 
hook.Add("ShutDown", "agurez_levelsystem", function()
    for k,v in pairs(player.GetHumans()) do
        agurezLevelSave(v)
    end
end)

hook.Add("PlayerInitialSpawn","agurez_levelsystem",function(ply)
    if not agurez_XP_PERJOB then
        agurezLevelLoad(ply)
    else
        timer.Create("levelload_"..ply:SteamID(),1,0,function()
            if not IsValid(ply) then
                timer.Remove("levelload_"..ply:SteamID())
                return
            end
            if ply:Team() == 0 then return end
            agurezLevelLoad(ply)
            timer.Remove("levelload_"..ply:SteamID())
        end)
    end
end)

hook.Add("PlayerDeath","agurez_levelsystem",function(ply,inflictor,attacker)
    if attacker:IsPlayer() and IsValid(attacker) then
        attacker:addXP(agurez_XP_KILL)
    end
end)

timer.Create("agurez_levelsystem",agurez_XP_TIMER,0,function()
    for k,v in ipairs(player.GetAll()) do
        v:addXP(agurez_XP_TIMER_XP)
    end
end)

--Restrict job changes
hook.Add("playerCanChangeTeam","agurez_levelsystem",function(ply,newTeam,force)
    if force then return true, "Job change was forced!" end
    local jobTable = RPExtraTeams[newTeam]
    if jobTable and jobTable.level and ply:getLevel() < jobTable.level then
        return false, "Level too low!"
    end
end)

print("[agurez_levelsystem] sv loaded")
