-- Inference Review and Presentation - Solo previous config
-- Toolbar button: ◀ Previous · Solos the previous lane (REF, A, B ...); playback keeps running.
-- Needs: REF / config lanes.
-- Steps the solo through REF and the config tracks (previous), selecting the soloed track
-- so its name lights up. Playback keeps running.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

local step = -1
local list = T.config_tracks(0)
if #list == 0 then T.msg("No REF / config tracks found.") return end
local cur = 0
for i, tr in ipairs(list) do if reaper.GetMediaTrackInfo_Value(tr, "I_SOLO") > 0 then cur = i break end end
local nxt
if cur == 0 then nxt = (step > 0) and 1 or #list else nxt = ((cur - 1 + step) % #list) + 1 end
reaper.Undo_BeginBlock()
T.set_active(list[nxt])
reaper.TrackList_AdjustWindows(false)
reaper.Undo_EndBlock("Inference Review and Presentation: solo " .. (step > 0 and "next" or "previous") .. " config", -1)
