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
      local hex = words[match]
      if hex == nil then return nil end
      return hipatterns.compute_hex_color_group(hex, "bg")
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
