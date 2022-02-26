-- Runs `pandoc` command on the current buffer to convert it into a pdf.

-- file and any other arguments to the Pandoc call
--   args[1] should be the name of the defaults file
-- Takes `args` as a string list of arguments to specify the pandoc defaults
--   args[..] are anything else to pass as command line arguments
--
-- Uses lualatex as the pdf engine unless `--pdf-engine=..` is specified as an argument.
--
-- Writes a pdf file with the same base filename as the current buffer.
--
-- Displays Pandoc output in a notification

vim.api.nvim_add_user_command(
  'Pandoc',
  function(opts)
    require('nvim-pandoc-pdf').pandoc_pdf(opts.args)
  end,
  { nargs = '*' }
)
