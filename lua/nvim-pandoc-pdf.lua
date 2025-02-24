local M = {}
-- Runs `pandoc` command on the current buffer to convert it into a pdf.
--
-- Takes `args` as a string list of arguments to pass to the pandoc command line
--
-- Writes a pdf file with the same base filename as the current buffer.
--
-- Displays Pandoc output in a notification using Snacks.notifier


function M.pandoc_pdf(args)
  local uv = vim.uv
  vim.notify = require('snacks').notifier.notify
  local outname = vim.fn.expand('%:t:r') .. '.pdf'
  local bufname = vim.api.nvim_buf_get_name(0)
  local arg_fields = { '-o', outname, }
  args:gsub('([^ ]+)', function(c) arg_fields[#arg_fields+1] = c end)

  arg_fields[#arg_fields + 1] = bufname

  local notify = function(msg, level, timeout)
    vim.notify(msg, level, {title="Pandoc to PDF", timeout = timeout})
  end

  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()
  local o, e = "", ""
  handle = uv.spawn('pandoc', {
      stdio = { nil, stdout, stderr },
      args = arg_fields,
    },
    vim.schedule_wrap(function()
      if #e > 0 then
        notify(e, vim.log.levels.ERROR, 10000)
      end
      if #o > 0 then
        notify(o, vim.log.levels.INFO, 3000)
      elseif e == "" then
        notify("Pandoc successfully wrote " .. outname, vim.log.levels.INFO, 3000)
      end
      stdout:read_stop()
      stderr:read_stop()
      stdout:close()
      stderr:close()
      handle:close()
    end)
  )
  notify("Pandoc starting conversion for " .. outname, vim.log.levels.INFO, 3000)
  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    if data or err then
      o = o .. (data or err)
    end
  end)
  uv.read_start(stderr, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data or err then
      e = e .. (data or err)
    end
  end))
end

return M
