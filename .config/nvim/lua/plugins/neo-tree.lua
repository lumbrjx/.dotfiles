return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,     -- Show hidden files
          hide_dotfiles = false, -- Do not hide dotfiles (e.g., `.git`, `.env`)
          hide_gitignored = false, -- Do not hide gitignored files
          never_show = { ".git" },
        },
      },
    },
    -- config = function(_, opts)
    --   require("neo-tree").setup(opts)
    -- end,
  },
}
