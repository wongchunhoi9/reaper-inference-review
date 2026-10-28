-- Inference Review and Presentation - Add note item
-- Toolbar button: + Note · Note item on the selected track, then opens its notes window.
-- Needs: selected track; time selection (or uses 5 s at the edit cursor).
-- Adds an empty item with stretched note text on the selected track, over the time selection
-- (or 5 s at the edit cursor), then opens its notes window so you can type.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local tr = reaper.GetSelectedTrack(0, 0)
if not tr then T.msg("Select a track first (for example FINDINGS).") return end
local s, e = T.time_range()
reaper.Undo_BeginBlock()
reaper.Main_OnCommand(40289, 0) -- Item: Unselect all items
local item = T.add_note_item(tr, s, e - s, "")
reaper.SetMediaItemSelected(item, true)
reaper.UpdateArrange()
reaper.Undo_EndBlock("Inference Review and Presentation: add note item", -1)
reaper.Main_OnCommand(40850, 0) -- Item: Show notes for items
