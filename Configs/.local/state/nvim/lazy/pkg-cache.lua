return {version=12,pkgs={{source="lazy",name="astrocore",file="lazy.lua",dir="/home/iris/.local/share/nvim/lazy/astrocore",spec=function()
return {
  "AstroNvim/astrocore",
  opts_extend = {
    "rooter.ignore.servers",
    "rooter.ignore.dirs",
    "sessions.ignore.buftypes",
    "sessions.ignore.dirs",
    "sessions.ignore.filetypes",
    "git_worktrees",
  },
}

end,},{source="lazy",name="astrolsp",file="lazy.lua",dir="/home/iris/.local/share/nvim/lazy/astrolsp",spec=function()
return {
  "AstroNvim/astrolsp",
  opts_extend = {
    "formatting.disabled",
    "formatting.format_on_save.allow_filetypes",
    "formatting.format_on_save.ignore_filetypes",
    "servers",
  },
}

end,},{source="lazy",name="astroui",file="lazy.lua",dir="/home/iris/.local/share/nvim/lazy/astroui",spec=function()
return {
  "AstroNvim/astroui",
  opts_extend = {
    "status.winbar.enabled.filetype",
    "status.winbar.enabled.buftype",
    "status.winbar.enabled.bufname",
    "status.winbar.disabled.filetype",
    "status.winbar.disabled.buftype",
    "status.winbar.disabled.bufname",
  },
}

end,},{source="lazy",name="blink.compat",file="lazy.lua",dir="/home/iris/.local/share/nvim/lazy/blink.compat",spec=function()
return {
  {
    'saghen/blink.compat',
    lazy = true,
  },
}

end,},{source="lazy",name="plenary.nvim",file="community",dir="/home/iris/.local/share/nvim/lazy/plenary.nvim",spec={"nvim-lua/plenary.nvim",lazy=true,},},},}