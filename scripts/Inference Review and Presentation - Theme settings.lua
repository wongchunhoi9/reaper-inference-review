-- Inference Review and Presentation - Theme settings
-- Toolbar button: Settings · Sliders for track name size, name width and compact height.
-- Needs: the Inference_Review_and_Presentation theme active.
-- Sliders for the review track panel (Review and Review Note layouts). Needs the Inference_Review_and_Presentation theme active.
-- Changes apply live and are saved with the theme settings.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")

if reaper.set_action_options then reaper.set_action_options(1 | 2) end -- re-running closes the open window

local params = {
  { key = "Review - Track Name Font Size", label = "Track name size", hint = "1-5", step = 1 },
  { key = "Review - Track Name Width", label = "Track name width", hint = "pt", step = 2 },
  { key = "Review - Hide Row 2 Below Track Height", label = "Compact below height", hint = "pt",
    step = 1, help = "Tracks shorter than this hide the fader / meter / M S row and show only the name." },
  { key = "TCP Folder Indent", label = "Folder indent", hint = "pt per level", step = 1 },
}
local function find()
  local i = 0
  while true do
    local ok, desc, val, def, mn, mx = reaper.ThemeLayout_GetParameter(i)
    if not ok then break end
    for _, p in ipairs(params) do
      if desc:sub(1, #p.key) == p.key and not p.idx then p.idx, p.val, p.def, p.min, p.max = i, val, def, mn, mx end
    end
    i = i + 1
  end
end
find()
if not params[1].idx then T.msg("The Inference_Review_and_Presentation theme is not active.\nChoose Options > Themes > Inference_Review_and_Presentation, then run this again.") return end

local function set(p, v)
  v = math.floor((math.max(p.min, math.min(p.max, v)) - p.min) / p.step + 0.5) * p.step + p.min
  v = math.max(p.min, math.min(p.max, v))
  if v ~= p.val then
    reaper.ThemeLayout_SetParameter(p.idx, v, true)
    reaper.ThemeLayout_RefreshAll()
    p.val = v
  end
end

local function col(hex, a) gfx.set(((hex >> 16) & 255) / 255, ((hex >> 8) & 255) / 255, (hex & 255) / 255, a or 1) end
local W, ROW = 620, 62
gfx.init("Inference Review and Presentation - Theme settings", W, 40 + #params * ROW + 30)
local drag, was_down = nil, false
local SX, SW = 200, 250 -- slider x / width

local function loop()
  local ch = gfx.getchar()
  if ch < 0 or ch == 27 then return end
  local mx, my = gfx.mouse_x, gfx.mouse_y
  local down = gfx.mouse_cap & 1 == 1
  col(0x1A1A1D); gfx.rect(0, 0, gfx.w, gfx.h, 1)
  local helptext = "Drag a slider, or click it and use the mouse wheel. Double-click resets. Esc closes."
  for i, p in ipairs(params) do
    if p.idx then
      local y = 20 + (i - 1) * ROW
      local frac = (p.val - p.min) / math.max(1, p.max - p.min)
      local hot = mx >= SX - 8 and mx <= SX + SW + 8 and my >= y + 6 and my <= y + 40
      if down and not was_down and hot then drag = p end
      if drag == p and down then set(p, p.min + (mx - SX) / SW * (p.max - p.min)) end
      if hot and gfx.mouse_wheel ~= 0 then set(p, p.val + (gfx.mouse_wheel > 0 and p.step or -p.step)) end
      if hot and p.help then helptext = p.help end
      -- label
      gfx.setfont(1, "Arial", 17); col(0xF0F0F0); gfx.x, gfx.y = 20, y + 14; gfx.drawstr(p.label)
      -- track + fill + knob
      col(0x3A3A40); gfx.rect(SX, y + 21, SW, 6, 1)
      col(0xF0F44A); gfx.rect(SX, y + 21, math.floor(SW * frac), 6, 1)
      col(hot and 0xFFFFFF or 0xF0F44A); gfx.circle(SX + SW * frac, y + 24, 9, 1, 1)
      -- value
      col(0xF0F44A); gfx.x, gfx.y = SX + SW + 20, y + 14; gfx.drawstr(tostring(math.floor(p.val)))
      gfx.setfont(1, "Arial", 13); col(0x9A9A9A); gfx.x, gfx.y = SX + SW + 60, y + 17; gfx.drawstr(p.hint)
      if p.idx == params[1].idx then
        gfx.x, gfx.y = SX, y + 36; gfx.drawstr("15        16        18        20        24 px  (at 100%)")
      end
    end
  end
  if gfx.mouse_cap & 1 == 1 and not was_down then
    local now = reaper.time_precise()
    if LASTCLICK and now - LASTCLICK < 0.3 and drag then set(drag, drag.def) end
    LASTCLICK = now
  end
  if not down then drag = nil end
  was_down = down
  gfx.mouse_wheel = 0
  gfx.setfont(1, "Arial", 13); col(0x9A9A9A); gfx.x, gfx.y = 20, gfx.h - 26; gfx.drawstr(helptext)
  gfx.update()
  reaper.defer(loop)
end
loop()
