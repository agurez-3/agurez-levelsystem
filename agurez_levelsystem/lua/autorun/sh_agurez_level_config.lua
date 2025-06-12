--AGUREZ Levelsystem
--Made by OverlordAkise

--Current XP multiplier
AGUREZ_LEVEL_XP_MULTIPLIER = 1
--Should each job have its own leveling
AGUREZ_XP_PERJOB = false
--Interval for giving XP in seconds
AGUREZ_XP_TIMER = 300
--How many XP every interval
AGUREZ_XP_TIMER_XP = 20
--How many XP per player kill
AGUREZ_XP_KILL = 5
--Should you get XP if you are AFK
AGUREZ_XP_DISABLE_WHILE_AFK = false

--Function for calculating how many XP you need per level
--Currently: Linear scaling
function AGUREZLevelRequiredXP(lvl)
    return (5+(lvl*5))
end

--UI stuff
--Show xp bar only if you press TAB
--This changes the design from a thin bar at the top
--to a bigger bar in the upper half of the screen
AGUREZ_LEVEL_SHOW_TAB = false


print("[AGUREZ_levelsystem] config loaded")
