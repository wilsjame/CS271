 TITLE Progamming Assignment #1     (Project01.asm)

; Author: James Wilson (wilsjame)
; CS 271 / Assignment#1                 Date: 1/17/2017
; Description: This program will introduce the programmer and program title, 
; display instructions for the user, have the user enter to two numbers,
; calculate the sum, difference, product, (integer) quotient and remainder of the numbers,
; and display a terminating message. 

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

intro		BYTE	"		Elementary Arithmetic		by James Wilson",0
instr_1		BYTE	"Enter 2 numbers, and I'll show you the sum, difference,",0 
instr_2		BYTE	"product, quotient, and remainder.",0 
prompt_1	BYTE	"First number: ",0
prompt_2	BYTE	"Second number: ",0
firstNum	DWORD	?
secondNum	DWORD	?
sum			DWORD	?
difference	DWORD	?
product		DWORD	?
quotient	DWORD	?
remainder	DWORD	?
equal		BYTE	" = ",0
plus		BYTE	" + ",0
minus		BYTE	" - ",0
multiply	BYTE	" * ",0
divide		BYTE	" / ",0
prompt_3 	BYTE	" remainder ",0 
goodbye		BYTE	"Impressed? Bye!",0 

.code
main PROC

;introduce programmer 
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf

;display instructions for user
	mov		edx, OFFSET	instr_1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instr_2
	call	WriteString
	call	CrLf
	call	CrLf

;get user inputs for two numbers
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		firstNum, eax
	
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	mov		secondNum, eax
	call	CrLf

;calculate and display sum
	mov		eax, firstNum
	mov		edx, OFFSET firstNum
	call	WriteDec

	mov		edx, OFFSET plus		;+
	call	WriteString

	mov		eax, secondNum
	mov		edx, OFFSET	secondNum
	call	WriteDec

	mov		edx, OFFSET equal		;=
	call	WriteString

	;sum calculation
	mov		eax, firstNum
	add		eax, secondNum
	mov		sum, eax
	mov		edx, OFFSET sum
	call	WriteDec
	call	CrLf
	
;calculate and display difference
	mov		eax, firstNum
	mov		edx, OFFSET firstNum
	call	WriteDec

	mov		edx, OFFSET minus		;-
	call	WriteString

	mov		eax, secondNum
	mov		edx, OFFSET	secondNum
	call	WriteDec

	mov		edx, OFFSET equal		;=
	call	WriteString

	;difference calculation
	mov		eax, firstNum
	sub		eax, secondNum
	mov		difference, eax
	mov		edx, OFFSET difference
	call	WriteDec
	call	CrLf

;calculate and display product
	mov		eax, firstNum
	mov		edx, OFFSET firstNum
	call	WriteDec

	mov		edx, OFFSET multiply	;*
	call	WriteString

	mov		eax, secondNum
	mov		edx, OFFSET	secondNum
	call	WriteDec

	mov		edx, OFFSET equal		;=
	call	WriteString

	;product calculation 
	mov		eax, firstNum
	mov		ebx, secondNum
	mul		ebx						;ebx is the operand. Multiply with whatevers in eax and stores result in eax
	mov		product, eax
	mov		edx, OFFSET product
	call	WriteDec
	call	CrLf
	
;calculate and display (integer) quotient and remainder
	mov		eax, firstNum
	mov		edx, OFFSET firstNum
	call	WriteDec

	mov		edx, OFFSET divide		;/
	call	WriteString

	mov		eax, secondNum
	mov		edx, OFFSET	secondNum
	call	WriteDec

	mov		edx, OFFSET equal		;=
	call	WriteString

	;quotient calculation 
	mov		eax, firstNum
	cdq								;convert doubleword to quadword- extends EAX (sign) into EDX
	mov		ebx, secondNum
	div		ebx
		
	;quotient is in EAX
	;remainder is in EDX
	;secondNum is still in EBX

	mov		remainder, edx
	mov		quotient, eax
	mov		edx, OFFSET quotient
	call	WriteDec

	mov		edx, OFFSET prompt_3
	call	WriteString

	mov		eax, remainder
	mov		edx, OFFSET remainder
	call	WriteDec
	call	CrLf

;display outgoing message
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
