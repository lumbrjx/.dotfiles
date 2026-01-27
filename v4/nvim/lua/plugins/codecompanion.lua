return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
        },
        inline = {
          adapter = "copilot",
        },
      },
      cmd = {
        "CodeCompanion",
        "CodeCompanionChat",
        "CodeCompanionActionPalette",
        "CodeCompanionSwitchAdapter",
      },
      display = {
        chat = {
         window = {
            position = "right",
            width = 0.35,
          },
        },
        action_palette = {
          width = 5,
          height = 10,
          prompt = "Prompt ",                -- Prompt used for interactive LLM calls
          provider = "default",              -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
          opts = {
            show_preset_actions = true,      -- Show the preset actions in the action palette?
            show_preset_prompts = true,      -- Show the preset prompts in the action palette?
            title = "CodeCompanion actions", -- The title of the action palette

          },
        },
      },
      adapters = {},
    },
    config = function(_, opts)
      opts.adapters.copilot = function()
        return require("codecompanion.adapters").extend("copilot", {})
      end
      opts.adapters.llama2 = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama2",
          model = "llama2",
        })
      end

      opts.adapters.codellama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "codellama",
          model = "codellama",
        })
      end

      require("codecompanion").setup(opts)

      vim.keymap.set("n", "<leader>cu", "<cmd>CodeCompanionActions<CR>",
        { desc = "Open CodeCompanion Action Palette" })

      local progress = require("fidget.progress")
      local handles = {}
      local group = vim.api.nvim_create_augroup("CodeCompanionFidget", {})

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionRequestStarted",
        group = group,
        callback = function(e)
          handles[e.data.id] = progress.handle.create({
            title = "CodeCompanion",
            message = "Thinking...",
            lsp_client = { name = e.data.adapter.formatted_name },
          })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionRequestFinished",
        group = group,
        callback = function(e)
          local h = handles[e.data.id]
          if h then
            h.message = e.data.status == "success" and "Done" or "Failed"
            h:finish()
            handles[e.data.id] = nil
          end
        end,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
}
