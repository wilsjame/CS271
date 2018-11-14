TITLE Program Template     (Project06a.asm)

; Author: James Wilson (wilsjame)
; CS 271 / Project 6A                 Date: 15 March 2017
; Description:
; Objectives:
; -Designing, implementing, and calling low-level I/O procedures
; - Implementing and using a macro
;
; Problem Definition:
; -Create ReadVal and WriteVal procedures for unsigned integers
; -Implement macros getString and displayString
;	-OK to use Irvine's ReadString and WriteString inside macros
;	-displayString displays a string stored in a specified memory location

; -readVal invokes getString macro
;	-gets user's string of digits and converts digit string to numeric (while validating)
; -writeVal converts numeric value to a string of digits, and invokes displayString macro to produce the output
;
; -Get 10 valid integers from the user and store numberic values in an array. Display the integers, sum, and average. 
;
; Requirements:
; -Validation
;	-Read user's input as a string -> convert string to numeric form
;	-If user enters non-digits or the number is too large for 32-bit registers display error message and discard input/number
;-Conversion routines use lodsb and/or stosb operators
;-All procedure parameters must be passed on the system stack
;-Addresses of prompts, identifying strings, and other memory locations pased by address to macros
;-Used registers must be saved and restored by the called procedures and macros
;-Stack must be "cleaned up" by called procedure
;
;**EC: DESCRIPTION (attempts)
; Something amazing ... changed the color scheme to red and white. Go Blazers!

INCLUDE Irvine32.inc

MAX_SIZE	EQU	<10>					;alt constant syntax: MAX_SIZE = 10

;---------------------------------------------------
;Macro to display a prompt and read a string from the user using Irvine's ReadString
;receives: prompt (ref), varName (ref), LENGTHOF varName (val) 
;returns: n/a 
;preconditions: aovid passing ecx and edx as arguments
;registers changed: ecx, edx
;---------------------------------------------------
mGetString		MACRO	prompt:REQ, varName:REQ, varName_size:REQ
	;save registers				
	push	edx
	push	ecx	

	mov		edx, prompt					;display prompt			
	call	WriteString
	mov		edx, varName				;point to the varName
	mov		ecx, varName_size			
	call	ReadString					;input string

	;restore registers
	pop		ecx
	pop		edx										
ENDM

;---------------------------------------------------
;Macro to display a string in a specific memory location using Irvine's WriteString
;receives: stringAddr (ref)
;returns: console output 
;preconditions: correct string is pushed
;registers changed: edx
;---------------------------------------------------
mDisplayString	MACRO	stringAddr:REQ	
	push	edx							;save edx on stack
	mov		edx, stringAddr			
	call	WriteString
	pop		edx							;restore edx from stack
ENDM

.data

titleBlock	BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10
			BYTE	"Written by: James Wilson",0
instruction BYTE	"Please provide 10 unsigned decimal integers.", 13, 10
			BYTE	"Each number needs to be small enough the fit inside a 32 bit register.", 13, 10
			BYTE	"After you have finished inputting the raw numbers I will display a list", 13, 10
			BYTE	"of integers, their sums, and their average value.", 0
prompt		BYTE	"Please enter an unsigned number: ",0
invalid		BYTE	"ERROR: You did not enter a an unsigned number or your number was too big.",0
tryAgain	BYTE	"Please try again: ",0
spaces		BYTE	"     ",0
result_1	BYTE	"You entered the following numbers: ",0
result_2	BYTE	"The sum of these numbers is: ",0
result_3	BYTE	"The average is: ",0

EC			BYTE	"**EC: Changed color scheme to output red and white. Go Blazers!",0 

muchThanks	BYTE	"Thanks for playing!",0

array		DWORD	MAX_SIZE	DUP(?)

.code
main PROC

	;introduce program
	push	OFFSET EC
	push	OFFSET titleBlock
	push	OFFSET instruction
	call	introduction

	;get valid user input for array
	push	OFFSET prompt
	push	OFFSET invalid
	push	OFFSET tryAgain
	push	LENGTHOF array
	push	OFFSET array
	call	getData

	;display the user inputted array
	push	OFFSET spaces
	push	OFFSET result_1
	push	OFFSET array
	push	LENGTHOF array
	call	displayList

	;display the sum and average of these numbers
	push	OFFSET result_2
	push	OFFSET result_3
	push	OFFSET array
	PUSH	LENGTHOF array
	call	sumAverage

	exit	; exit to operating system
