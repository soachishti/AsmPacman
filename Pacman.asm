; 214 dots
; Game over when enemy col and row equal pacmanMov col and row
; Randomness of enemy movement
; Enemy only trigger after colliding
;   - Try to move when turn comes
; What will happen when pacman eat o

include irvine32.inc
include macros.inc
INCLUDELIB user32.lib
VK_LEFT		EQU		000000025h
VK_UP		EQU		000000026h
VK_RIGHT	EQU		000000027h
VK_DOWN		EQU		000000028h
maxCol      EQU     79
maxRow      EQU     22

GetKeyState PROTO, nVirtKey:DWORD

movement STRUCT
    up BYTE 0
    down BYTE 0
    left BYTE 0
    right BYTE 0
movement ENDS

enemyInfo STRUCT
    col     BYTE 26
    row     BYTE 9
    up      BYTE 0
    down    BYTE 0
    left    BYTE 0
    right   BYTE 1
    delay   WORD 0
    hrow     BYTE 26
    hcol     BYTE 9
enemyInfo ENDS

.data
    include data.asm
.code 
    include PacmanControl.asm
    include enemyControl.asm
    
    main PROC       
    
        call ClrScr
        mGotoxy 30, 9
        mWrite "Pacman using MASM"
        mGotoxy 30, 10
        mWrite "Developer: soachishti"
        mGotoxy 50, 20
        call WaitMsg
        call ClrScr

        call initEnemy
        call printMap
        forever:      
            call loadEnemy
            call enemyCollide
            .IF al
                jmp GameOver
            .ENDIF
            
            call keySync          ; sync keyboard
            call currentItem      ; Check for . and increase score
            
            mGotoxy col, row
            .IF specialPower == 0
                mov al,pacman     
            .ELSEIF
                mov al, 1
                DEC specialPower
            .ENDIF
            call WriteChar  ; print out pacman
    
            invoke Sleep, speed
                    
            call eraseEnemy
            
            mGotoxy col, row
            mov  al,' '     
            call WriteChar
            
            mGotoxy 60, 10
            mWrite "Score:" 
            mov eax, score
            call WriteInt

            mGotoxy 60, 11
            mWrite "Food Eaten:" 
            mov eax, foodEaten
            call Writeint
            
            .IF foodEaten == 220
                jmp YouWin
            .ENDIF
            
        jmp forever
        
        GameOver:
            call ClrScr
            mGotoxy 35, 10
            mWrite "Game Over"
            ret

        YouWin:
            call ClrScr
            mGotoxy 35, 7
            mWrite "You Win"
            
            mGotoxy 35, 10
            mWrite "Score:" 
            mov eax, score
            call WriteInt

            mGotoxy 35, 11
            mWrite "Food Eaten:" 
            mov eax, foodEaten
            call Writeint
            ret
        
        ret
    main ENDP
END main