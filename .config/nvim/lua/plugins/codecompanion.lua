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
          adapter = "deepseek_coder",
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
      adapters = {
        http = {}
      },
    },
    config = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters.http = opts.adapters.http or {}

      opts.adapters.http.copilot = function()
        return require("codecompanion.adapters").extend("copilot", {})
      end
      opts.adapters.http.llama2 = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama2",
          schema = { model = { default = "llama2" } },
        })
      end
      opts.adapters.http.deepseek_coder = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "deepseek_coder",
          schema = {
            model = {
              default = "deepseek-coder-v2",
            },
          },
        })
      end
      opts.adapters.http.codellama = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "codellama",
          schema = { model = { default = "codellama" } },
        })
      end
      opts.adapters.http.llama3 = function()
        return require("codecompanion.adapters").extend("ollama", {
          name = "llama3",
          schema = { model = { default = "llama3" } },
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