main ENDP

;---------------------------------------------------
;Procedure to display the introduction and instructions
;receives: titleBlock (ref), instruction (ref)
;returns: console output 
;preconditions: parameters pushed by address (OFFSET) in correct order
;registers changed: ebp, edx
;---------------------------------------------------
introduction	PROC	USES	edx					;(+4bytes on stack) USES tells assembler to generate push and pop instructions to save and restore edx
	push	ebp							;set up stack frame (activation record) 
	mov		ebp, esp
	
	mov		edx, [ebp+16]				;get address of titleBlock in edx (extra 4bytes due to edx)
	mDisplayString	edx
	call	CrLf
	call	CrLf

	mov		edx, [ebp+12]				;get address of instruction in edx (extra 4bytes due to edx)
	mDisplayString edx
	call	CrLf

	call	CrLf
	mov		edx, [ebp+20]				;display extra credit
	mDisplayString edx
	call	CrLf
	call	CrLf

	;set color scheme
	mov		eax, white+(red*16)
	call	SetTextColor	;set to Blazers color scheme


	pop		ebp
	ret		 8
introduction	ENDP

;---------------------------------------------------
;Procedure to get valid user inputs to fill the array 
;Nested Procedures: ReadVal
;receives: prompt (ref)24, invalid (ref)20, tryAgain (ref)16, LENGTHOF array (val)12, array (ref)8
;returns: n/a
;preconditions: parameters pushed in correct order
;registers changed: ebp, esp, eax, ebx, edi
;---------------------------------------------------
getData			PROC	USES	esi ecx eax			;(+12 bytes on stack) 
	push	ebp							;set up stack frame (activation record)
	mov		ebp, esp	

	;get array and counter ready
	mov		esi, [ebp+20]				;get address of beginning of array in esi
	mov		ecx, [ebp+24]				;get LENGTHOF array in ecx. This is now the loop counter

fillArray:
	mov		eax, [ebp+36]				;get address of prompt in eax
	push	eax
	push	[ebp+32]					;address of invalid
	push	[ebp+28]					;address of tryAgain
	call	ReadVal
	pop		[esi]						;store integer in array
	add		esi, 4
	loop	fillArray
	
	pop		ebp
	ret		20
getData			ENDP

;---------------------------------------------------
;Procedure to get user input (string) by invoking mGetString macro, then if valid, converts string to numeric 
;Nested Procedures: validation
;receives: prompt (ref)16, invalid (ref)12, tryAgain (ref)8
;returns: n/a
;preconditions: parameters pushed in correct order
;registers changed: eax, ebx, ecx, esi
;---------------------------------------------------
ReadVal			PROC	USES	eax ebx				;(+8 bytes on the stack)
	LOCAL		isValid:DWORD, TempInput[15]:BYTE	;Local directive high-level substitute for ENTER

	;save registers
	push	esi							;address of beginning of array
	push	ecx							;loop counter initialized with LENGTHOF array

	mov		eax, [ebp+16]				;get address of prompt in eax
	lea		ebx, TempInput				;load address of TempInput in ebx
	
loopInput:
	mGetString	eax, ebx, LENGTHOF TempInput
	mov		ebx, [ebp+12]				;get address of invalid in ebx
	push	ebx
	lea		eax, isValid				;load address of isValid in eax
	push	eax
	lea		eax, TempInput				;load address of TempInput in eax
	push	eax
	push	LENGTHOF TempInput
	call	validation
	pop		edx							;return converted integer
	mov		[ebp+16], edx				;store converted number where prompt used to be
	mov		eax, isValid
	cmp		eax, 1						;check if isValid is true i.e. 1
	mov		eax, [ebp+12]				
	lea		ebx, TempInput				;load address of TempInput into ebx
	jne		loopInput

	pop		ecx
	pop		esi
	ret		8							;leave [ebp+16], thats where our converted number is
ReadVal			ENDP

