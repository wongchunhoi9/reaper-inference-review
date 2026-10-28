-- Inference Review and Presentation - Add take marker
-- Toolbar button: + Take marker · Point marker at the edit cursor, or a duration pair (start / end) over the time selection.
-- Needs: item under the edit cursor on the selected track (or a selected item); optional time selection.
-- Point marker: no time selection -> one marker at the edit cursor.
-- Range marker: with a time selection over the item -> a start marker '▸ text · 1.25 s' and an end marker '◂'.
-- Works on the selected item under the cursor / time selection, or the item on the selected track.
-- Text colour is black on light items and white on dark ones.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

local ts, te = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
local has_range = te > ts
local cur = reaper.GetCursorPosition()
local probe = has_range and ts or cur
local function range(it) local p = reaper.GetMediaItemInfo_Value(it, "D_POSITION"); return p, p + reaper.GetMediaItemInfo_Value(it, "D_LENGTH") end
local function hits(it)
  local a, b = range(it)
  if has_range then return ts < b and te > a end
  return cur >= a and cur <= b
end
local item
for i = 0, reaper.CountSelectedMediaItems(0) - 1 do local it = reaper.GetSelectedMediaItem(0, i); if hits(it) and reaper.GetActiveTake(it) then item = it break end end
if not item then
  local tr = reaper.GetSelectedTrack(0, 0)
  if tr then for i = 0, reaper.CountTrackMediaItems(tr) - 1 do local it = reaper.GetTrackMediaItem(tr, i); if hits(it) and reaper.GetActiveTake(it) then item = it break end end end
end
local take = item and reaper.GetActiveTake(item)
if not take then T.msg("Put the edit cursor (or a time selection) over an audio item, and select the item or its track.") return end

local a, b = range(item)
local s, e = probe, nil
if has_range then s, e = math.max(ts, a), math.min(te, b) end
local title = has_range and string.format("Range marker (%.2f s)", e - s) or "Take marker"
local ok, name = reaper.GetUserInputs("Inference Review and Presentation - " .. title, 1, "Marker text,extrawidth=220", "")
if not ok then return end

local rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
local offs = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
local function src(t) return (t - a) * rate + offs end
local colr = T.marker_color_for(item)
reaper.Undo_BeginBlock()
if has_range then
  reaper.SetTakeMarker(take, -1, string.format("▸ %s · %.2f s", name, e - s), src(s), colr)
  reaper.SetTakeMarker(take, -1, "◂", src(e), colr)
else
  reaper.SetTakeMarker(take, -1, name, src(s), colr)
end
reaper.UpdateArrange()
reaper.Undo_EndBlock("Inference Review and Presentation: add take marker", -1)
