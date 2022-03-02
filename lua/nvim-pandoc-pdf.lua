local M = {}
-- Runs `pandoc` command on the current buffer to convert it into a pdf.

-- file and any other arguments to the Pandoc call
-- Takes `args` as a string list of arguments to pass to the pandoc command line
--
-- Writes a pdf file with the same base filename as the current buffer.
--
-- Displays Pandoc output in a notification


function M.pandoc_pdf(args)
  vim.notify = require('notify')
  local shortname = vim.fn.expand('%:t:r') .. '.pdf'
  local fullname = vim.api.nvim_buf_get_name(0)

  local arg_fields = {}
  args:gsub('([^ ]+)', function(c) arg_fields[#arg_fields+1] = c end)

  local cmd = {
    'pandoc',
    '-o',
    shortname,
  }
  for c = 1, #arg_fields do
    cmd[#cmd + 1] = arg_fields[c]
  end
  cmd[#cmd + 1] = fullname

  -- TO-DO: Add option to open output file or not
  cmd[#cmd + 1] = '&&'
  cmd[#cmd + 1] = 'xdg-open'
  cmd[#cmd + 1] = shortname

  -- https://github.com/rcarriga/nvim-notify/wiki/Usage-Recipes#output-of-command
  local stdin = vim.loop.new_pipe()
  local stdout = vim.loop.new_pipe()
  local stderr = vim.loop.new_pipe()
  local output = ''
  local error_output = ''
  vim.notify('Pandoc starting conversion for ' .. shortname,'info',
    {
      title='Pandoc',
      timeout = 1000
    })
  vim.loop.spawn(cmd[1],
    {
      stdio = { stdin, stdout, stderr },
      detached = true,
      args = #cmd > 1 and vim.list_slice(cmd, 2, #cmd) or nil,
    },
    function(_)
      stdin:close()
      stdout:close()
      stderr:close()
      if #output > 0 then
        vim.notify(output,'info',{title='Pandoc'})
      end
      if #error_output > 0 then
        vim.notify(error_output, 'error',{title='Pandoc', timeout=false})
      end
      if #output == 0 and #error_output == 0 then
        vim.notify('Pandoc successfully created ' .. shortname, 'info',
          {
            title='Pandoc'
          })
        -- To-do: open file after it's written
        --   this isn't working right now (does nothing) but without scheduling
        --   it throws an error
        -- vim.schedule_wrap(function() vim.fn.jobstart({'xdg-open', shortname}) end)
      end
    end
  )
  stdout:read_start(function(err, data)
    if err then
      error_output = error_output .. (err or data)
      return
    end
    if data then
      output = output .. data
    end
  end)
  stderr:read_start(function(err, data)
    if err or data then
      error_output = error_output .. (err or data)
    end
  end)
end

return M
