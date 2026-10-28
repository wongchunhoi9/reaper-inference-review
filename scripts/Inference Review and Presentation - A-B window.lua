-- Inference Review and Presentation - A-B window
-- Toolbar button: A/B window · Shows which config is A and which is B, with an A ⇄ B crossfader.
-- Needs: REF / config lanes; two configs heard (A = the one heard before, B = the one playing now).
-- Read-out: always up to date while open (A/B swap, Next, number keys, clicking names all update it).
-- Crossfader: touch the slider (or press the arrow keys) to hear A and B together with an equal-power fade
--   (centre = both at -3 dB). Safe playback allows the two solos while the crossfader is in use.
--   It works on track volume and puts the original volumes back when you close the window.
-- Keys: left / right arrows nudge, Space jumps to the other end, Esc closes.
-- Closing (or switching config another way) ends the crossfade: exclusive solo on the side you were nearer.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

if reaper.set_action_options then reaper.set_action_options(1 | 4) end -- re-run closes; toolbar button lit while open
local _, _, sec, cmd = reaper.get_action_context()
reaper.SetToggleCommandState(sec, cmd, 1)
reaper.RefreshToolbar2(sec, cmd)

local KEY = "xfade_orig" -- project ext state: original volumes while crossfading (recovered if REAPER quit mid-fade)
local x = 1.0            -- 0 = all A, 1 = all B
local fade = nil         -- while crossfading: { a = track, b = track, va = vol, vb = vol }

local function restore_saved_volumes()
  local _, saved = reaper.GetProjExtState(0, T.EXT, KEY)
  for g, v in saved:gmatch("([^;=]+)=([^;]+)") do
    local tr = T.track_by_guid(g)
    if tr then reaper.SetMediaTrackInfo_Value(tr, "D_VOL", tonumber(v)) end
  end
  reaper.SetProjExtState(0, T.EXT, KEY, "")
end
restore_saved_volumes() -- left over from a crash / forced quit

local function apply()
  local ga, gb = math.cos(x * math.pi / 2), math.sin(x * math.pi / 2)
  reaper.SetMediaTrackInfo_Value(fade.a, "D_VOL", fade.va * ga)
  reaper.SetMediaTrackInfo_Value(fade.b, "D_VOL", fade.vb * gb)
end

local function start_fade()
  local a, b = T.ab_pair()
  if not (a and b) then return false end
  local proj = reaper.EnumProjects(-1)
  fade = { proj = proj, a = a, b = b, va = reaper.GetMediaTrackInfo_Value(a, "D_VOL"), vb = reaper.GetMediaTrackInfo_Value(b, "D_VOL") }
  reaper.SetProjExtState(proj, T.EXT, KEY, reaper.GetTrackGUID(a) .. "=" .. fade.va .. ";" .. reaper.GetTrackGUID(b) .. "=" .. fade.vb)
  reaper.SetExtState(T.EXT, "xfade", "1", false)
  reaper.SetMediaTrackInfo_Value(a, "I_SOLO", 2)
  reaper.SetMediaTrackInfo_Value(b, "I_SOLO", 2)
  apply()
  return true
end

-- keep_side: true = exclusive solo on the nearer side; false = someone else already switched, leave solo alone
local function end_fade(keep_side)
  if not fade then return end
  local f = fade
  fade = nil
  -- put the volumes back on the project the fade started in (even if another project tab is open now)
  for _, t in ipairs({ { f.a, f.va }, { f.b, f.vb } }) do
    if reaper.ValidatePtr2(f.proj, t[1], "MediaTrack*") then reaper.SetMediaTrackInfo_Value(t[1], "D_VOL", t[2]) end
  end
  reaper.SetProjExtState(f.proj, T.EXT, KEY, "")
  if keep_side and f.proj == reaper.EnumProjects(-1) then
    T.set_active(x < 0.5 and f.a or f.b)
  elseif reaper.ValidatePtr2(f.proj, f.a, "MediaTrack*") and reaper.ValidatePtr2(f.proj, f.b, "MediaTrack*")
    and reaper.GetMediaTrackInfo_Value(f.a, "I_SOLO") ~= 0 and reaper.GetMediaTrackInfo_Value(f.b, "I_SOLO") ~= 0 then
    reaper.SetMediaTrackInfo_Value(f.a, "I_SOLO", 0) -- both still soloed (project tab switched): back to B only
  end
  x = 1.0 -- whatever plays now is B
  reaper.SetExtState(T.EXT, "xfade", "", false)
  reaper.TrackList_AdjustWindows(false)
