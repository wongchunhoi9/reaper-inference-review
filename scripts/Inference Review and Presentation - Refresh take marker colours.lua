-- Inference Review and Presentation - Refresh take marker colours
-- Toolbar button: Take marker colour reset · Re-picks black or white text for every take marker after colour changes.
-- Needs: nothing.
-- Re-colours every take marker in the project for contrast with its item:
-- black text on light items, white on dark ones. Run after changing track or item colours.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local n = 0
reaper.Undo_BeginBlock()
for i = 0, reaper.CountMediaItems(0) - 1 do
  local it = reaper.GetMediaItem(0, i)
  local c = T.marker_color_for(it)
  for t = 0, reaper.CountTakes(it) - 1 do
    local take = reaper.GetTake(it, t)
    if take then
      for m = 0, reaper.GetNumTakeMarkers(take) - 1 do
        local pos, name = reaper.GetTakeMarker(take, m)
        reaper.SetTakeMarker(take, m, name, pos, c)
        n = n + 1
      end
    end
  end
end
reaper.UpdateArrange()
reaper.Undo_EndBlock("Inference Review and Presentation: refresh take marker colours", -1)
