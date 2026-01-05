-- Useful plugins for editing

return {
  --- Add closing brackets
  {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        options = {
          disabled_filetypes = { "text", "markdown" },
          disable_command_mode = true,
        },
      })
    end,
  },
  --- Add shortcut to dial up/down numbers/words
  {
    "monaqa/dial.nvim",
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group {
        -- default augends used when no group name is specified
        default = {
          augend.integer.alias.decimal,  -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.integer.alias.hex,      -- nonnegative hex number  (0x01, 0x1a1f, etc.)
          augend.date.alias["%Y/%m/%d"], -- date (2022/02/19, etc.)
          augend.constant.new {          -- Day of week
            elements = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" },
            word = true,
            cyclic = true,
          },
        },

        -- augends used when group with name `mygroup` is specified
        mygroup = {
          augend.integer.alias.decimal,
          augend.constant.alias.bool,    -- boolean value (true <-> false)
          augend.date.alias["%m/%d/%Y"], -- date (02/19/2022, etc.)
        }
      }

      -- Set keymaps
      vim.keymap.set("n", "<C-a>", function()
        require("dial.map").manipulate("increment", "normal")
      end)
      vim.keymap.set("n", "<C-x>", function()
        require("dial.map").manipulate("decrement", "normal")
      end)
      vim.keymap.set("n", "g<C-a>", function()
        require("dial.map").manipulate("increment", "gnormal")
      end)
      vim.keymap.set("n", "g<C-x>", function()
        require("dial.map").manipulate("decrement", "gnormal")
      end)
      vim.keymap.set("x", "<C-a>", function()
        require("dial.map").manipulate("increment", "visual")
      end)
      vim.keymap.set("x", "<C-x>", function()
        require("dial.map").manipulate("decrement", "visual")
      end)
      vim.keymap.set("x", "g<C-a>", function()
        require("dial.map").manipulate("increment", "gvisual")
      end)
      vim.keymap.set("x", "g<C-x>", function()
        require("dial.map").manipulate("decrement", "gvisual")
      end)
    end
  },
  --- Add custom highlight
  {
    "nvim-mini/mini.hipatterns",
    config = function()
      local hipatterns = require("mini.hipatterns")

      -- Mapping for custom words
      local words = {}
      -- For Neorg, priority for todo tasks
      words["@high"] = "#f24141"
      words["@low"] = "#4188f2"

      local word_color_group = function(_, match)
        local hex

        -- Hard-coded values above
        hex = words[match]

        -- Pattern matching
        local patterns = {
          "@%d+-%d+-%d+$",   -- deadline (e.g. @2025-12-31)
          "@%d+[\\.%d+]*h$", -- Estimated time (e.g. @1h, @1.5h)
        }
        if hex == nil then
          for i = 1, #patterns, 1
          do
            if string.find(match, patterns[i]) then
              hex = "#e5ed10"
            end
          end
        end

        if hex ~= nil then
          return hipatterns.compute_hex_color_group(hex, "bg")
        end
      end

      hipatterns.setup({
        highlighters = {
          -- Default
          fixme      = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack       = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo       = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note       = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
          -- Custom
          word_color = { pattern = "%S+", group = word_color_group },
        },
      })
    end
  },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  -- Manage folding
  {
    "kevinhwang91/nvim-ufo",

    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
              { text = { "%s" },                  click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },

    event = "BufReadPost",

    init = function()
      vim.keymap.set("n", "zR", function()
        require("ufo").openAllFolds()
      end)
      vim.keymap.set("n", "zM", function()
        require("ufo").closeAllFolds()
      end)
    end,

    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      require("ufo").setup({
        close_fold_kinds_for_ft = {
          default = { "imports" },
        },
      })
    end,
  },
  -- Render markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({
        heading = {
          position = "inline",
          sign = false,
          width = "block",
          min_width = 80,
          border = true,
        },
        indent = {
          enabled = true,
          per_level = 2,
          skip_level = 1,
          skip_heading = false,
        },
      })
    end
  }
}
