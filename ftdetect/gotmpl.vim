autocmd BufNewFile,BufRead * if search('{{.\+}}', 'nw') && &filetype == '' | setlocal filetype=gotmpl | endif
