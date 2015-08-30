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
        .IF ah
            add dl, colAdd
            ;add dh, rowAdd
           invoke getArrayVal, dh, dl            
        .ENDIF
        ret
    isHurdle ENDP 
        
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
            INC foodEaten
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