; AHMET ONUR AKCAY 151816045

; data segmentinde degiskenleri tanimlayip ekrana mesajlari yazdirdik.
data segment       
    yeni_satir db 13, 10, "$"
    
    oyun_cekmek db "_|_|_", 13, 10
              db "_|_|_", 13, 10
              db "_|_|_", 13, 10, "$"    
                  
    oyun_pointer db 9 DUP(?)  
    
    kazanma_bayragi db 0 
    oyuncu db "0$" 
    
    oyunbitti_mesaji db "TicTacToe Oyunu", 13, 10, "$"    
    oyunbaslama_mesaji db "AHMET ONUR AKCAY 151816045", 13, 10, "$"
    oyuncu_mesaji db "OYUNCU $"   
    kazanma_mesaji db " KAZANDI!$"   
    pozisyon_mesaji db "HARF POZISYONUNU GIRINIZ: $"
ends
; stack segmentinde stack'imizi tanimladik. 
stack segment
    dw   128  dup(?)
ends         
; es segmentini tanimladik
extra segment
    
ends

code segment
basla:
    ; Segment kaydedicilerinin atanmasi
    mov     ax, data
    mov     ds, ax
    mov     ax, extra
    mov     es, ax

    ; Oyunun baslamasi   
    call    set_oyun_pointer    
            
ana_dongu:
    ; Ekranin temizlenmesi 
    call    clear_screen   
    ; dx'e oyun baslama mesajinin yuklenmesi ve yazdirilmasi
    lea     dx, oyunbaslama_mesaji 
    call    print
    ; dx'e yeni satirin yuklenmesi ve yazdirilmasi
    lea     dx, yeni_satir
    call    print                      
    ; Oyuncu sayisinin, sirasinin dx kaydedicisine yuklenmesi ve yazdirilmasi
    lea     dx, oyuncu_mesaji
    call    print
    lea     dx, oyuncu
    call    print  
    
    lea     dx, yeni_satir
    call    print    
    ; oyuncu cekmek
    lea     dx, oyun_cekmek
    call    print    
    
    lea     dx, yeni_satir
    call    print    
    ;ekrana pozisyon mesajini yazdirmak
    lea     dx, pozisyon_mesaji    
    call    print            
                        
    ; pozisyonu okumak                   
    call    klavyeyi_oku
                       
    ; pozisyonunu hesaplamak                   
    sub     al, 49               
    mov     bh, 0
    mov     bl, al                                  
    ;matrixi guncellemek                              
    call    draw_guncelle                                    
                                                          
    call    kontrol  
                       
    ; Oyun bittiyse kontrol et                   
    cmp     kazanma_bayragi, 1  
    je      game_over  
    
    call    oyuncu_Degistir 
            
    jmp     ana_dongu   

    ; oynayan oyuncunun sirasinin degistirilmesi
oyuncu_Degistir:   
    lea     si, oyuncu    
    xor     ds:[si], 1 
    
    ret
      
    ;x ve o larin durumlarinin matrixe yazilmasi ve bunlarin kontrol edilmesi
draw_guncelle:
    mov     bl, oyun_pointer[bx]
    mov     bh, 0
    
    lea     si, oyuncu
    
    cmp     ds:[si], "0"
    je      x_durumu     
                  
    cmp     ds:[si], "1"
    je      o_durumu              
                  
    x_durumu:
    mov     cl, "x"
    jmp     guncelle

    o_durumu:          
    mov     cl, "o"  
    jmp     guncelle    
          
    guncelle:         
    mov     ds:[bx], cl
      
    ret 
       
    ; satir kontrolu, pointer'in nerde oldugunun kontrolu   
kontrol:
    call    satir_kontrol
    ret     
       
       
satir_kontrol:
    mov     cx, 0
    
    satir_kontrol_loop:     
    cmp     cx, 0
    je      ilk_satir
    
    cmp     cx, 1
    je      ikinci_satir
    
    cmp     cx, 2
    je      ucuncu_satir  
    
    call    sutun_kontrol
    ret    
        
    ilk_satir:    
    mov     si, 0   
    jmp     do_satir_kontrol   

    ikinci_satir:    
    mov     si, 3
    jmp     do_satir_kontrol
    
    ucuncu_satir:    
    mov     si, 6
    jmp     do_satir_kontrol        

    do_satir_kontrol:
    inc     cx
  
    mov     bh, 0
    mov     bl, oyun_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      satir_kontrol_loop
    
    inc     si
    mov     bl, oyun_pointer[si]    
    cmp     al, ds:[bx]
    jne     satir_kontrol_loop 
      
    inc     si
    mov     bl, oyun_pointer[si]  
    cmp     al, ds:[bx]
    jne     satir_kontrol_loop
                 
                         
    mov     kazanma_bayragi, 1
    ret         
       
       
    ; sutun kontrolu   
