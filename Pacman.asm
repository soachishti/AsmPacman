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

elementInfo STRUCT
    col BYTE 26
    row BYTE 9
    up BYTE 0
    down BYTE 0
    left BYTE 0
    right BYTE 1
elementInfo ENDS

.data
    map BYTE "+---------------------------------------------------+"
        BYTE "| . . . . . .  | . . . . . . . .  .  | . . . . . .  |"
        BYTE "| . +------+ . +------+ . | . +------+ . +------+ . |"
        BYTE "| o |      | . |      | . | . |      | . |      | o |"
        BYTE "| . +------+ . +------+ . | . +------+ . +------+ . |"
        BYTE "| . . . . .  . | . . . . . . . . . . . . | . . . .  |"
        BYTE "| . -------- . | . -------+------- . | . -------- . |"
        BYTE "| . . . . .  . | . . . .  | . . . .  | . . . . . .  |"
        BYTE "+----------+ . +-------   |   -------+ . +----------+"
        BYTE "           | . |                     | . |           "
        BYTE "-----------+ . |   +-------------+   | . +-----------"
        BYTE "  . . . . . .      |    A A A    |     . . . . . . . "
        BYTE "-----------+ . |   +-------------+   | . +-----------"
        BYTE "           | . |          @          | . |           "
        BYTE "+----------+ . |   -------+-------   | . +----------+"
        BYTE "| . . . . . . . . . . . . | . . . . . . . . . . . . |"
        BYTE "| . -------+ . -------- . | . -------  . +------- . |"
        BYTE "| . . . .  | . . . . . . . . . . . . | . . . . . .  |"
        BYTE "+------- . | . | . ---------------   | . |   -------+"
        BYTE "| . . . . . . .| . . . . . . . . . . | . . . . . .  |"
        BYTE "| o -----------+------- . | . -------+----------- o |"
        BYTE "| . . . . . . . . . . . . | . . . . . . . . . . .   |"
        BYTE "+---------------------------------------------------+", 0 
        
    mapRow EQU 23
    mapCol EQU 53
    
    col     BYTE 26
    row     BYTE 13    
    score    DWORD 0    
    specialPowerLimit BYTE 100  ; total iteration counter for power
    specialPower BYTE ?       ;  
    speed DWORD 200
    pacmanMov movement <1,0,0,0>
    
    noOfEnemy EQU 4
    enemy elementInfo <26,9,0,0,0,1>    
    tmp DWORD 0
    pacman BYTE '@'
