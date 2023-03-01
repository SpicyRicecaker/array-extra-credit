INCLUDE Irvine32.inc

.data
    ARR_SIZE DWORD 5
    onedarr1 DWORD 231,192,29,44,5192
    onedarr2 DWORD 11,12,13,14,15
    onedarr3 DWORD 21,22,23,24,25
    twodarr1 DWORD OFFSET onedarr1, onedarr2, onedarr3
.code

print macro data:REQ
    local s
    .data
        s BYTE data,0
    .code
        push EDX
        mov EDX, OFFSET s
		call WriteString
        pop EDX
endm

; Receives array_size, array offset, 
; push in reverse order
ArrayDspl PROC
     push EBP
     mov EBP, ESP
     pushad
     mov ESI, [EBP+12] ; @list in ESI
     mov ECX, [EBP+8] ; Count in ECX
     prtNum:
          mov EAX, [ESI]
          call WriteDec
          call Crlf
          add ESI, 4 ; May be different, Why?
          loop  prtNum
     popad
     pop EBP
     ret 8
ArrayDspl ENDP

; A[y][x]
; Receives: array offset, array size y, array size x, index x, index y (optional)
; Return: in the address of array offset
ARRAY_OFFSET EQU [EBP+8]
ARRAY_SIZE_Y EQU [EBP+12]
ARRAY_SIZE_X EQU [EBP+16]
ARRAY_X EQU [EBP+20]
ARRAY_Y EQU [EBP+24]
procArrGet proc
    ; Dump stack
	; push 10
	; call PrintStack

    ; set ebp to esp
    push EBP
    mov EBP, ESP
    ; push all general purpose registers onto the stack
    pushad

    ; is number of rows 1?
    mov EAX, ARRAY_SIZE_Y
    cmp EAX, 1
    je one_dimensional

    two_dimensional:
        ; save the offset of the array into esi
        mov ESI, ARRAY_OFFSET

        ; bump our row ptr
        mov EAX, ARRAY_Y
        mov EBX, 4
        mul EBX

        ; move the offset of the one dimensional array to edx
        mov ESI, [ESI+EAX]

        ; find the x offset into this array
        mov EAX, ARRAY_X
        mov EBX, 4
        mul EBX

        ; add into the offset
        add ESI, EAX

        ; now return the variable at this address to the last variable in the entire stack
        mov EAX, [ESI]
        mov ARRAY_Y, EAX

		popad
		pop EBP

        ; dump the stack
        push 10
        call printStack

        ret 16

    one_dimensional:
        ; save the offset of the array into esi
        mov ESI, ARRAY_OFFSET

        ; finds out how much the cpu needs to offset into the array to return
        ; value stored at index
        mov EAX, ARRAY_X
        mov ECX, 4
        mul ECX

        ; store the value that the address points into the eax register
        mov EAX, [ESI+EAX]
        ; put the value of the array into the value of that array
        mov ARRAY_X, EAX

		popad
		pop EBP

        ; instructs the cpu to pop all but one variable on the stack
		ret 12
procArrGet endp

; Receives: y, x
; Return: VOID
procArrStr proc
	; prologue
	Push ebp
	Mov ebp, esp

	Pushad ;Pushing all registers in

	Popad ;popping registers

	; epilogue
	Pop esp
procArrStr endp

; Receives: x the number of values to pop from the stack
; Returns: VOID
printStack proc 
    ; because stack is decremented, we can decrement say the first 10 values of the stack
    push EBP
    mov EBP, ESP

    pushad
	print "--top of stack--"
    call crlf

    mov ECX, [EBP+8]
    mov ESI, EBP
    add ESI, 12
    start:
        mov EAX, [ESI]
        call WriteDec
        call Crlf
        add ESI, 4
        loop start

	print "--bottom of stack--"
    call Crlf
    popad

    pop EBP
    ret 4
printStack endp

Main proc
    ; index y (omitted), index x, array x, array y, offset arr
    push 3
    push ARR_SIZE
    push 1
    push OFFSET onedarr1
    call procArrGet

    pop EAX
    call WriteDec
    call Crlf

    ; index y, index x, array x, array y, offset arr
    push 1
    push 2
    push ARR_SIZE
    push 3
    push OFFSET twodarr1
    call procArrGet

    pop EAX
    call WriteDec
    call Crlf

    ; pop EAX
    ; call WriteDec

    invoke exitprocess,0
Main endp
End main
