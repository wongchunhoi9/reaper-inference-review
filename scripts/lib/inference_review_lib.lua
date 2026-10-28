-- Inference Review and Presentation kit: shared helpers. Loaded by every "Inference Review and Presentation - ..." script.
-- Works with plain REAPER 7 (no extensions needed). Mac + Windows.

local T = {}
T.EXT = "InferenceReview"

-- Brand palette (from the logo)
T.palette = {
  yellow = 0xF0F44A, blue = 0x98D1EA, grey = 0x757575, orange = 0xF4743B, black = 0x070709, white = 0xFFFFFF,
}

-- Track colours: REF is grey, configs cycle through the brand colours, then lighter/darker tints.
local function mix(c, target, amt)
  local r, g, b = (c >> 16) & 255, (c >> 8) & 255, c & 255
  local tr, tg, tb = (target >> 16) & 255, (target >> 8) & 255, target & 255
  r = math.floor(r + (tr - r) * amt + 0.5); g = math.floor(g + (tg - g) * amt + 0.5); b = math.floor(b + (tb - b) * amt + 0.5)
  return (r << 16) | (g << 8) | b
end
local base = { T.palette.yellow, T.palette.blue, T.palette.orange }
T.config_colors = {}
for _, amt in ipairs({ 0, 0.45, -0.35 }) do
  for _, c in ipairs(base) do
    T.config_colors[#T.config_colors + 1] = amt >= 0 and mix(c, 0xFFFFFF, amt) or mix(c, 0x000000, -amt)
  end
end

function T.native(hex)
  return reaper.ColorToNative((hex >> 16) & 255, (hex >> 8) & 255, hex & 255) | 0x1000000
end

-- Default row proportions (from the agreed layout spec, in points at 100%)
T.H = { prompt = 70, config = 85, findings = 60 }

T.LAYOUT_CONFIG = "Review"
T.LAYOUT_NOTE = "Review Note"

-- Track roles are stored on the track itself, so they survive save/load.
function T.get_role(tr)
  local _, r = reaper.GetSetMediaTrackInfo_String(tr, "P_EXT:" .. T.EXT .. "_role", "", false)
  return r
end
function T.set_role(tr, role)
  reaper.GetSetMediaTrackInfo_String(tr, "P_EXT:" .. T.EXT .. "_role", role, true)
end
function T.is_note_role(r) return r == "prompt" or r == "findings" or r == "note" end
function T.is_config_role(r) return r == "ref" or r == "config" end

-- Note lanes never make sound: no master/parent send and no hardware outputs.
function T.silence_track(tr)
  reaper.SetMediaTrackInfo_Value(tr, "B_MAINSEND", 0)
  for i = reaper.GetTrackNumSends(tr, 1) - 1, 0, -1 do reaper.RemoveTrackSend(tr, 1, i) end
  reaper.SetMediaTrackInfo_Value(tr, "I_RECARM", 0)
end

function T.apply_role(tr, role)
  T.set_role(tr, role)
  if T.is_note_role(role) then
    reaper.GetSetMediaTrackInfo_String(tr, "P_TCP_LAYOUT", T.LAYOUT_NOTE, true)
    T.silence_track(tr)
  else
    reaper.GetSetMediaTrackInfo_String(tr, "P_TCP_LAYOUT", T.LAYOUT_CONFIG, true)
    reaper.SetMediaTrackInfo_Value(tr, "B_MAINSEND", 1)
  end
end

function T.tracks_with_roles(proj)
  local list = {}
  for i = 0, reaper.CountTracks(proj or 0) - 1 do
    local tr = reaper.GetTrack(proj or 0, i)
    local r = T.get_role(tr)
    if r ~= "" then list[#list + 1] = { tr = tr, role = r, idx = i } end
  end
  return list
end

function T.config_tracks(proj)
  local out = {}
  for _, t in ipairs(T.tracks_with_roles(proj)) do
    if T.is_config_role(t.role) then out[#out + 1] = t.tr end
  end
  return out
end

-- Height lock helpers (REAPER 7 track attribute)
function T.lock_height(tr, on) reaper.SetMediaTrackInfo_Value(tr, "B_HEIGHTLOCK", on and 1 or 0) end
function T.set_height(tr, h, lock)
  local was = reaper.GetMediaTrackInfo_Value(tr, "B_HEIGHTLOCK")
  reaper.SetMediaTrackInfo_Value(tr, "B_HEIGHTLOCK", 0)
  reaper.SetMediaTrackInfo_Value(tr, "I_HEIGHTOVERRIDE", math.max(20, math.floor(h)))
  reaper.SetMediaTrackInfo_Value(tr, "B_HEIGHTLOCK", (lock or was == 1) and 1 or 0)
end

-- Height of the track area (arrange view) in pixels, without extensions:
-- temporarily maximise one track (View: Toggle track zoom to maximum height), read it, restore.
function T.arrange_height()
  local proj = 0
  local n = reaper.CountTracks(proj)
  if n == 0 then return nil end
  local tr = reaper.GetTrack(proj, 0)
  local sel = {}
  for i = 0, n - 1 do local t = reaper.GetTrack(proj, i); sel[i] = reaper.IsTrackSelected(t) end
  local heights = {}
  for i = 0, n - 1 do
    local t = reaper.GetTrack(proj, i)
    heights[i] = { reaper.GetMediaTrackInfo_Value(t, "I_HEIGHTOVERRIDE"), reaper.GetMediaTrackInfo_Value(t, "B_HEIGHTLOCK") }
    reaper.SetMediaTrackInfo_Value(t, "B_HEIGHTLOCK", 0)
  end
  reaper.SetOnlyTrackSelected(tr)
  reaper.Main_OnCommand(40113, 0) -- View: Toggle track zoom to maximum height
  local h = reaper.GetMediaTrackInfo_Value(tr, "I_TCPH")
  reaper.Main_OnCommand(40113, 0)
  for i = 0, n - 1 do
    local t = reaper.GetTrack(proj, i)
    reaper.SetMediaTrackInfo_Value(t, "I_HEIGHTOVERRIDE", heights[i][1])
    reaper.SetMediaTrackInfo_Value(t, "B_HEIGHTLOCK", heights[i][2])
    reaper.SetTrackSelected(t, sel[i])
  end
  return h
end

-- Empty item with notes, shown stretched inside the item (Item notes > "Stretch image/text").
function T.add_note_item(tr, pos, len, text)
  local item = reaper.AddMediaItemToTrack(tr)
  reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", len)
  reaper.GetSetMediaItemInfo_String(item, "P_NOTES", text or "", true)
  local ok, chunk = reaper.GetItemStateChunk(item, "", false)
  if ok then
    chunk = chunk:gsub("\nIMGRESOURCEFLAGS %d+", "")
    chunk = chunk:gsub("\n>%s*$", "\nIMGRESOURCEFLAGS 3\n>\n")
    reaper.SetItemStateChunk(item, chunk, false)
  end
  return item
end

-- Take marker colour that stays readable: black text on light items, white on dark ones.
function T.marker_color_for(item)
  local c = reaper.GetMediaItemInfo_Value(item, "I_CUSTOMCOLOR")
  if c == 0 then c = reaper.GetTrackColor(reaper.GetMediaItem_Track(item)) end
  if c == 0 then return T.native(T.palette.white) end
  local r, g, b = reaper.ColorFromNative(c & 0xFFFFFF)
  local lum = 0.299 * r + 0.587 * g + 0.114 * b
  return T.native(lum > 170 and T.palette.black or T.palette.white)
end


-- Region lanes (REAPER 7.62+): put a region on lane 0 (prompts) or 1 (second layer).
function T.add_region(s, e, name, color, lane)
  reaper.AddProjectMarker2(0, true, s, e, name, -1, color or 0)
  if not reaper.APIExists("SetRegionOrMarkerInfo_Value") then return false end
  for i = reaper.GetNumRegionsOrMarkers(0) - 1, 0, -1 do
    local m = reaper.GetRegionOrMarker(0, i, "")
    if reaper.GetRegionOrMarkerInfo_Value(0, m, "B_ISREGION") == 1
      and math.abs(reaper.GetRegionOrMarkerInfo_Value(0, m, "D_STARTPOS") - s) < 1e-6
      and math.abs(reaper.GetRegionOrMarkerInfo_Value(0, m, "D_ENDPOS") - e) < 1e-6 then
      local _, nm = reaper.GetSetRegionOrMarkerInfo_String(0, m, "P_NAME", "", false)
      if nm == name then reaper.SetRegionOrMarkerInfo_Value(0, m, "I_LANENUMBER", lane or 0) return true end
    end
  end
  return false
end

-- Playback: exactly one REF/config track audible (solo in place), selected so its name lights up.
-- The previous one is remembered for A/B swap.
local function guid(tr) return reaper.GetTrackGUID(tr) end
function T.track_by_guid(g)
  if not g or g == "" then return nil end
  for i = 0, reaper.CountTracks(0) - 1 do local tr = reaper.GetTrack(0, i); if guid(tr) == g then return tr end end
end
function T.get_active()
  local _, g = reaper.GetProjExtState(0, T.EXT, "active"); return T.track_by_guid(g)
end
function T.get_previous()
  local _, g = reaper.GetProjExtState(0, T.EXT, "previous"); return T.track_by_guid(g)
end
function T.set_active(tr, keep_selection)
  local list = T.config_tracks(0)
  local cur = T.get_active()
  reaper.PreventUIRefresh(1)
  for _, t in ipairs(list) do
    if t ~= tr and reaper.GetMediaTrackInfo_Value(t, "I_SOLO") ~= 0 then reaper.SetMediaTrackInfo_Value(t, "I_SOLO", 0) end
  end
  if reaper.GetMediaTrackInfo_Value(tr, "I_SOLO") == 0 then reaper.SetMediaTrackInfo_Value(tr, "I_SOLO", 2) end
  if not keep_selection then reaper.SetOnlyTrackSelected(tr) end
  reaper.PreventUIRefresh(-1)
  if cur ~= tr then
    if cur then reaper.SetProjExtState(0, T.EXT, "previous", guid(cur)) end
    reaper.SetProjExtState(0, T.EXT, "active", guid(tr))
  end
end

function T.msg(s) reaper.ShowMessageBox(s, "Inference Review and Presentation", 0) end

function T.time_range()
  local s, e = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if e > s then return s, e, true end
  local cur = reaper.GetCursorPosition()
  return cur, cur + 5, false
end

return T