.code 

    getArrayVal PROC, x:BYTE, y:BYTE
        mov eax, 0
        mov al, x      ; ROW
        mov bl, mapCol  ; TOTAL ROW
        mul bl
        movsx bx, y
        add ax, bx      ; RESULT + COL
          
        mov al, map[eax]         
        
        .IF al != '|' && al != '-' && al != '+'  
            mov ah, 1
        .ELSE 
            mov ah, 0
        .ENDIF
        
        ret
    getArrayVal ENDP    
    
    isHurdle PROC, co:BYTE, r:BYTE, colAdd:BYTE, rowAdd:BYTE
        mov dl, co
        mov dh, r
        
        add dl, colAdd
        add dh, rowAdd
        
        invoke getArrayVal, dh, dl    ; return character in al and hurdle info in ah 
        ;.IF ah
        ;    add dl, colAdd
            ;add dh, rowAdd
        ;    invoke getArrayVal, dh, dl            
        ;.ENDIF
        ret
    isHurdle ENDP

    enemyDirection PROC, up:BYTE,down:BYTE,left:BYTE,right:BYTE
        mov al, up
        mov enemy.up, al

        mov al, down
        mov enemy.down, al

        mov al, left
        mov enemy.left, al      
        
        mov al, right
        mov enemy.right, al        
        ret
    enemyDirection ENDP
   
    loadEnemy PROC                   
           .IF enemy.left
            invoke isHurdle, enemy.col, enemy.row, -1, 0
            .IF ah
                DEC enemy.col
            .ENDIF
        .ELSEIF enemy.right
            invoke isHurdle, enemy.col, enemy.row, 1, 0
            .IF ah
                INC enemy.col
            .ENDIF
        .ELSEIF enemy.up
            invoke isHurdle, enemy.col, enemy.row, 0, -1
            .IF ah
                DEC enemy.row
            .ENDIF
        .ELSEIF enemy.down
            invoke isHurdle, enemy.col, enemy.row, 0, 1
            .IF ah
                INC enemy.row
            .ENDIF
        .ENDIF    
        
        .IF ah == 0         ; Trigger when hurdle is found
            weNeedRes:
            mov  eax,3
            call RandomRange
            call Randomize
            
            .IF eax == 0 && enemy.up == 0 && enemy.down == 0
                invoke enemyDirection, 1, 0, 0, 0
            .ELSEIF eax == 1 && enemy.down == 0  && enemy.up == 0 
                invoke enemyDirection, 0, 1, 0, 0
            .ELSEIF eax == 2 && enemy.left == 0  && enemy.right == 0 
                invoke enemyDirection, 0, 0, 1, 0
            .ELSEIF eax == 3 && enemy.right == 0 && enemy.left == 0   
                invoke enemyDirection, 0, 0, 0, 1        
            .ELSE 
                jmp weNeedRes
            .ENDIF
            
        .ENDIF
        
                    mGotoxy enemy.col, enemy.row            
            mWrite "A" 
        
        
        ret
    loadEnemy ENDP
    

    currentItem PROC
        mov eax, 0
        mov al, row      ; ROW
        mov bl, mapCol  ; TOTAL ROW
        mul bl
        movsx bx, col
        add ax, bx      ; RESULT + 
        
        mov bl, map[eax] 
        .IF bl == '.'
            mov map[eax] , ' '
            INC score
        .ELSEIF bl == 'o'
            mov map[eax] , ' '
            mov bl, specialPowerLimit
            mov specialPower, bl
        .ENDIF
        
        ret
    currentItem ENDP
    
    setDirection PROC, up:BYTE,down:BYTE,left:BYTE,right:BYTE
        mov al, up
        mov pacmanMov.up, al

        mov al, down
        mov pacmanMov.down, al

        mov al, left
        mov pacmanMov.left, al      
        
        mov al, right
        mov pacmanMov.right, al        
        
        ret
    setDirection ENDP
        
    keySync PROC
        mov ah, 0
        INVOKE GetKeyState, VK_DOWN
        .IF ah && row < mapRow - 1 || pacmanMov.down
            invoke isHurdle, col, row, 0, 1
            .IF ah
                INC row
                invoke SetDirection, 0, 1, 0, 0
            .ENDIF 
        .ENDIF

        mov ah, 0
        INVOKE GetKeyState, VK_UP
        .IF ah && row > 1 || pacmanMov.up
            invoke isHurdle, col, row, 0, -1
            .IF ah 
                DEC row
                invoke SetDirection, 1, 0, 0, 0
            .ENDIF
        .ENDIF     
        
        mov ah, 0
        INVOKE GetKeyState, VK_LEFT
        .IF ah && col > 1 || pacmanMov.left
            invoke isHurdle, col, row, -1, 0
            .IF ah 
                DEC col
                invoke SetDirection, 0, 0, 1, 0                
            .ENDIF
        .ENDIF  

        mov ah, 0
        INVOKE GetKeyState, VK_RIGHT
        .IF ah && col < mapCol || pacmanMov.right
            invoke isHurdle, col, row, 1, 0
            .IF ah
                INC col
                invoke SetDirection, 0, 0, 0, 1                
            .ENDIF

        .ENDIF     
        
        .IF col == 0
            mov ah, mapCol - 1
            mov col, ah
        .ELSEIF col == mapCol - 1
            mov col, 0
        .ENDIF
        
        ret
    keySync ENDP

    printMap PROC
        mov dl, 0   ; row
        mov dh, 0   ; col
               
        .WHILE dl != mapRow
            .WHILE dh != mapCol
                    invoke getArrayVal, dl, dh      ; return char in al                  
                    call WriteChar
                    INC dh
            .ENDW
            mov dh, 0
            call Crlf
            inc dl
        .ENDW
        ret
    printMap ENDP
    
    main PROC
        call printMap
        forever:      
            call loadEnemy
            call keySync          ; sync keyboard
            call currentItem      ; Check for . and increase score
            
            mGotoxy col, row
            .IF specialPower == 0
                mov  al,pacman     
            .ELSEIF
                mov al, 1
                DEC specialPower
            .ENDIF
            call WriteChar  ; print out pacman
    
            invoke Sleep, speed
            
            mGotoxy enemy.col, enemy.row            
            mov  al,' '     
            call WriteChar
            
            mGotoxy enemy.col, enemy.row 
            invoke getArrayVal, enemy.row, enemy.col      ; return char in al                  
            call WriteChar            
            
            mGotoxy col, row
            mov  al,' '     
            call WriteChar
            
            mGotoxy 60, 10
            mWrite "Score:" 
            mov eax, score
            call WriteInt
            
            
        jmp forever
        ret
    main ENDP
END main