end

local function move_to(v)
  v = math.max(0, math.min(1, v))
  if not fade and not start_fade() then return end
  x = v
  apply()
end

-- drawing ---------------------------------------------------------------
local function col(hex, a) gfx.set(((hex >> 16) & 255) / 255, ((hex >> 8) & 255) / 255, (hex & 255) / 255, a or 1) end
local function trcol(tr)
  local c = tr and reaper.GetTrackColor(tr) or 0
  if c == 0 then return 0x757575 end
  local r, g, b = reaper.ColorFromNative(c & 0xFFFFFF)
  return (r << 16) | (g << 8) | b
end
local function db(v) return v < 0.0001 and "-inf" or string.format("%+.1f", 20 * math.log(v, 10)) end

local W, H = 560, 230
local SX, SW, SY = 60, 440, 140
gfx.init("Inference Review and Presentation - A/B", W, H)
local drag, was_down = false, false

local function loop()
  local ch = gfx.getchar()
  if ch < 0 or ch == 27 then return end
  -- someone switched configs another way while fading -> stop fading, keep their choice
  if fade and (fade.proj ~= reaper.EnumProjects(-1) or T.get_active() ~= fade.b or reaper.GetMediaTrackInfo_Value(fade.a, "I_SOLO") == 0) then end_fade(false) end

  if ch == 1818584692 then move_to(x - 0.05)       -- left arrow
  elseif ch == 1919379572 then move_to(x + 0.05)   -- right arrow
  elseif ch == 32 then move_to(x < 0.5 and 1 or 0) -- space
  end
  local mx, my, down = gfx.mouse_x, gfx.mouse_y, gfx.mouse_cap & 1 == 1
  if down and not was_down and my > SY - 20 and my < SY + 25 then drag = true end
  if not down then drag = false end
  if drag then move_to((mx - SX) / SW) end
  was_down = down

  local a, b = T.ab_pair()
  if fade then a, b = fade.a, fade.b end
  col(0x1A1A1D); gfx.rect(0, 0, gfx.w, gfx.h, 1)
  gfx.setfont(1, "Arial", 24)
  for i, row in ipairs({ { "A", a, "heard before" }, { "B", b, "playing now" } }) do
    local y = 18 + (i - 1) * 38
    col(trcol(row[2])); gfx.rect(20, y, 28, 28, 1)
    col(0x070709); gfx.x, gfx.y = 27, y + 2; gfx.drawstr(row[1])
    col(0xF0F0F0); gfx.x, gfx.y = 60, y + 2
    gfx.drawstr(row[2] and T.track_name(row[2]) or "(none yet)")
    gfx.setfont(2, "Arial", 15); col(0x909090); gfx.x, gfx.y = 60 + 330, y + 8; gfx.drawstr(row[3]); gfx.setfont(1)
  end
  -- slider
  gfx.setfont(2)
  col(0x3A3A40); gfx.rect(SX, SY - 3, SW, 6, 1)
  col(0x757575); gfx.rect(SX + SW / 2 - 1, SY - 10, 2, 20, 1)
  col(fade and 0xF0F44A or 0x909090); gfx.circle(SX + SW * x, SY, 10, 1, 1)
  col(0xF0F0F0); gfx.x, gfx.y = SX - 30, SY - 8; gfx.drawstr("A"); gfx.x = SX + SW + 18; gfx.drawstr("B")
  col(0xB0B0B0); gfx.x, gfx.y = 20, SY + 26
  if not (a and b) then
    gfx.drawstr("Audition two configs first (click names, Next, or A/B swap); then A and B appear here.")
  elseif fade then
    gfx.drawstr("Crossfading:  A " .. db(math.cos(x * math.pi / 2)) .. " dB   ·   B " .. db(math.sin(x * math.pi / 2)) .. " dB")
  else
    gfx.drawstr("Crossfader off: only B plays. Drag the slider or press ← → to hear both.")
  end
  col(0x707070); gfx.x, gfx.y = 20, H - 28
  gfx.drawstr("← → nudge   ·   Space: other end   ·   Esc / close: keep the nearer side")
  gfx.update()
  reaper.defer(loop)
end

reaper.atexit(function()
  end_fade(true)
  gfx.quit()
  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd)
end)
loop()
