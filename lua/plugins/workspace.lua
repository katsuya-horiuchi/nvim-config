return {
  --- Color scheme
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000, -- Make sure to load this before all the other plugins
    config = function()
      require("monokai-pro").setup({
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
        styles = {
          comment = { italic = false },
          keyword = { italic = false },
          type = { italic = false },
          storageclass = { italic = false },
          structure = { italic = false },
          parameter = { italic = false },
          annotation = { italic = false },
          tag_attribute = { italic = false },
        },
        filter = "spectrum",
      })
      vim.cmd([[colorscheme monokai-pro-spectrum]])
    end,
  },
  -- Tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      require("nvim-tree").setup({
        filters = {
          dotfiles = false,
        },
        view = {
          preserve_window_proportions = true,
        },
      })
      require("utils").restore_on_close("NvimTree")
    end,
  },
  -- Manage windows (e.g. swap two windows)
  {
    "sindrets/winshift.nvim",
  },
  --- Add "powerline"
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {},
      })
    end,
  },
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- optional but recommended
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "crispgm/telescope-heading.nvim"
    },
    config = function()
      require("telescope").setup({
        extensions = {
          heading = {
            picker_opts = {
              sorting_strategy = "ascending"
            }
          }
        }
      })
    end
  },
  {
    "stevearc/aerial.nvim",
    branch = "nvim-0.11",
    config = function()
      local width = 30
      require("aerial").setup({
        disable_max_lines = 20000,
        layout = {
          width = width,
          min_width = width,
          max_width = width,
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "aerial",
        callback = function()
          vim.wo.foldmethod = "indent"
          -- ufo maps zR/zM globally to its own functions which don't work here;
          -- override them locally to use the standard vim fold commands instead.
          vim.keymap.set("n", "zR", function() vim.cmd("normal! zR") end, { buffer = true })
          vim.keymap.set("n", "zM", function() vim.cmd("normal! zM") end, { buffer = true })
          -- aerial may shadow the global <Space>→za mapping; restore it locally.
          vim.keymap.set("n", "<Space>", "za", { buffer = true })
        end,
      })

      -- Set keymaps
      local utils = require("utils")
      -- restore_on_open=false: aerial always opens at its configured width so no
      -- restoration is needed. Restoring would call nvim_win_set_width anyway,
      -- which fires WinResized and triggers nvim-tree's preserve_window_proportions
      -- to cascade widths into adjacent windows, shrinking code buffers over time.
      vim.keymap.set("n", "<leader>ta",
        function() utils.toggle_with_restore("AerialToggle", "aerial",
            { restore_on_open = false }) end)
      utils.restore_on_close("aerial")
    end
  }
}