;---------------------------------------------------
;Procedure to validate users input 
;Nested Procedures: convertNum
;receives: invalid (ref)20, isValid (ref)16, TempInput (ref)12, LENGTHOF TempInput (val)8
;returns: a valid user input
;preconditions: parameters pushed in correct order
;registers changed: eax, ebx, ecx, edx, esi, al, ebp
;---------------------------------------------------
validation		PROC	USES	esi ecx eax edx
	LOCAL		tooBig:DWORD
	
	;get TempInput array and counter ready
	mov		esi, [ebp+12]				;get address of beginning of TempInput array in edi
	mov		ecx, [ebp+8]				;get LENGTHOF TempInput in ecx. This is now the loop counter
	cld									;clear direction flag, data goes onwards 

checkString:							;check string bytes for non-digits using ascii codes
	lodsb								;load a byte from memory at ESI into AL (ESI is incremented because of direction flag set by cld)
	cmp		al, 0						;0 is ascii code for null
	je		isNull
	cmp		al, 48						;48 is ascii code for 0
	jl		notValid
	cmp		al, 57						;57 is ascii code for 9
	ja		notValid
	loop	checkString

notValid:								;sets isValid to false i.e. 0
	mov		edx, [ebp+20]				;get address of invalid in edx
	mDisplayString	edx
	call	CrLf
	mov		edx, [ebp+16]				;get address of isValid in edx
	mov		eax, 0
	mov		[edx], eax					;set isValid to false i.e. 0 
	jmp		endBlock1

isNull:									;converts string to intger it is NOT toobig
	mov		edx, [ebp+8]				;get LENGTHOF TempInput in edx
	cmp		ecx, edx					
	je		notValid					;null was entered!
	lea		eax, tooBig					;load address of tooBig in eax
	mov		edx, 0
	mov		[eax], edx					;value @ eax is 0
	push	[ebp+12]					;address of TempInput
	push	[ebp+8]						;LENGTHOF TempInput
	lea		edx, tooBig					;load address of tooBig in edx
	push	edx
	call	convertNum
	mov		edx, tooBig
	cmp		edx, 1						;check if tooBig is true i.e. 1
	je		notValid
	mov		edx, [ebp+16]				;get address of isValid in edx
	mov		eax, 1
	mov		[edx], eax					;set isValid to true i.e. 1 
	
endBlock1:
	pop		edx							;return from convertNum
	mov		[ebp+20], edx				;store converted number where invalid used to be
	ret		12							;keep [ebp+20] that is the converted number
validation		ENDP

;---------------------------------------------------
;Procedure to convert string char in an array into digits
;Nested Procedures: convertNum
;receives: TempInput (ref)16, LENGTHOF TempInput (val)12, tooBig (ref)8
;returns: converted array into digits
;preconditions: parameters pushed in correct order
;registers changed: eax, ebx, ecx, edx, esi, ebp
;---------------------------------------------------
convertNum		PROC	USES	esi ecx eax ebx edx
	LOCAL		integer:DWORD
	
	mov			esi, [ebp+16]			;get address of TempInput in edi
	mov			ecx, [ebp+12]			;get LENGTHOF TempInput in ecx
	lea			eax, integer			;load address of integer in eax

	
	xor	ebx, ebx
	mov	[eax], ebx
	xor	eax, eax
	xor	edx, eax						;clear overflow and carry flags
	cld									;clear direction flag, data goes onwards
	

loadIntegers:							;convert string bytes into integers
	lodsb								;load a byte from memory at ESI into AL (ESI is incremented because of direction flag set by cld)
	cmp			eax,0					;check for null
	je			endBlock2
	
	;find the ascii digit code
	sub			eax, 48
	mov			ebx, eax
	mov			eax, integer
	mov			edx, 10
	mul			edx
	
	;check if the digit is too large
	jc			intTooBig	
	add			eax, ebx				
	jc			intTooBig							
	mov			integer, eax
	mov			eax, 0					;reset for next digit convert process 
	loop		loadIntegers

endBlock2:
	mov			eax, integer
	mov			[ebp+16], eax			;add integer to TempInput
	jmp			endBlock3

intTooBig:
	mov			ebx, [ebp+8]			;move tooBig into ebx
	mov			eax, 1					;1 = true
	mov			[ebx], eax				;set tooBig to 1 = true
	mov			eax, 0
	mov			[ebp+16], eax			;move 0 TempInput
	
endBlock3:
	ret			8
convertNum		ENDP

