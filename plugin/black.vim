" Author: Łukasz Langa
" Created: Mon Mar 26 23:27:53 2018 -0700
" Requires: Vim Ver7.0+
" Version:  1.1
"
" Documentation:
"   This plugin formats Python files.
"
" History:
"  1.0:
"    - initial version
"  1.1:
"    - restore cursor/window position after formatting


if exists("g:load_black")
   finish
endif

let g:load_black = "py1.0"
if !exists("g:black_virtualenv")
  let g:black_virtualenv = "~/.vim/black"
endif
if !exists("g:black_fast")
  let g:black_fast = 0
endif
if !exists("g:black_linelength")
  let g:black_linelength = 79
endif
if !exists("g:black_skip_string_normalization")
  let g:black_skip_string_normalization = 0
endif

python3 << endpython3
import sys
import vim
import black
import time
black.prefer_single_quotes()
black.grammar_chosen.append('py3')
def Black():
  LS = chr(10)
  start = time.time()
  fast = bool(int(vim.eval("g:black_fast")))
  line_length = int(vim.eval("g:black_linelength"))
  mode = black.FileMode.AUTO_DETECT
  if bool(int(vim.eval("g:black_skip_string_normalization"))):
    mode |= black.FileMode.NO_STRING_NORMALIZATION
  buffer_str = LS.join(vim.current.buffer) + LS
  try:
    new_buffer_str = black.format_file_contents(buffer_str, line_length=line_length, fast=fast, mode=mode)
  except black.NothingChanged:
    print(f'Already well formatted, good job. (took {time.time() - start:.4f}s)')
  except Exception as exc:
    print(exc)
  else:
    cursor = vim.current.window.cursor
    vim.current.buffer[:] = new_buffer_str.split(LS)[:-1]
    vim.current.window.cursor = cursor
    print(f'Reformatted in {time.time() - start:.4f}s.')

def BlackUpgrade():
  _initialize_black_env(upgrade=True)

def BlackVersion():
  print(f'Black, version {black.__version__} on Python {sys.version}.')

endpython3
command! RemoveWhitespace :%s/\s\+$//e
command! Black :py3 Black()
command! BlackUpgrade :py3 BlackUpgrade()
command! BlackVersion :py3 BlackVersion()
