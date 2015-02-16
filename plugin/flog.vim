" File:        flog.vim
" Description: Ruby cyclomatic complexity analizer
" Author:      Max Vasiliev <vim@skammer.name>
" Author:      Jelle Vandebeeck <jelle@fousa.be>
" Licence:     WTFPL
" Version:     0.0.2

if !has('signs') || !has('ruby')
  finish
endif

let s:medium_limit     = 10
let s:high_limit       = 20
let s:hide_low         = 0
let s:hide_medium      = 0

if exists("g:flog_hide_low")
  let s:hide_low = g:flog_hide_low
endif

if exists("g:flog_hide_medium")
  let s:hide_medium = g:flog_hide_medium
endif

if exists("g:flog_medium_limit")
  let s:medium_limit = g:flog_medium_limit
endif

if exists("g:flog_high_limit")
  let s:high_limit = g:flog_high_limit
endif

exec expand("rubyfile <sfile>:p:h/flog.rb")

function! ShowComplexity()
  exec "rubyfile " . findfile("plugin/show_complexity.rb", &rtp)
endfunction

function! HideComplexity()
  exec "rubyfile " . findfile("plugin/hide_complexity.rb", &rtp)
endfunction

function! FlogDisable()
  let g:flog_enable = 0
  call HideComplexity()
endfunction
command! FlogDisable call FlogDisable()

function! FlogEnable()
  let g:flog_enable = 1
  call ShowComplexity()
endfunction
command! FlogEnable call FlogEnable()

function! FlogToggle()
  if exists("g:flog_enable") && g:flog_enable
    call FlogDisable()
  else
    call FlogEnable()
  endif
endfunction
command! FlogToggle call FlogToggle()

if !exists("g:flog_enable") || g:flog_enable
  au BufReadPost,BufWritePost,FileReadPost,FileWritePost *.rb call ShowComplexity()
endif
