; multi-segment executable file template.

data segment
    ; add your data here!    
    a1 db 1 dup(0),  
    b1 db 1 dup(0)
    c1 db 1 dup(0)  
    
    pkey  db "press any key...$"       
    text1 db "Hello there! This program should draw a quadratic equation of form ax^2 + bx + c on the graphics mode, before moving to the graphics mode it will show the equation roots,if they weren't shown then there is no roots, if one appears the equation is linear and a = 0 $" 
    text2 db  13 , 10 , "Press any key to switch to graphic mode $"
    num1  db  13 , 10 , "Enter the value of a ; range[-1:1] $" 
    num2  db  13 , 10 , "Enter the value of b ; range[-10:10] $"
    num3  db  13 , 10 ,  "Enter the value of c ; range[-100:100] $"
    root1 db  13 , 10 , "The only root is: $"
    twoRoots db    13 , 10 , "The 2 root are: $" 
    x     db  "x= $"  
    y     db  "y= $" 
    space db  "   $"
   
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
    
    ; program explanation
    lea dx , text1
    mov ah, 9
    int 21h
    
    ; a is taken here
    lea dx , num1
    mov ah, 9
    int 21h    
    
    CALL ReadNUM
    mov a1 , dl  
    
    mov dl , 10 
    mov ah , 2 
    int 21h 
    
    ; b is taken here
    lea dx , num2
    mov ah, 9
    int 21h 
    
    CALL ReadNUM
    mov b1 , dl   
    
    mov dl , 10 
    mov ah , 2 
    int 21h
    
    ; c is taken here
    lea dx , num3
    mov ah, 9
    int 21h 
              
    CALL ReadNUM
    mov c1 , dl
   
    mov dl , 10 
    mov ah , 2 
    int 21h
    
    ; check for a= 0 then it's linear equation
    lea bx , a1 
    mov al , [bx]
    cmp al , 0
    jne  roots
    
    lea bx , c1 
    mov al , [bx] 
    lea bx , b1   
    mov bl , [bx]  
    cmp bl , 0 
    je skip
    
    NEG al 
    cbw    
    idiv bl 
    mov bl , al 
    
    lea dx , root1 
    mov ah , 9 
    int 21h 
    
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
        imul cl              ; a*c in ax
        
        mov cx , 3 
        mov dx , ax
        l2:    
        add ax , dx          ; ac+ac+ac+ac = 4ac
        loop l2
        
        pop dx               ; b*b
        
        sub dx , ax          ; b*b - 4ac 
        
        ; check if < 0 , then there is no roots ,
        ; if = 0 then only one root twice but no need for sqrt 
        cmp  dx , 0 
        jl   skip     
        mov cx , 0
        je get     
        
        lea dx , twoRoots
        mov ah, 9
        int 21h 
                
                
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
        ; now we will begin with the graphics mode 
        
        lea dx , text2
        mov ah , 9 
        int 21h 
        
        mov ah , 1 
        int 21h
         
        
        mov ax, 13h 
        int 10h      
        ; x axis 
        mov cx,0    ;  column = 0 
        mov dx,100  ;  row= 100
     XAxis: 
        mov ah,0ch 
        mov al,07h 
        int 10h

        inc cx 
        cmp cx,320
        jnz XAxis
    
        ; y axis 
        mov cx, 160  ; column = 160 
        mov dx,0     ; row = 0 
     YAxis:
        mov ah,0ch
        mov al,07h
        int 10h
        inc dx
        cmp dx,200
        jnz YAxis
                      
        ; drawing the function              
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

    
    ; moouuuse
       mov ax, 0
       int 33h

    
    ; display mouse cursor:
       mov ax, 1
       int 33h
    
    Mouse:
        mov ax, 3
        int 33h
        ; cx = x , dx = y 
        
        push dx 
        lea dx , x 
        mov ah , 9
        int 21h  
        
        mov ax, cx 
        shr ax , 1 
        
        cmp ax , 0 
        jne printAX1
        
        ; print 0 alone to avoid empty x and y 
        mov dl ,'0'
        mov ah , 2 
        int 21h 
        jmp printAX2   
        
        printAX1:
            call PrintXY 
         
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
             call PrintXY 
        
        finish: 
            lea dx , space
            mov ah , 9 
            int 21h 
            
            ; to keep printing x and y on the first 2 rows
            mov cx , 0 
            mov dx , 0 
            mov ah , 2
            int 10h 
      
       
    jmp Mouse:

   
    
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
    mov dl , 0 
    mov dh , dl
   ; cld  
    
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
    
    ; check if it's less or equal -10 or greater or equal 10 to print it alone 
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
    
        mov al, bl
        mov ah, 0
        mov dl, 10
        div dl
        
        mov dl, al
        add dl, 30H
        
        mov bl, ah
        mov ah, 2
        int 21h
        
    
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
                    
 PrintXY proc         
      
    mov cx,0 
    mov dx,0   
    
    
    
    label1: 
 
        cmp ax,0 
        je print1       
        mov bx,10         
        div bx                   
        push dx               
        inc cx               
        xor dx,dx 
        jmp label1  
        
    print1: 
       
        cmp cx,0 
        je exit
         
        pop dx 
         
        add dx,30h 
        mov ah,02h 
        int 21h 
        dec cx 
        jmp print1 
exit: 
ret 
PrintXY ENDP

    
end start ; set entry point and stop the assembler.  
