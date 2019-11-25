; multi-segment executable file template.

data segment
    ; add your data here!    
    a1 db 1 dup(0),  
    b1 db 1 dup(0)
    c1 db 1 dup(0)  
    
    pkey db "press any key...$"   
    x    db "x= $"  
    y    db "y= $" 
    space db "   $"
   
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    CALL ReadNUM
    mov a1 , dl
    
    mov dl , 10 
    mov ah , 2 
    int 21h 
    
    CALL ReadNUM
    mov b1 , dl   
    
    mov dl , 10 
    mov ah , 2 
    int 21h
               
    CALL ReadNUM
    mov c1 , dl
   
    mov dl , 10 
    mov ah , 2 
    int 21h
   
    lea bx , a1 
    mov al , [bx]
    cmp al , 0
    jne  roots
    
    lea bx , c1 
    mov bl , [bx]   
    CALL PrintNUM 
    
    jmp skip
    ; (-b+- sqrt(b*b-4ac)) / 2    
    
    roots:
    lea bx , b1 
    mov al , [bx]   
    imul al 
    push ax 
     
    lea bx , a1  
    mov al , [bx]
    lea bx , c1
    mov cl , [bx]     
    imul cl            ; a*c in ax
    
    mov cx , 3 
    mov dx , ax
    l2:    
    add ax , dx        ; ac+ac+ac+ac = 4ac
    loop l2
    
    pop dx        ; b*b
    
    sub dx , ax  ; b*b - 4ac 
    
    ; check if < 0 
    cmp  dx , 0 
    jl   skip     
    mov cx , 0
    je get     
    
    ;sqrt
    mov ax , dx
    mov cx , 0000h
    mov bx , 0FFFFH 
   
    L3:           
    ADD bx , 2
    inc cx
    sub ax , bx  
    cmp ax , 0 
    JGE L3 
    ;       
    
    get:
    lea bx , b1 
    mov al , [bx]
    NEG al         ; -b 
    mov ch , al
    add al , cl    ; -b+sqrt
    cbw       
    lea bx , a1 
    mov bl , [bx]
    add bl , bl      
    idiv bl ; result in al  -b+sqrt/(2a)  
       
    mov bh , bl 
    mov bl , al
    
    mov dl , 10 
    mov ah , 2 
    int 21h
     
    
    CALL PrintNUM   
     
     ; second root 
    NEG cl 
    add cl , ch 
    mov al , cl
    CBW
    idiv bh     
    
    mov bl , al 
    CALL PrintNUM  
         
    skip:    
    
    
    mov ax, 13h ; here select which mode you want
    int 10h      ; this calls EGA/VGA/VESA BIOS
    ; top horizontal line (house)
    mov cx,0 ;start line at column=130 and
    mov dx,100 ;row=75
    hseT: mov ah,0ch ;ah=0ch to draw a line
    mov al,07h ;pixels=light grey
    int 10h ;invoke the interrupt to draw the
    
    inc cx ;increment the horizontal position
    cmp cx,320 ;draw line until column=216
    jnz hseT

    ; left vertical line
    mov cx, 160
    mov dx,0
    hseL: mov ah,0ch
    mov al,07h
    int 10h
    inc dx
    cmp dx,200
    jnz hseL
                  
    ; function              
    mov cl , 0F6H    
    mov ch , 0
    points:
    
    mov al , cl 
    imul al 
    lea bx , a1 
    mov bl , [bx]  
    imul bl 
    mov dx , ax 
    
    mov al , cl 
    lea bx , b1 
    mov bl , [bx]
    imul bl    
    cbw
    add dx , ax 
    
    lea bx , c1 
    add dl , [bx]  
    mov al , dl 
    cbw 
    mov dx , ax
    NEG dx 
    mov bl , cl 
    mov al , cl 
    cbw 
    mov cx , ax 
    add cx , 160
    add dx ,  100
    
    cmp cx , 0 
    jl skipDrawing
    cmp cx , 300
    jg skipDrawing 
    
    cmp dx , 0 
    jl skipDrawing
    cmp dx , 200
    jg skipDrawing
     
    mov ah,0ch 
    mov al,07h 
    int 10h 
    
    skipDrawing:
    mov cl , bl 
    inc cl
    cmp cl , 0BH
    jNE points
    
    ;mov ax, 3h 
    ;int 10h 
    
    
    ; moouuuse
    mov ax, 0
    int 33h
    
    
    ok:
    
    ; display mouse cursor:
    mov ax, 1
    int 33h
    
    check_mouse_buttons:
    mov ax, 3
    int 33h
    ; cx = x , dx = y 
    
    print_xy: 
    push dx 
    lea dx , x 
    mov ah , 9
    int 21h  
    
    mov ax, cx 
    shr ax , 1 
    
    cmp ax , 0 
    jne printAX1
    mov dl ,'0'
    mov ah , 2 
    int 21h 
    jmp printAX2
    printAX1:
    call print_ax 
    
    printAX2:
    lea dx , space
    mov ah , 9 
    int 21h 
    
    mov dl , 10
    mov ah , 2 
    int 21h
    
    mov dl , 13
    mov ah , 2 
    int 21h
    
    lea dx , y 
    mov ah , 9
    int 21h 
    
    pop dx 
    mov ax, dx  
     
    cmp ax , 0 
    jne printAX3
    mov dl ,'0'
    mov ah , 2 
    int 21h 
    jmp finish 
    
    printAX3:
    call print_ax 
    
    finish: 
    lea dx , space
    mov ah , 9 
    int 21h 
   
    mov cx , 0 
    mov dx , 0 
    mov ah , 2
    int 10h 
  
   
    jmp check_mouse_buttons

   
    
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends


