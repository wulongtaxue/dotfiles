
syntax clear

"case insensitive
syntax case ignore

"syntax keyword logLevelTag V D I W E

"syntax match logLevel /.*\(V\|D\|I\|W\|E\)/

syntax match logTag / V[ /]\([^:]*\):/ contained

syntax match logV /.* V[ /].*/ contains=logTag
syntax match logD /.* D[ /].*/
syntax match logI /.* I[ /].*/
syntax match logW /.* W[ /].*/
syntax match logE /^.* E[ /].*$/






"highlight link logLevelTag keyword
"highlight link logLevel  Statement

hi logTag ctermfg=White
hi logV ctermfg=Black guifg=White
hi logD ctermfg=DarkBlue guifg=DarkBlue
hi logI ctermfg=DarkGreen guifg=DarkGreen
hi LogW ctermfg=DarkYellow guifg=DarkYellow
hi logE ctermfg=DarkRed guifg=DarkRed