sutun_kontrol:
    mov     cx, 0
    
    sutun_kontrol_loop:     
    cmp     cx, 0
    je      ilk_sutun
    
    cmp     cx, 1
    je      ikinci_sutun
    
    cmp     cx, 2
    je      ucuncu_sutun  
    
    call    kontrol_diagonal
    ret    
        
    ilk_sutun:    
    mov     si, 0   
    jmp     do_sutun_kontrol   

    ikinci_sutun:    
    mov     si, 1
    jmp     do_sutun_kontrol
    
    ucuncu_sutun:    
    mov     si, 2
    jmp     do_sutun_kontrol        

    do_sutun_kontrol:
    inc     cx
  
    mov     bh, 0
    mov     bl, oyun_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      sutun_kontrol_loop
    
    add     si, 3
    mov     bl, oyun_pointer[si]    
    cmp     al, ds:[bx]
    jne     sutun_kontrol_loop 
      
    add     si, 3
    mov     bl, oyun_pointer[si]  
    cmp     al, ds:[bx]
    jne     sutun_kontrol_loop
                 
    ; kazanma bayraginin kontrolu                     
    mov     kazanma_bayragi, 1
    ret        

     ;matrix kontrolu
kontrol_diagonal:
    mov     cx, 0
    
    kontrol_diagonal_loop:     
    cmp     cx, 0
    je      ilk_diagonal
    
    cmp     cx, 1
    je      ikinci_diagonal                         
    
    ret    
        
    ilk_diagonal:    
    mov     si, 0                
    mov     dx, 4 
    jmp     do_kontrol_diagonal   

    ikinci_diagonal:    
    mov     si, 2
    mov     dx, 2
    jmp     do_kontrol_diagonal       

    do_kontrol_diagonal:
    inc     cx
  
    mov     bh, 0
    mov     bl, oyun_pointer[si]
    mov     al, ds:[bx]
    cmp     al, "_"
    je      kontrol_diagonal_loop
    
    add     si, dx
    mov     bl, oyun_pointer[si]    
    cmp     al, ds:[bx]
    jne     kontrol_diagonal_loop 
      
    add     si, dx
    mov     bl, oyun_pointer[si]  
    cmp     al, ds:[bx]
    jne     kontrol_diagonal_loop
                 
                         
    mov     kazanma_bayragi, 1
    ret  
           
     ; oyun bittiyse sonuclari ekrana yazmak.
game_over:        
    call    clear_screen   
    
    lea     dx, oyunbaslama_mesaji 
    call    print
    
    lea     dx, yeni_satir
    call    print                          
    
    lea     dx, oyun_cekmek
    call    print    
    
    lea     dx, yeni_satir
    call    print

    lea     dx, oyunbitti_mesaji
    call    print  
    
    lea     dx, oyuncu_mesaji
    call    print
    
    lea     dx, oyuncu
    call    print
    
    lea     dx, kazanma_mesaji
    call    print 

    jmp     bitis    
  
    ; oyun isaretcisini ayarlamak 
set_oyun_pointer:
    lea     si, oyun_cekmek
    lea     bx, oyun_pointer          
              
    mov     cx, 9   
    
    loop_1:
    cmp     cx, 6
    je      add_1                
    
    cmp     cx, 3
    je      add_1
    
    jmp     add_2 
    
    add_1:
    add     si, 1
    jmp     add_2     
      
    add_2:                                
    mov     ds:[bx], si 
    add     si, 2
                        
    inc     bx               
    loop    loop_1 
 
    ret  
         
       
print:      ; dx'i yaz  
    mov     ah, 9
    int     21h   
    
    ret 
    

clear_screen:       ; video modunu al ve ayarla
    mov     ah, 0fh
    int     10h   
    
    mov     ah, 0
    int     10h
    
    ret
       
    
klavyeyi_oku:  ; Klavyeyi oku ve ah'deki icerige don
    mov     ah, 1       
    int     21h  
    
    ret      
      
      
bitis:
    jmp     bitis         
      
code ends

end basla
