local LEVELBOX = {}
LEVELBOX.Colors = {
    Background = Color(50,50,50,200),
    White = Color(255,255,255,255),
    Blue = Color(0,150,255,255),
    Progress = Color(80,80,80,200),
    Edges = Color(255,255,255,120)
}

surface.CreateFont("Agurezfontlvl", {
    font = "Roboto",
    size = 26,
})

surface.CreateFont("AgurezfontXP", {
    font = "Roboto",
    size = 16,
})


local scrw = ScrW()
local scrh = ScrH()
local boxWidth = math.floor(scrh * 0.35)
local boxHeight = math.floor(scrh * 0.06)
local margin = math.floor(scrh * 0.015)
local edgeSize = math.floor(scrh * 0.015)
local barHeight = math.floor(scrh * 0.008)

local curxp = 0
local level = 1
local reqXP = 10
local targetLength = 0
local currentLength = 0

local function LerpNumber(from, to, time)
    return from + (to - from) * math.min(time * 10, 1)
end

local function DrawEdges(x, y, width, height, edgeSize)
    surface.SetDrawColor(LEVELBOX.Colors.Edges)
    surface.DrawRect(x, y, edgeSize, 2)
    surface.DrawRect(x, y, 2, edgeSize)
    surface.DrawRect(x + width - edgeSize, y, edgeSize, 2)
    surface.DrawRect(x + width - 2, y, 2, edgeSize)
    surface.DrawRect(x, y + height - 2, edgeSize, 2)
    surface.DrawRect(x, y + height - edgeSize, 2, edgeSize)
    surface.DrawRect(x + width - edgeSize, y + height - 2, edgeSize, 2)
    surface.DrawRect(x + width - 2, y + height - edgeSize, 2, edgeSize)
end

hook.Add("Think", "agurez_levelsystem_animation", function()
    if currentLength ~= targetLength then
        currentLength = LerpNumber(currentLength, targetLength, FrameTime())
    end
end)

hook.Add("DarkRPVarChanged","agurez_levelsystem",function(ply,name,old,new)
    if ply ~= LocalPlayer() then return end
    if name == "xp" then
        curxp = new
        targetLength = (curxp*(boxWidth-40))/reqXP
    end
    if name == "level" then
        level = new
        reqXP = agurezLevelRequiredXP(level)
    end
end)

hook.Add("HUDPaint","agurez_levelsystem_hud", function()
    local xPos = (scrw - boxWidth) / 2
    local yPos = margin
    
    draw.RoundedBox(0, xPos, yPos, boxWidth, boxHeight, LEVELBOX.Colors.Background)
    DrawEdges(xPos, yPos, boxWidth, boxHeight, edgeSize)
    
    draw.SimpleText("Level " .. level, "Agurezfontlvl", xPos + 20, yPos + boxHeight/2 - 12, LEVELBOX.Colors.White)
    
    draw.RoundedBox(0, xPos + 20, yPos + boxHeight - barHeight - 8, boxWidth - 40, barHeight, LEVELBOX.Colors.Progress)
    
    draw.RoundedBox(0, xPos + 20, yPos + boxHeight - barHeight - 8, currentLength, barHeight, LEVELBOX.Colors.Blue)

    local xpText = curxp .. "/" .. reqXP .. " XP"
    draw.SimpleText(xpText, "AgurezfontXP", xPos + boxWidth - 25, yPos + boxHeight/2 - 12, LEVELBOX.Colors.White, TEXT_ALIGN_RIGHT)
end)

print("[Agurez_levelsystem] cl loaded")