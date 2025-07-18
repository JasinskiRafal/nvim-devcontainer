-- vscode style color scheme
return {
  "Mofiqul/vscode.nvim",
  priority = 1000,
  opts = {
    style = "dark",
    italic_comments = true,
    underline_links = true,
    color_overrides = {
      vscCursorDarkDark = "#2d2d2d",
    },
  },
  init = function()
    vim.cmd.colorscheme("vscode")
  end,
}
