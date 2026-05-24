return {
  "David-Kunz/gen.nvim",
  lazy = false,
  priority = 1000,

  opts = {
    model = "mistral", -- or "llama3.2", "codellama", etc.
    host = "127.0.0.1",
    port = "11434",
    display_mode = "float",
    show_prompt = true,
    debug = true,
    init = function()
      -- start ollama automatically (optional)
      pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
    end,

    -- this is the crucial fix: proper `command` function
    command = function(options)
      local body = vim.fn.json_encode({
        model = options.model,
        messages = { { role = "user", content = options.prompt } },
        stream = false,
      })

      return string.format(
        "curl --silent -X POST http://%s:%s/api/chat -d %s",
        options.host,
        options.port,
        vim.fn.shellescape(body)
      )
    end,
  },
}

