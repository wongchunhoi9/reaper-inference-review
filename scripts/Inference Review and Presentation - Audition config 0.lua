-- Inference Review and Presentation - Audition config 0
-- Solos REF on its own, like clicking its name. Meant for a shortcut key (0 = REF, 1-9 = configs).
-- Needs: REF / config lanes. Works with Safe playback and the A/B memory.
-- All ten "Audition config N" scripts are the same code; N comes from the file name.
local dir, file = ({reaper.get_action_context()})[2]:match("^(.*[/\\])(.*)$")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local n = tonumber(file:match("Audition config (%d)"))
local tr
if n == 0 then
  tr = T.ref_track()
else
  local k = 0
  for _, t in ipairs(T.tracks_with_roles(0)) do
    if t.role == "config" then k = k + 1; if k == n then tr = t.tr break end end
  end
end
if not tr then T.msg(n == 0 and "No REF track found." or ("There is no config " .. n .. " (only REF and config lanes count, in track order).")) return end
reaper.Undo_BeginBlock()
T.set_active(tr)
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: audition " .. (n == 0 and "REF" or ("config " .. n)), -1)
