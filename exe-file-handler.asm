; Load/start/remove a demo as an exe file
; Important: dos.library is expected as opened and its base is already stored

exec_base			EQU $0004
LIB_VERSION                     EQU 20	;Offset in library base
_LVOCacheClearU			EQU -636
OS2_VERSION                     EQU 37	;OS2.04

FirstCode			EQU 4	;Offset in SegList structure
_LVOLoadSeg			EQU -150
_LVOUnloadSeg			EQU -156

; ** AmigaDOS command return codes **
RETURN_OK			EQU 0
RETURN_FAIL			EQU 20

ASCII_LINE_FEED			EQU 10


start
	lea     demofile_path(pc),a0
	move.l  a0,d1
	move.l  dos_base(pc),a6
	jsr     _LVOLoadSeg(a6)
	lea	demofile_seglist(pc),a0
	move.l  d0,(a0)
	bne.s   check_os_version
	moveq	#RETURN_FAIL,d0
	bra.s	exit
	CNOP 0,4
check_os_version
	move.l  exec_base.w,a6
	cmp.w   #OS2_VERSION,LIB_VERSION(a6) ;OS2.04 or better
	blo.s	load_demo
	jsr	_LVOCacheClearU(a6)	;Mandatory on 680x0 systems

load_demo
	move.l	demofile_seglist(pc),a3 ;Pointer to SegList structure in a3 is not mandatory, but some demos expect it
	add.l	a3,a3			;Get BCPL pointer
	add.l	a3,a3

; ** Some demos expect these values in d0/a0 or there will be a guru meditation **
	lea	shell_command_line(pc),a0 ;Pointer to line feed command line string
	moveq	#shell_command_line_end-shell_command_line,d0 ;Length = 1 character

 	movem.l d2-d7/a2-a6,-(a7)
	jsr	FirstCode(a3)		;Execute demo
        movem.l (a7)+,d2-d7/a2-a6

unload_demo
	move.l	demofile_seglist(pc),d1
	move.l	dos_base(pc),a6
	jsr	_LVOUnLoadSeg
	moveq	#RETURN_OK,d0
exit
	rts


; ** Variables **
	CNOP 0,4
dos_base			DC.L 0

demofile_seglist		DC.L 0
demofile_path			DC.B "exampledemo.exe",0
	EVEN
shell_command_line		DC.B ASCII_LINE_FEED ;pseudo Shell commandline
shell_command_line_end
	DC.B 0

	END