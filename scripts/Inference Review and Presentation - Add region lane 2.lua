-- Inference Review and Presentation - Add region lane 2
-- Region over the time selection in the second ruler lane (REAPER 7.62+), e.g. sections, rounds or issues.
-- Prompt regions from 'Add prompt' stay in lane 1.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local s, e, has = T.time_range()
if not has then T.msg("Make a time selection first.") return end
local ok, name = reaper.GetUserInputs("Inference Review and Presentation - Add region lane 2", 1, "Region name,extrawidth=240", "")
if not ok then return end
reaper.Undo_BeginBlock()
local laned = T.add_region(s, e, name, T.native(T.palette.orange), 1)
reaper.UpdateTimeline()
reaper.Undo_EndBlock("Inference Review and Presentation: add region lane 2", -1)
if not laned then T.msg("Region added, but this REAPER version has no region lanes (needs 7.62 or later), so it is in lane 1.") end
