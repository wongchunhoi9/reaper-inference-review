-- Inference Review and Presentation - Swap and replay
-- Toolbar button: Swap & replay · Switches to the other config (like A/B swap) and plays again from where playback started.
-- Needs: REF / config lanes.
-- "Where playback started" = the edit cursor: REAPER leaves it where you pressed play.
-- Stopped: switches and starts playing from the edit cursor. Works with Safe playback.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local target = T.ab_target()
if not target then T.msg("No REF / config tracks found.") return end

local start = reaper.GetCursorPosition()
if reaper.GetPlayState() & 1 == 1 then reaper.OnStopButton() end
reaper.Undo_BeginBlock()
T.set_active(target)
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: swap and replay", -1)
reaper.SetEditCurPos(start, false, false)
reaper.OnPlayButton()
