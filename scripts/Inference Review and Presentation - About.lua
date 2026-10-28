-- Inference Review and Presentation - About
-- Toolbar button: About · Shows the kit version, the theme version actually loaded and the REAPER version, with warnings.
-- Needs: nothing.
-- Checks: REAPER older than T.FEATURE_REAPER (no region lanes), review theme not active, theme from a different kit version.
local dir = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local T = dofile(dir .. "lib/inference_review_lib.lua")
if not T.check_reaper() then return end

-- Theme: our theme defines the parameter 'Review - Kit version X.Y.Z (info only)'. Theme 1.0.0 had none.
local theme_file = reaper.GetLastColorThemeFile() or ""
local theme_name = theme_file:match("([^/\\]+)$") or "(unknown)"
local theme_ver, is_review_theme = nil, false
local i = 0
while true do
  local ok, desc = reaper.ThemeLayout_GetParameter(i)
  if not ok then break end
  if desc:find("^Review %- ") then is_review_theme = true end
  theme_ver = theme_ver or desc:match("^Review %- Kit version ([%d%.]+)")
  i = i + 1
end

local have = reaper.GetAppVersion()
local lines = {
  "Inference Review and Presentation Kit",
  "",
  "Kit (scripts) version:  " .. T.VERSION,
  "Theme loaded:  " .. theme_name .. (theme_ver and ("  (kit version " .. theme_ver .. ")") or ""),
  "REAPER:  " .. have,
  "Scripts folder:  " .. dir,
}
local warn = {}
if T.reaper_version() < tonumber(T.FEATURE_REAPER) then
  warn[#warn + 1] = "REAPER is older than " .. T.FEATURE_REAPER .. ": no region lanes, '+ Region lane 2' is off. Update REAPER."
end
if not is_review_theme then
  warn[#warn + 1] = "The review theme is not active, so the Review / Review Note track layouts won't show.\n" ..
    "   Options > Themes > Inference_Review_and_Presentation (or double-click the .ReaperThemeZip from the kit)."
elseif theme_ver ~= T.VERSION then
  warn[#warn + 1] = "The loaded theme is from kit version " .. (theme_ver or "1.0.0 or older") ..
    ", the scripts are " .. T.VERSION .. ".\n   Double-click Inference_Review_and_Presentation.ReaperThemeZip from the same kit download."
end

lines[#lines + 1] = ""
if #warn == 0 then
  lines[#lines + 1] = "All good: theme and scripts match, REAPER supports every feature."
else
  lines[#lines + 1] = "Check:"
  for _, w in ipairs(warn) do lines[#lines + 1] = "- " .. w end
end
lines[#lines + 1] = ""
lines[#lines + 1] = "Theme: LGPL v2+ (based on Cockos Default 7.0). Scripts and icons: MIT."
lines[#lines + 1] = "https://github.com/wongchunhoi9/reaper-inference-review"
T.msg(table.concat(lines, "\n"))
