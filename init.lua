vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.cursorline = true
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("NeovimTerminalBackground", { clear = true }),
  pattern = "catppuccin",
  command = "highlight Normal guibg=NONE ctermbg=NONE",
})
vim.cmd.colorscheme("catppuccin")

vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.keymap.set("i", "<C-CR>", "<C-o>o", { desc = "Open a line below" })

vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp" },
  root_markers = { ".clangd", ".git" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "clangd" then
      return
    end

    vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = "Go to definition",
    })
  end,
})

vim.lsp.enable("clangd")

vim.g.mapleader = " "

vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.pick", version = "stable" },
})

local pick = require("mini.pick")
local previous_select = vim.ui.select
pick.setup()
vim.ui.select = previous_select

vim.keymap.set("n", "<leader>ff", function()
  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, ".git")
  pick.builtin.files(
    { tool = root and "git" or "fallback" },
    { source = { cwd = root or cwd } }
  )
end, { desc = "搜索文件名" })
