; ** Load/start/remove a demo as an exe file
; ** dos.library is expected as opened
; ** Official includes macro for dos-library LoadSeg()/UnLoadSeg() used

  CNOP 0,4
load_demo
  lea     demo_filepath(pc),a0
  move.l  a0,d1
  CALLDOS LoadSeg
  move.l  d0,demofile_seglist
  beq.s   load_demo_error
check_os_version
  move.l  ExecBase.w,a6
  cmp.w   #37,LIB_VERSION(a6) ; OS2.0 or better
  blo.s   no_cache
  CALLEXEC CacheClearU
no_cache
  moveq   #0,d0
  rts
  CNOP 0,4
load_demo_error
  moveq   #-1,d0
  rts


  CNOP 0,4
start_demo
  move.l  demofile_seglist(pc),a3 ;Pointer to seglist structure in a3 is not mandatory, but some demos expect it
  add.l   a3,a3              ;BCPL pointer
  add.l   a3,a3
; ** Not mandatory. Some demos expect it. Oherwise -> guru meditation
  lea     shell_cmd_line(pc),a0 ;Pointer to empty command line-String
  moveq   #1,d0              ;Length = 1 character (line feed)
; **
  jmp     4(a3)              ;Execute demo


  CNOP 0,4
unload_demo
  move.l  demofile_seglist(pc),d1
  beq.s   no_unload_demo
  CALLDOS UnLoadSeg
no_unload_demo 
  rts


demofile_seglist DC.L 0

demo_filepath    DC.B "exampledemo.exe",0

shell_cmd_line   DC.B 10,0 ;pseudo Shell commandline - only line feed

  END
