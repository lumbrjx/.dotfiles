local M = {}
local Path = require("plenary.path")

M.config = {
  model = "llama2",
  context_memory = true,
  default_flow = {},
}

local last_output = "" -- store previous generation output

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  vim.api.nvim_create_user_command("GenFlow", M.select_step, {})
  vim.api.nvim_create_user_command("GenFullFlow", M.run_full_flow, {})
end

-- Load project-specific flow
local function load_project_config()
  local cwd = vim.fn.getcwd()
  local json_path = Path:new(cwd, ".genflow.json")
  local lua_path = Path:new(cwd, ".genflow.lua")

  if json_path:exists() then
    local ok, decoded = pcall(vim.fn.json_decode, json_path:read())
    if ok and decoded then return decoded end
  elseif lua_path:exists() then
    local ok, result = pcall(dofile, tostring(lua_path))
    if ok and result then return result end
  end
  return M.config.default_flow
end

local function expand_path(p)
  return vim.fn.expand(p)
end

local function read_files(files)
  if not files or #files == 0 then return "" end
  local content = {}
  for _, f in ipairs(files) do
    local path = Path:new(vim.fn.expand(f))
    if path:exists() then
      table.insert(content, "File: " .. f .. "\n```" .. path:read() .. "```\n")
    end
  end
  return table.concat(content, "\n")
end

local function run_post_cmd(cmd, dir)
  if not cmd or cmd == "" then return end
  vim.fn.jobstart(cmd, {
    cwd = dir,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ Post command succeeded: " .. cmd)
      else
        vim.notify("⚠️ Post command failed: " .. cmd, vim.log.levels.WARN)
      end
    end,
  })
end

-- 🔥 updated: now supports step.output_path
local function run_step(step)
  local dir = expand_path(step.dir or ".")
  vim.cmd("cd " .. dir)

  local entity = ""
  if not step.skip_input then
    entity = vim.fn.input("Entity name for " .. step.name .. ": ")
    if entity == "" then return end
  end

  -- Load prompt text (can be inline or file)
  local prompt_text = step.prompt
  if Path:new(prompt_text):exists() then
    prompt_text = Path:new(prompt_text):read()
  end

  -- Inject file context
  local context = read_files(step.context_files)

  -- Inject previous LLM output if enabled
  if M.config.context_memory and last_output ~= "" then
    context = context .. "\nPrevious step output:\n```\n" .. last_output .. "\n```"
  end

  -- Ask for output path if dynamic
  local output_path = step.output_path
  if step.ask_output then
    output_path = vim.fn.input("Output file path: ", output_path or "")
  elseif output_path and entity ~= "" then
    output_path = output_path:gsub("$ENTITY", entity)
  end

  local gen = require("gen")
  gen.open({
    model = M.config.model,
    prompt = (context ~= "" and (context .. "\n\n") or "") .. prompt_text ..
        (entity ~= "" and ("\nEntity: " .. entity) or ""),
    on_finish = function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      last_output = table.concat(lines, "\n")

      -- ✨ Write generated output to file if specified
      if output_path and output_path ~= "" then
        local expanded = vim.fn.expand(output_path)
        local path = Path:new(expanded)
        path:parent():mkdir({ parents = true, exists_ok = true })

        local ok, err = pcall(function()
          path:write(last_output, "w")
        end)

        if ok then
          vim.notify("💾 Generated code written to " .. expanded)
        else
          vim.notify("❌ Failed to write to " .. expanded .. ": " .. err, vim.log.levels.ERROR)
        end
      end

      run_post_cmd(step.post_cmd, dir)
    end,
  })
end

function M.select_step()
  local flow = load_project_config()
  vim.ui.select(vim.tbl_map(function(s) return s.name end, flow), {
    prompt = "Select generation step:",
  }, function(choice)
    if not choice then return end
    for _, s in ipairs(flow) do
      if s.name == choice then
        run_step(s)
        return
      end
    end
  end)
end

function M.run_full_flow()
  local flow = load_project_config()
  for _, s in ipairs(flow) do
    run_step(s)
  end
end

return M

