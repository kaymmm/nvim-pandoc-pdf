# nvim-pandoc-pdf

A small plugin to compile documents into PDFs using Pandoc. It uses vim.notify to display the compilation status.

## Installation

Using Lazy:

```lua
{
  'kaymmm/nvim-pandoc-pdf',
  -- ft={[optional, whatever filetypes you want, e.g., `{'markdown', 'html'}`]
}
```

Feel free to set up notifications to your liking.

## Usage

`:Pandoc <args>`

<args> is a space delimited list of any command line arguments you'd like to pass, such as a defaults file or pdf engine.

It automatically includes the current buffer as the input and [buffername].pdf as the output

Example:

Current buffer: `hello_kitty.md`

`:Pandoc -dmy_wonderful_default --pdf-engine=lualatex`

Output: `hello_kitty.pdf`

## License

GPLv3; see LICENSE
