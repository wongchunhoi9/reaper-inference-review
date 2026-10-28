-- Inference Review and Presentation - Level match ON-OFF
-- Toolbar button: Level match ON/OFF · Sets every config take as loud as REF in the same prompt (fallback -23 LUFS-I); again = original volumes.
-- Needs: audio on REF / config lanes; prompt regions help (otherwise REF takes that overlap in time are used).
-- ON: measures integrated loudness (LUFS-I) and sets take volumes; a report lists boosts that hit the limit
--     and takes that could clip. OFF: puts every original take volume back. Settings: "Level match settings".
-- The button lights while level matching is on in the current project.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end
local LM = dofile(dir .. "lib/level_match.lua")(T)

local _, _, sec, cmd = reaper.get_action_context()
if LM.is_on() then
  local n = LM.restore()
  reaper.SetToggleCommandState(sec, cmd, 0)
  T.msg("Level matching OFF: original volume restored on " .. n .. " take(s).")
else
  local report = LM.apply()
  reaper.SetToggleCommandState(sec, cmd, 1)
  T.msg(report)
end
reaper.RefreshToolbar2(sec, cmd)
