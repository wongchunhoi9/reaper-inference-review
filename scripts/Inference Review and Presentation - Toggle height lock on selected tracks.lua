-- Inference Review and Presentation - Toggle height lock on selected tracks
-- Toolbar button: Lock height · Locks or unlocks the height of the selected tracks.
-- Needs: selected track(s).
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local n = reaper.CountSelectedTracks(0)
if n == 0 then T.msg("Select one or more tracks first.") return end
local first = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0, 0), "B_HEIGHTLOCK")
reaper.Undo_BeginBlock()
for i = 0, n - 1 do T.lock_height(reaper.GetSelectedTrack(0, i), first == 0) end
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: toggle height lock", -1)
