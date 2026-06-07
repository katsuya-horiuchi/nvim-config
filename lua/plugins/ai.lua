return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Get devcontainer id
      local result =
        vim.fn.system("devcontainer exec --docker-path podman hostname")
      -- trim whitespace and newline
      local container_id = result:match("^%s*(.-)%s*$")
      if container_id == "" then
        print("Devcontainer is not set up")
      else
        require("claude-code").setup({
          command = "podman exec -it " .. container_id .. " claude",
          window = {
            position = "botright vertical", -- Open terminal on right
          },
        })
        vim.keymap.set("n", "<Leader>cc", ":ClaudeCode<CR>")
      end
    end,
  },
}
