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
  enew
  if len(a:buffers) == 0
    return
  endif
  only
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

function! s:spreadchangedbuffers()
  let buffers = range(1, bufnr('$'))
  let buffers = filter(buffers, 'bufexists(v:val)')
  let buffers = filter(buffers, 'getbufinfo(v:val)[0].changed')
  call s:spreadbuffers(buffers)
  1wincmd w
endfunction

command! Nde call s:spreadchangedbuffers()
