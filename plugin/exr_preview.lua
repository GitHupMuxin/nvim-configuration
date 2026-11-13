local api = vim.api
local group = api.nvim_create_augroup("ExrPreview", { clear = true })
local magick = "E:/work/ImageMagick/magick.exe"
local queued = false
local generation = 0
local painted = false

local function set_status(buf, message)
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, { "EXR  " .. vim.fs.basename(api.nvim_buf_get_name(buf)), message })
  vim.bo[buf].modified = false
  vim.bo[buf].modifiable = false
end

local function clear_image()
  generation = generation + 1
  if painted then
    painted = false
    api.nvim_ui_send("\027[2J")
    vim.schedule(function()
      vim.cmd.redraw({ bang = true })
    end)
  end
end

local function render()
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  if not vim.b[buf].exr_preview then
    return
  end
  clear_image()
  if not vim.env.WT_SESSION then
    set_status(buf, "EXR preview requires Windows Terminal.")
    return
  end
  if vim.fn.executable(magick) ~= 1 then
    set_status(buf, "ImageMagick is missing at " .. magick)
    return
  end

  local view = vim.fn.getwininfo(win)[1]
  -- Windows Terminal 的 Sixel 以 10×20 像素为一个字符格。
  local width = math.min(1400, (view.width - view.textoff - 1) * 10)
  local height = math.min(1000, (view.height - 3) * 20)
  if width < 10 or height < 20 then
    set_status(buf, "Enlarge the window to preview this image.")
    return
  end

  local request = generation
  set_status(buf, "Loading preview…")
  vim.system({
    magick, api.nvim_buf_get_name(buf),
    "-resize", ("%dx%d>"):format(width, height),
    "-colorspace", "sRGB", "-alpha", "off", "-colors", "256", "sixel:-",
  }, { timeout = 15000 }, vim.schedule_wrap(function(result)
    -- 异步转换结束时，预览窗口可能已经关闭、切换或缩放。
    if request ~= generation or api.nvim_get_current_win() ~= win or api.nvim_get_current_buf() ~= buf then
      return
    end
    local image = (result.stdout or ""):gsub("[\r\n]+$", "")
    -- 只将完整的 Sixel 数据发给终端，错误输出留在预览缓冲区。
    if result.code ~= 0 or not image:match("^\027P[%d;]*q[!-~\r\n]*\027\\$") then
      local detail = vim.trim(result.stderr or ""):match("^[^\r\n]+")
      set_status(buf, detail or "Unable to generate an EXR preview.")
      return
    end

    set_status(buf, "")
    vim.cmd.redraw()
    local cursor = ("\027[%d;%dH"):format(view.winrow + 1, view.wincol + view.textoff)
    api.nvim_ui_send("\0277" .. cursor .. image .. "\0278")
    painted = true
  end))
end

local function queue_render()
  if queued or not vim.b.exr_preview then
    return
  end
  queued = true
  vim.schedule(function()
    queued = false
    render()
  end)
end

api.nvim_create_autocmd("BufReadCmd", {
  group = group,
  pattern = "*.[eE][xX][rR]",
  callback = function(event)
    local buf = event.buf
    vim.b[buf].exr_preview = true
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    set_status(buf, "")
    vim.keymap.set("n", "q", "<Cmd>bdelete<CR>", { buffer = buf, desc = "Close EXR preview" })
    vim.keymap.set("n", "<C-l>", queue_render, { buffer = buf, desc = "Refresh EXR preview" })
  end,
})

api.nvim_create_autocmd({ "VimEnter", "BufEnter", "WinEnter", "WinResized" }, {
  group = group,
  callback = queue_render,
})

api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = group,
  callback = function(event)
    if vim.b[event.buf].exr_preview then
      clear_image()
    end
  end,
})
