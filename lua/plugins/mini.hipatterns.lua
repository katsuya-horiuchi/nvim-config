return {
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
}