ReadNUM PROC 
    mov cx , 4  
    xor dl , dl 
    XOR dh , dh
    cld
    l1:
    mov ah , 1 
    int 21h 
    cmp al , 13
    JE cont     
    cmp al , '-'
    JNE  READ
    mov dh , 1
    jmp lop 
    READ:
    mov bl , al     
    sub bl , 30h  
    mov al , dl
    mov bh , 10 
    mul bh     
    mov dl , al 
    add dl , bl  
    lop:
    loop l1 
    
    cont:
    
    cmp dh , 1 
    JNE cont1
    NEG dl
    cont1:
 RET 
 ReadNUM ENDP 



PrintNUM PROC     
    
    cmp bl , 0F6H
    JLE minusTen       
    cmp bl  , 0AH
    JGE ten
    cmp bl , 0 
    jnl printt
    mov dl , "-"
    mov ah , 2 
    int 21h 
    NEG bl 
    
    printt: 
    add bl , 30h 
    mov dl , bl
    mov ah , 2   
    int 21h 
    skip2:
    JMP ennd 
    
    
    minusTen:   
    NEG bl 
    mov dl , "-"
    mov ah , 2 
    int 21h 
    
    ten:
    ; Display the count on display
    ; 1- display the count of tens 
    
    mov al, bl
    mov ah, 0
    mov dl, 10
    div dl
    
    mov dl, al
    add dl, 30H
    
    mov bl, ah
    mov ah, 2
    int 21h
    
    ; now display he count of ones
    mov dl, bl
    add dl, 30h
    int 21h
    jmp   skip2  
    
 
          
    ennd: 
    mov dl , " " 
    mov ah , 2 
    int 21h 
     
    RET
 PrintNUM ENDP
                    
  print_ax proc         
      
    ;initilize count 
    mov cx,0 
    mov dx,0   
    
    
    
    label1: 
        ; if ax is zero 
        cmp ax,0 
        je print1       
          
        ;initilize bx to 10 
        mov bx,10         
          
        ; extract the last digit 
        div bx                   
          
        ;push it in the stack 
        push dx               
          
        ;increment the count 
        inc cx               
          
        ;set dx to 0  
        xor dx,dx 
        jmp label1 
    print1: 
        ;check if count  
        ;is greater than zero 
        cmp cx,0 
        je exit
          
        ;pop the top of stack 
        pop dx 
          
        ;add 48 so that it  
        ;represents the ASCII 
        ;value of digits 
        add dx,48 
          
        ;interuppt to print a 
        ;character 
        mov ah,02h 
        int 21h 
          
        ;decrease the count 
        dec cx 
        jmp print1 
exit: 
ret 
print_ax ENDP

    
end start ; set entry point and stop the assembler.  
