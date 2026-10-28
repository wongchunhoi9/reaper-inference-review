-- Inference Review and Presentation - A-B swap
-- Toolbar button: A/B swap · Flips between the current and the previously heard config.
-- Needs: two configs heard in this session.
-- Switches between the current and the previously auditioned config (exclusive solo). Playback keeps running.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local prev = T.ab_target()
if not prev then T.msg("No REF / config tracks found.") return end
reaper.Undo_BeginBlock()
T.set_active(prev)
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: A/B swap", -1)
