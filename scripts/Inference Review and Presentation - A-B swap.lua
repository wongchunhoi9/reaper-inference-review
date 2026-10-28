-- Inference Review and Presentation - A-B swap
-- Toolbar button: A/B swap · Flips between the current and the previously heard config.
-- Needs: two configs heard in this session.
-- Switches between the current and the previously auditioned config (exclusive solo). Playback keeps running.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local cur, prev = T.get_active(), T.get_previous()
local list = T.config_tracks(0)
if #list == 0 then T.msg("No REF / config tracks found.") return end
if not prev or prev == cur then
  -- nothing remembered yet: swap between the selected config and REF
  local sel = reaper.GetSelectedTrack(0, 0)
  prev = (sel and T.is_config_role(T.get_role(sel)) and sel ~= cur) and sel or list[1]
  if prev == cur then prev = list[2] or list[1] end
end
reaper.Undo_BeginBlock()
T.set_active(prev)
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: A/B swap", -1)
