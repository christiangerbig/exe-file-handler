; Manually load/run/unload a demo as an exe file with the dos.library
; Important: The dos.library is expected as opened and its base is already stored
;	     No cleanup code for the dos.library included

exec_base			EQU $0004
LIB_VERSION                     EQU 20
_LVOCacheClearU			EQU -636

FirstCode			EQU 4	; offset in SegList structure
_LVOLoadSeg			EQU -150
_LVOUnloadSeg			EQU -156

; AmigaDOS command return codes
RETURN_OK			EQU 0
RETURN_FAIL			EQU 20

ASCII_LINE_FEED			EQU 10


; other code

	CNOP 0,4
load_demo
	lea     demofile_path(pc),a0
	move.l  a0,d1
	move.l  dos_base(pc),a6
	jsr     _LVOLoadSeg(a6)
	lea	demofile_seglist(pc),a0
	move.l  d0,(a0)
	bne.s   run_demo
	moveq	#RETURN_FAIL,d0
	bra.s	exit
	CNOP 0,4
run_demo

; Some demos expect these values in d0/a0 or there will be a guru meditation
	lea	shell_nop_command_line(pc),a0 ; pointer pseudo command line string
	moveq	#shell_nop_command_line_end-shell_nop_command_line,d0 ; length = 1 character

	move.l	demofile_seglist(pc),a3 ; pointer SegList structure in a3 is not mandatory, but some demos expect it
	add.l	a3,a3			; BCPL pointer
	add.l	a3,a3
 	movem.l d2-d7/a2-a6,-(a7)
	jsr	FirstCode(a3)		; execute demo
        movem.l (a7)+,d2-d7/a2-a6
	move.l	demofile_seglist(pc),d1
	move.l	dos_base(pc),a6
	jsr	_LVOUnLoadSeg(a6)
	moveq	#RETURN_OK,d0
exit
	rts


; ** Variables **
	CNOP 0,4
dos_base			DC.L 0
demofile_seglist		DC.L 0

demofile_path			DC.B "exampledemo.exe",0
	EVEN
shell_nop_command_line		DC.B ASCII_LINE_FEED
shell_nop_command_line_end	DC.B 0

	END