;---------------------------------------------------
; Procedure to display array in its current state (10 numbers per line)
; receives: address of array, value of request (size,count), and address of the title on system stack
; returns: displays the contents of the array
; preconditions: request is initialized in the range [10, 200]
;				 and the array is filled with request number of numbers
; registers changed: eax, ebx, ecx, edx, esi, ebp, esp
;---------------------------------------------------
displayList		PROC
	push	ebp
	mov		ebp, esp				;set up stack frame

	;print the list title
	call	CrLf
	mDisplayString	[ebp+16]
	call	CrLf

	;set up other parameters
	mov		esi, [ebp+12]			;(starting) address of array in esi
	mov		ecx, [ebp+8]			;address of request (size, count) in ecx
	mov		ebx, 0					;terms per line counter

more:
	push		[esi]
	call		WriteVal
	mDisplayString	[ebp+20]		;puts spaces between lines
	add		esi, 4					;next element

	;manage terms per line
	inc		ebx
	cmp		ebx, 10
	je		newLine
	jmp		resume

newLine:
	call	CrLf
	mov		ebx, 0

resume:
	loop	more

endMore:
	pop		ebp
	ret		16						;title_1, array, request => 4, 4, 4, 4 bytes
displayList		ENDP

;---------------------------------------------------
;Procedure to display a numeric value as a string 
;Nested Procedures: convertChar
;receives: Intger (val)
;returns: none
;preconditions: parameters pushed in correct order
;registers changed: eax, ebp
;---------------------------------------------------
WriteVal		PROC	USES	eax
	LOCAL		stringToNum[11]:BYTE

	lea		eax, stringToNum		;load address of stringToNum into eax
	push	eax
	push	[ebp+8]
	call	convertChar

	lea		eax, stringToNum		;load address of stringToNum into eax
	mDisplayString	eax

	lea		eax, stringToNum
	ret		4
WriteVal		ENDP

;---------------------------------------------------
;Procedure to convert integers into string chars
;Nested Procedures: none
;receives: stringToNum (ref), integer (val)
;returns: n/a
;preconditions: parameters pushed in correct order
;registers changed: eax, ebx, ecx, ebp, edi
;---------------------------------------------------
convertChar		PROC	USES	eax ebx ecx
	LOCAL		charTemp:DWORD

	;divide integer by 10
	mov		eax, [ebp+8]
	mov		ebx, 10
	mov		ecx, 0
	cld								;clear direction flag, data goes onwards

divIntBy10:
	cdq								
	div		ebx
	push	edx						;remainder in edx
	inc		ecx
	cmp		eax, 0
	jne		divIntBy10

	mov		edi, [ebp+12]			;get address of character array in edi

charStorage:
	pop		charTemp
	mov		al,	BYTE PTR charTemp
	add		al, 48
	stosb						;	;convert to chars
	loop	charStorage

	mov		al, 0
	stosb							

	ret		8
convertChar		ENDP

;---------------------------------------------------
;Procedure calculate and display the sum and average of the array
;Nested Procedures: none
;receives: result_2 (ref), result_3 (ref), array (ref), LENGTHOF array (val)
;returns: displays sum and average on an array
;preconditions: parameters pushed in correct order
;registers changed: eax, ebx, ecx, edx, ebp, esp, esi
;---------------------------------------------------
sumAverage		PROC	USES	esi edx ecx eax ebx			;additional 20 bytes on stack
	push	ebp
	mov		ebp, esp			;set up stack frame
	
	mov		esi, [ebp+32]		;get address of array in esi
	mov		ecx, [ebp+28]		;get the size of the array in the ecx counter
	xor		eax, eax			;clear flags

sumArray:
	add	eax, [esi]
	add	esi, 4
	loop	sumArray

	;display the sum
	mov		edx, [ebp+40]		;get address of result_2 "sum" is edx
	mDisplayString	edx
	push	eax
	call	WriteVal
	call	CrLf
	
	;calculate the average of the elements in the array
	cdq							
	mov		ebx, [ebp+28]		;get lengthof array in ebx 
	div		ebx					;average is now in eax

	;display the average
	mov		edx, [ebp+36]		;get address of result_3 "average" in edx
	mDisplayString	edx
	push	eax
	call	WriteVal
	call	CrLf

	pop		ebp
	ret		16
sumAverage		ENDP

END main