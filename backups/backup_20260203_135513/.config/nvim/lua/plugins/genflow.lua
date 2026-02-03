return {
  dir = "~/.config/nvim/lua/genflow", -- path to your plugin folder
  name = "genflow.nvim",
  dev = true,
  dependencies = { "David-Kunz/gen.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    require("genflow").setup({
      model = "llaama2", -- specify your model here
      context_memory = true,
    })
  end,
}
