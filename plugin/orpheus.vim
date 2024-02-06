let s:height_factor = 3

function! s:getwindowsize(winnr)
  let ret = winwidth(a:winnr)
  let ret = ret * winheight(a:winnr) * s:height_factor
  return ret
endfunction

function! s:getlargestwindow()
  let ret = 0
  let largestsize = 0
  for winnr in range(1, winnr('$'))
    let currentsize = s:getwindowsize(winnr)
    if currentsize > largestsize
      let ret = winnr
      let largestsize = currentsize
    endif
  endfor
  return ret
endfunction

function! s:addonewindow()
  let winnr = s:getlargestwindow()
  execute winnr . 'wincmd w'
  if winheight(winnr) * s:height_factor > winwidth(winnr)
    wincmd s
  else
    wincmd v
  endif
  " wincmd =
endfunction

function! s:spreadbuffers(buffers)
  if len(a:buffers) == 0
    return
  endif
  if winnr('$') > 1
    enew
    only
  endif
  for i in range(2, len(a:buffers))
    call s:addonewindow()
  endfor
  let winnr = 0
  for bufnr in a:buffers
    let winnr = winnr + 1
    execute winnr . 'wincmd w'
    execute 'b' . bufnr
  endfor
endfunction

function! s:getlistedbuffers()
  let buffers = range(1, bufnr('$'))
  let buffers = filter(buffers, 'bufexists(v:val)')
  let buffers = filter(buffers, 'getbufinfo(v:val)[0].listed')
  return buffers
endfunction

function! s:spreadlistedbuffers()
  let buffers = s:getlistedbuffers()
  call s:spreadbuffers(buffers)
  1wincmd w
endfunction

" Grid All Listed
command! Grid call s:spreadlistedbuffers()

function! s:getchangedbuffers()
  let buffers = range(1, bufnr('$'))
  let buffers = filter(buffers, 'bufexists(v:val)')
  let buffers = filter(buffers, 'getbufinfo(v:val)[0].changed')
  return buffers
endfunction

function! s:spreadchangedbuffers()
  let buffers = s:getchangedbuffers()
  call s:spreadbuffers(buffers)
  1wincmd w
endfunction

" Near Death Experience
command! Nde call s:spreadchangedbuffers()

function! s:quitall(bang)
  " echom 'bang: ' . a:bang
  if a:bang == '!'
    qall!
  endif
  let buffers = s:getchangedbuffers()
  if len(buffers) == 0
    quitall
  else
    call s:spreadchangedbuffers()
  endif
endfunction

command! -bang Qall call s:quitall('<bang>')
