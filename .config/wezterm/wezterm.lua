local status, wezterm = pcall(require, "wezterm")
if not status then
  return
end

local function day_of_week(w_num)
  if w_num == 1 then
    return "sun"
  elseif w_num == 2 then
    return "mon"
  elseif w_num == 3 then
    return "tue"
  elseif w_num == 4 then
    return "wed"
  elseif w_num == 5 then
    return "thu"
  elseif w_num == 6 then
    return "fri"
  elseif w_num == 7 then
    return "sat"
  end
end

wezterm.on("update-status", function(window, pane)
  local wday = string.format("(%s)", day_of_week(os.date("*t").wday))
  local date = wezterm.strftime("📆%Y-%m-%d" .. wday .. " ⏰%H:%M:%S")

  local bat = ""

  for _, b in ipairs(wezterm.battery_info()) do
    local battery_state_of_charge = b.state_of_charge * 100
    local battery_icon = ""

    if battery_state_of_charge >= 80 then
      battery_icon = "🌕"
    elseif battery_state_of_charge >= 70 then
      battery_icon = "🌖"
    elseif battery_state_of_charge >= 60 then
      battery_icon = "🌖"
    elseif battery_state_of_charge >= 50 then
      battery_icon = "🌗"
    elseif battery_state_of_charge >= 40 then
      battery_icon = "🌗"
    elseif battery_state_of_charge >= 30 then
      battery_icon = "🌘"
    elseif battery_state_of_charge >= 20 then
      battery_icon = "🌘"
    else
      battery_icon = "🌑"
    end

    bat = string.format("%s%.0f%% ", battery_icon, battery_state_of_charge)
  end

  window:set_right_status(wezterm.format({
    { Text = date .. " " .. bat },
  }))
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local tab_index = tab.tab_index + 1
  return string.format(" %d ", tab_index)
end)

local keys = {
  {
    key = "h",
    mods = "OPT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "v",
    mods = "OPT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
}

return {
  color_scheme = "Dracula (Official)",
  window_background_image = "/Users/gr1m0h/.config/wezterm/images/wallpaper.png",
  window_background_image_hsb = {
    brightness = 0.1,
  },
  keys = keys,
  exit_behavior = "Close",
  font = wezterm.font("HackGen35 Console NF"),
  font_size = 13.0,
  use_ime = true,
  use_fancy_tab_bar = false,
  window_decorations = "RESIZE",
}
