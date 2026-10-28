-- Inference Review and Presentation - Unlock height of all tracks
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local on = false
reaper.Undo_BeginBlock()
for i = 0, reaper.CountTracks(0) - 1 do T.lock_height(reaper.GetTrack(0, i), on) end
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: " .. (on and "lock" or "unlock") .. " all track heights", -1)
