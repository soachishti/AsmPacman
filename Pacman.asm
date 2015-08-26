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
    row BYTE 8
    up BYTE 0
    down BYTE 0
    left BYTE 0
    right BYTE 0
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
    enemy elementInfo noOfEnemy DUP(<26,9,0,0,0,0>)
    
    tmp DWORD 0
    pacman BYTE '@'
.code 

    moveEnemy PROC
    
    moveEnemy ENDP

    loadEnemy PROC
        mov cx, noOfEnemy
        mov al, noOfEnemy
        mov cl, 6
        mov eax, 0
        mul bl
        mov tmp, eax
        
        .WHILE cx  
            mGotoxy enemy[eax].col, enemy[eax].row            
            mWrite "A"            
            dec cx
        .ENDW
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
    
    keySync PROC
        mov ah, 0
        INVOKE GetKeyState, VK_DOWN
        .IF ah && row < mapRow - 1 || pacmanMov.down
            mov dl, row
            add dl, 1
            invoke getArrayVal, dl, col      ; return 1 in ah if hurdle found
            .IF ah
                INC row
                invoke SetDirection, 0, 1, 0, 0
            .ENDIF 
        .ENDIF

        mov ah, 0
        INVOKE GetKeyState, VK_UP
        .IF ah && row > 1 || pacmanMov.up
            mov dl, row
            sub dl, 1
            invoke getArrayVal, dl, col      ; return 1 in ah if hurdle found
            .IF ah 
                DEC row
                invoke SetDirection, 1, 0, 0, 0
            .ENDIF
        .ENDIF     
        
        mov ah, 0
        INVOKE GetKeyState, VK_LEFT
        .IF ah && col > 1 || pacmanMov.left
            mov dl, col
            sub dl, 1
            invoke getArrayVal, row, dl      ; return 1 in ah if hurdle found
            .IF ah 
                DEC col
                invoke SetDirection, 0, 0, 1, 0                
            .ENDIF
        .ENDIF  

        mov ah, 0
        INVOKE GetKeyState, VK_RIGHT
        .IF ah && col < mapCol || pacmanMov.right
            mov dl, col
            add dl, 1
            invoke getArrayVal, row, dl      ; return 1 in ah if hurdle found
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