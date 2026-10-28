-- Inference Review and Presentation kit: level matching (used by "Level match ON-OFF" and "Level match settings").
-- Makes every REF / config take play at the same loudness, so A/B comparisons aren't decided by volume.
--   * Loudness = integrated LUFS of the part of the audio file the item plays (REAPER's CalculateNormalization).
--   * Target per take: "ref" mode = the loudness REF has in the same prompt region (as you hear it now);
--     where a prompt has no REF take, the fallback target (default -23 LUFS-I) is used.
--     "fixed" mode = the fixed target for every take, REF included.
--   * Applied as TAKE volume (non-destructive). The original take volume is kept in the take (P_EXT) and put
--     back when level matching is turned off. Track faders and item volume are not touched.
--   * Safety: boost limited to +max_boost dB; takes whose true peak would go above -1 dBTP are listed.
-- Settings and on/off state are stored in the project.
return function(T)
  local LM = {}
  local K_ORIG, K_DB = "P_EXT:" .. T.EXT .. "_lm_orig", "P_EXT:" .. T.EXT .. "_lm_db"

  local function db(v) return 20 * math.log(v, 10) end
  local function getp(key, default)
    local _, v = reaper.GetProjExtState(0, T.EXT, key)
    return v ~= "" and v or default
  end

  function LM.settings()
    return { mode = getp("lm_mode", "ref"), target = tonumber(getp("lm_target", "-23")), max_boost = tonumber(getp("lm_max_boost", "12")) }
  end
  function LM.save_settings(s)
    reaper.SetProjExtState(0, T.EXT, "lm_mode", s.mode)
    reaper.SetProjExtState(0, T.EXT, "lm_target", tostring(s.target))
    reaper.SetProjExtState(0, T.EXT, "lm_max_boost", tostring(s.max_boost))
  end
  function LM.is_on() return getp("lm_on", "") == "1" end

  -- original take volume (before level matching touched it)
  local function orig_vol(take)
    local _, v = reaper.GetSetMediaItemTakeInfo_String(take, K_ORIG, "", false)
    return tonumber(v) or reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
  end

  -- integrated LUFS and true peak (dBTP) of what the item plays, before any volume. nil for empty / MIDI takes.
  local function measure(item, take)
    local src = reaper.GetMediaItemTake_Source(take)
    if not src then return nil end
    local typ = reaper.GetMediaSourceType(src, "")
    if typ == "" or typ == "MIDI" or typ == "EMPTY" then return nil end
    local rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
    local s = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
    local e = s + reaper.GetMediaItemInfo_Value(item, "D_LENGTH") * rate
    local m = reaper.CalculateNormalization(src, 0, 0, s, e)   -- 0 = LUFS-I: multiplier that brings it to 0 LUFS
    local p = reaper.CalculateNormalization(src, 3, 0, s, e)   -- 3 = true peak: multiplier to 0 dBTP
    if not m or m <= 0 or m > 1e6 then return nil end           -- silent
    return -db(m), (p and p > 0) and -db(p) or nil
  end

  -- prompt regions: ruler lane 1 (lane number 0) when region lanes exist, else every region
  local function prompt_regions()
    local out = {}
    if reaper.APIExists("GetRegionOrMarker") then
      for i = 0, reaper.GetNumRegionsOrMarkers(0) - 1 do
        local m = reaper.GetRegionOrMarker(0, i, "")
        if reaper.GetRegionOrMarkerInfo_Value(0, m, "B_ISREGION") == 1 and reaper.GetRegionOrMarkerInfo_Value(0, m, "I_LANENUMBER") == 0 then
          local _, name = reaper.GetSetRegionOrMarkerInfo_String(0, m, "P_NAME", "", false)
          out[#out + 1] = { s = reaper.GetRegionOrMarkerInfo_Value(0, m, "D_STARTPOS"), e = reaper.GetRegionOrMarkerInfo_Value(0, m, "D_ENDPOS"), name = name }
        end
      end
    else
      local i = 0
      while true do
        local ok, isrgn, s, e, name = reaper.EnumProjectMarkers3(0, i)
        if ok == 0 then break end
        if isrgn then out[#out + 1] = { s = s, e = e, name = name } end
        i = i + 1
      end
    end
    return out
  end

  -- every REF / config item with its take, loudness, prompt region
  local function collect()
    local regions, list = prompt_regions(), {}
    for _, t in ipairs(T.tracks_with_roles(0)) do
      if T.is_config_role(t.role) then
        for k = 0, reaper.CountTrackMediaItems(t.tr) - 1 do
          local item = reaper.GetTrackMediaItem(t.tr, k)
          local take = reaper.GetActiveTake(item)
          if take then
            local pos, len = reaper.GetMediaItemInfo_Value(item, "D_POSITION"), reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            local mid, rg = pos + len / 2, nil
            for _, r in ipairs(regions) do if mid >= r.s and mid < r.e then rg = r break end end
            local lufs, tp = measure(item, take)
            list[#list + 1] = { item = item, take = take, track = t.tr, ref = t.role == "ref", s = pos, e = pos + len,
              region = rg, lufs = lufs, tp = tp, itemvol = db(math.max(1e-9, reaper.GetMediaItemInfo_Value(item, "D_VOL"))) }
          end
        end
      end
    end
    return list
  end

  local function label(x) return T.track_name(x.track) .. (x.region and (" @ " .. x.region.name) or string.format(" @ %.1f s", x.s)) end

  -- REF level (as heard now) for this take: the REF take in the same prompt region, else the REF take that overlaps most
  local function ref_level(x, list)
    local best, best_ov
    for _, r in ipairs(list) do
      if r.ref and r.lufs then
        local same = x.region and r.region == x.region
        local ov = math.min(x.e, r.e) - math.max(x.s, r.s)
        if same or (not x.region and ov > 0) then
          if not best or ov > best_ov then best, best_ov = r, ov end
        end
      end
    end
    if best then return best.lufs + db(orig_vol(best.take)) + best.itemvol end
  end

  -- Measures and applies. Returns a report string.
  function LM.apply()
    local st = LM.settings()
    reaper.Undo_BeginBlock()
    LM.restore_all() -- start from the original volumes (re-measure, or settings changed)
    local list = collect()
    local n, n_ref, n_fallback, capped, clipping, skipped = 0, 0, 0, {}, {}, 0
    for _, x in ipairs(list) do
      if not x.lufs then
        skipped = skipped + 1
      elseif not (x.ref and st.mode == "ref") then
        local target = st.mode == "ref" and ref_level(x, list) or nil
        if target then n_ref = n_ref + 1 else target = st.target; n_fallback = n_fallback + 1 end
        local vol_db = target - x.lufs - x.itemvol            -- take volume that lands it on the target
        if vol_db > st.max_boost then vol_db = st.max_boost; capped[#capped + 1] = label(x) end
        local orig = reaper.GetMediaItemTakeInfo_Value(x.take, "D_VOL")
        reaper.GetSetMediaItemTakeInfo_String(x.take, K_ORIG, tostring(orig), true)
        reaper.SetMediaItemTakeInfo_Value(x.take, "D_VOL", 10 ^ (vol_db / 20))
        reaper.GetSetMediaItemTakeInfo_String(x.take, K_DB, string.format("%+.1f", vol_db - db(orig)), true)
        if x.tp and x.tp + vol_db + x.itemvol > -1 then clipping[#clipping + 1] = string.format("%s (%.1f dBTP)", label(x), x.tp + vol_db + x.itemvol) end
        n = n + 1
      end
    end
    reaper.SetProjExtState(0, T.EXT, "lm_on", "1")
    reaper.Undo_EndBlock("Inference Review and Presentation: level match", -1)
    reaper.UpdateArrange()
    local r = { string.format("Level matching ON: %d takes adjusted (take volume).", n) }
    if st.mode == "ref" then
      r[#r + 1] = string.format("Matched to REF: %d.  No REF in that prompt, used %.1f LUFS-I: %d.", n_ref, st.target, n_fallback)
    else
      r[#r + 1] = string.format("Fixed target %.1f LUFS-I (REF included).", st.target)
    end
    if skipped > 0 then r[#r + 1] = skipped .. " take(s) skipped (empty, MIDI or silent)." end
    if #capped > 0 then r[#r + 1] = "\nBoost limited to +" .. st.max_boost .. " dB (still quieter than target):\n- " .. table.concat(capped, "\n- ") end
    if #clipping > 0 then r[#r + 1] = "\nTrue peak above -1 dBTP after gain (may clip):\n- " .. table.concat(clipping, "\n- ") end
    return table.concat(r, "\n")
  end

  -- Puts every original take volume back (no undo block). Returns how many takes were restored.
  local function restore_all()
    local n = 0
    for i = 0, reaper.CountMediaItems(0) - 1 do
      local item = reaper.GetMediaItem(0, i)
      for k = 0, reaper.CountTakes(item) - 1 do
        local take = reaper.GetTake(item, k)
        local _, v = reaper.GetSetMediaItemTakeInfo_String(take, K_ORIG, "", false)
        if v ~= "" then
          reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", tonumber(v))
          reaper.GetSetMediaItemTakeInfo_String(take, K_ORIG, "", true)
          reaper.GetSetMediaItemTakeInfo_String(take, K_DB, "", true)
          n = n + 1
        end
      end
    end
    return n
  end
  LM.restore_all = restore_all

  function LM.restore()
    reaper.Undo_BeginBlock()
    local n = restore_all()
    reaper.SetProjExtState(0, T.EXT, "lm_on", "")
    reaper.Undo_EndBlock("Inference Review and Presentation: level match off", -1)
    reaper.UpdateArrange()
    return n
  end

  -- offset text for the export ("+1.8"), or "" when the take isn't level matched
  function LM.offset(take)
    local _, v = reaper.GetSetMediaItemTakeInfo_String(take, K_DB, "", false)
    return v
  end

  return LM
end
