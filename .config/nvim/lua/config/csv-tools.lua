-- https://github.com/chen244/csv-tools.lua

local status, csv = pcall(require, "csvtools.lua")
if (not status) then return end

csv.setup {
  before = 10,
  after = 10,
  -- this will clear the highlight of buf after move
  clearafter = false,
  -- this will provide a overflow show
  showoverflow = false,
  -- add an alone title
  titelflow = true,
}
