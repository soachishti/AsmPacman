    eraseEnemy PROC
        mov ecx, 0
        
        mov edx, 0
        mov tmp, edx

        .WHILE ecx < noOfEnemy 
            mov al,enemy[edx].col
            mov ah,enemy[edx].row  
            
            mGotoxy al, ah 
            mov  al,' '     
            call WriteChar
                
            mov al,enemy[edx].col
            mov ah,enemy[edx].row
            mGotoxy al, ah   
                
            invoke getArrayVal, enemy[edx].row, enemy[edx].col      ; return char in al                  
            call WriteChar
           
            add edx, SIZEOF enemyInfo 
            mov tmp, edx  
   
            inc ecx
        .ENDW
        ret
    eraseEnemy ENDP  
    
    enemyDirection PROC, up:BYTE,down:BYTE,left:BYTE,right:BYTE
        mov edx, tmp    
        mov al, up
        mov enemy[edx].up, al

        mov al, down
        mov enemy[edx].down, al

        mov al, left
        mov enemy[edx].left, al      
        
        mov al, right
        mov enemy[edx].right, al        
        ret
    enemyDirection ENDP    
    
    
    enemyCollide PROC
        mov ecx, 0
        mov edx, 0
        mov tmp, edx

        .WHILE ecx < noOfEnemy 
            mov al, col
            mov ah, row
            .IF enemy[edx].col == al && enemy[edx].row == ah
                .IF specialPower != 0 
                    ; If collide with enemy and you have special power
                    add score, 100
                    
                    mov al,enemy[edx].col
                    mov ah,enemy[edx].row  
            
                    mGotoxy al, ah 
                    mov  al,' '     
                    call WriteChar
                    
                    mov enemy[edx].col, 23
                    mov enemy[edx].row, 9
                    mov enemy[edx].delay, 50
                    invoke enemyDirection, 0,0,0,1                 
                    mov al, 0
                    ret
                .ELSE
                    mov al, 1
                    ret
                .ENDIF
            .ENDIF
   
            add edx, SIZEOF enemyInfo 
            mov tmp, edx     
            inc ecx
        .ENDW
        mov al, 0 
        ret
    enemyCollide ENDP
   
    initEnemy PROC 
        mov ecx, 0
        
        mov edx, 0
        mov tmp, edx
        
        .WHILE ecx < noOfEnemy  
            call Randomize
            mov  eax,1
            call RandomRange
            
            .IF eax == 0
                invoke enemyDirection, 0,0,1,0
            .ELSE
                invoke enemyDirection, 0,0,0,1
            .ENDIF
            
            mov edx, tmp
            
            mov  eax,30
            call RandomRange
            mov enemy[edx].delay, ax
            
            add edx, SIZEOF enemyInfo 
            mov tmp, edx            
                
            inc ecx
        .ENDW
        ret
    initEnemy ENDP
   
    loadEnemy PROC                   
        mov ecx, 0
        
        mov edx, 0
        mov tmp, edx
        
        .WHILE ecx < noOfEnemy        
            .IF enemy[edx].delay != 0
                DEC enemy[edx].delay
            .ELSE            
                .IF enemy[edx].left
                    invoke isHurdle, enemy[edx].col, enemy[edx].row, -1, 0
                    .IF ah
                        mov edx, tmp
                        DEC enemy[edx].col
                    .ENDIF
                .ELSEIF enemy[edx].right
                    invoke isHurdle, enemy[edx].col, enemy[edx].row, 1, 0
                    .IF ah
                        mov edx, tmp                     
                        INC enemy[edx].col
                    .ENDIF
                .ELSEIF enemy[edx].up
                    invoke isHurdle, enemy[edx].col, enemy[edx].row, 0, -1
                    .IF ah
                        mov edx, tmp                     
                        DEC enemy[edx].row
                    .ENDIF
                .ELSEIF enemy[edx].down
                    invoke isHurdle, enemy[edx].col, enemy[edx].row, 0, 1
                    .IF ah
                        mov edx, tmp                     
                        INC enemy[edx].row
                    .ENDIF
                .ENDIF    
                
                mov edx, tmp
                
                .IF ah == 0         ; Trigger when hurdle is found
                    call Randomize
                    mov  eax,2
                    call RandomRange
                    
                    ; UP DOWN LEFT RIGHT
                    mov edx, tmp
                    
                    .IF enemy[edx].down == 1
                        .IF eax
                            invoke enemyDirection, 0,0,1,0 
                        .ELSE
                            invoke enemyDirection, 0,0,0,1                 
                        .ENDIF
                    .ELSEIF enemy[edx].up == 1
                        .IF eax
                            invoke enemyDirection, 0,0,1,0 
                        .ELSE
                            invoke enemyDirection, 0,0,0,1                 
                        .ENDIF
                    .ELSEIF enemy[edx].right == 1
                        .IF eax
                            invoke enemyDirection, 1,0,0,0 
                        .ELSE
                            invoke enemyDirection, 0,1,0,0                 
                        .ENDIF
                    .ELSEIF enemy[edx].left == 1
                        .IF eax
                            invoke enemyDirection, 1,0,0,0 
                        .ELSE
                            invoke enemyDirection, 0,1,0,0                 
                        .ENDIF
                    .ENDIF
                   
                .ENDIF
            .ENDIF
            
            mov al, enemy[edx].col
            mov ah, enemy[edx].row
                
            mGotoxy al, ah                            
            .IF specialPower == 0
                mWrite "E" 
            .ELSE    
                mWrite "e" 
            .ENDIF
            
                                        
            add edx, SIZEOF enemyInfo 
            mov tmp, edx            
                
            inc ecx
        .ENDW    
        
        ret
    loadEnemy ENDP