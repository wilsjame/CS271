TITLE Program Template     (Project04.asm)

; Author: James Wilson (wilsjame)
; CS 271 / Program 4				  Date: 2/19/2017
; Description: This program calculates composite numbers.
;
;- Display programmer's name and title
;- User is instructed to enter the number of composites to display
;
;- Prompt to enter an integer in the range [1 .. 400]
;- validate the number is 1 <= n <= 400
;	-if the number is out of range prompt user to re-enter until valid
;
;- Calculate and display comopsites up to the nth composite
;	-Display 10 results per line with at least 3 spaces between 

; Implementaion notes;
;	Upper limit should be defined and used as a constant
;	This program is implemented using procedures.
;	All variables are global ... no parameter passing

INCLUDE Irvine32.inc

LOWER_LIMIT EQU <1>		;alt consant syntax: LOWER_LIMIT = 1
UPPER_LIMIT EQU	<400>

.data

intro_1		BYTE	"		Composite Numbers			by James Wilson",0
intro_2		BYTE	"Enter the number of composite numbers you would like to see",0
intro_3		BYTE	"I'll accept orders for up to 400 composites.",0
prompt_1	BYTE	"Enter the number of composites to display [1 .. 400]: ",0
valid_1		BYTE	"Out of range. Try again.",0
valid_2		BYTE	"Good choice.",0
spaces		BYTE	"   ",0
goodbye_1	BYTE	"Results certified by Euclid.	Goodbye",0

number		DWORD	?		;user input for number of composite numbers to show
divisor		DWORD	1		;use with isComposite
dividend	DWORD	3		;use with isComposite
composite	DWORD	?		;will be used as a bool
;composite	DWORD	0		;Composite number to some nth degree
lineCount	DWORD	0		;keeps track of terms per line


.code
main PROC
	call	introduction
	call	getUserData
	call	validate
	call	showComposites
			;isComposite
	call	farewell

	exit	; exit to operating system
main ENDP

;---------------------------------------------------
;Procedure to display the introduction and instructions
;receives: n/a
;returns: console output 
;preconditions: n/a
;registers changed: n/a
;---------------------------------------------------
introduction	PROC

;Display program title and programmer's name
	mov		edx, OFFSET intro_1		;edx register is no pointing to the begining of intro_1
	call	WriteString				;displays text as its stored in memory
	call	CrLf					;carry return line feed creates new line
	call	CrLf
;Display instructions
	mov		edx, OFFSET intro_2		
	call	WriteString				
	call	CrLf
	mov		edx, OFFSET intro_3		
	call	WriteString				
	call	CrLf					
	
	ret
introduction	ENDP

;---------------------------------------------------
;Procedure to get a user input
;receives: n/a
;returns: number of composites to show in eax
;preconditions: n/a
;registers changed: eax
;---------------------------------------------------
getUserData		PROC
	
	;get an integer for number
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		number, eax

	;now call validate to check if the input is valid

	ret
getUserData		ENDP

;---------------------------------------------------
;Procedure to validate if user input is in range
;receives: number of composites to show is a global variable
;returns: none (calls getUserData until input is valid)
;preconditions:
;registers changed: eax
;---------------------------------------------------
validate		PROC 

validationLoop:						;beginning of data post-test validation loop

	;compound condition (AND): (1)input greater than lower limit AND (1)less than upper limit
	cmp		eax, LOWER_LIMIT		;check condition 1 (number should still be in eax)
	jl		falseBlock				;number < LOWER_LIMIT
	cmp		eax, UPPER_LIMIT		;check condition 2
	jg		falseBlock				;number > UPPER_LIMIT

;trueBlock
	mov		edx, OFFSET valid_2		;"Good choice"
	call	WriteString
	call	CrLf
	jmp		endBlock

falseBlock:
	mov		edx, OFFSET valid_1		;"Invalid, try again"
	call	WriteString
	call	CrLf
	
	;Get another input and repeat validation 	
	call	getUserData				
	jmp		validationLoop

endBlock:
	ret
validate		ENDP

;---------------------------------------------------
;Procedure to display the composite numbers with the correct amount of terms per line
;receives: number of composites to show is global variable
;returns: none (calls isComposite and outputs composites)
;preconditions: have number of composites to show set
;registers changed: eax, ebx, ecx
;---------------------------------------------------
showComposites	PROC

	;set composite output loop counter
	mov		ecx, number

	;beginning of loop (will also be treated as jump destination)
	compositeLoop:
	;update dividend to parse with a fresh divisor
	inc		dividend
	mov		divisor, 2
	
	callComposite:
	;prepare composite search process
	mov		eax, dividend
	cdq
	mov		ebx, divisor
	div		ebx

	;call isComposit to check if dividend is composite
	call	isComposite

	;check if isComposite returned match
	cmp		composite, 0
	jne		printComposite

	;composite was not found so increment divisor until its = dividend - 1
	inc		divisor
	mov		edx, divisor
	cmp		edx, dividend
	jl		callComposite 
	jmp		compositeLoop
	
printComposite:
	;print composite to screen and line management
	mov		eax, dividend
	mov		edx, OFFSET dividend
	call	WriteDec
	mov		edx, OFFSET spaces		;"   "
	call	WriteString	
		
	inc		lineCount
	cmp		lineCount, 10
	je		newLine
	jmp		resume

newLine:
	call	CrLf
	mov		lineCount, 0			;reset terms per line counter to 1

resume:
	loop	compositeLoop

	ret
showComposites	ENDP

;---------------------------------------------------
;Procedure to determine the composite numbers, checks the remainder from the
;division search process. If the remainder is 0 than the dividend is composite
;and is composite is set to 1 for true else 0 for false
;receives: dividend as a global variable and remainder from div in edx
;returns: composite as either 0, 1 as a global variable
;preconditions:	dividend is correct and divisor is in ebx
;registers changed: n/a
;---------------------------------------------------
isComposite		PROC
	
	;check if remainder is zero
	cmp		edx, 0
	jne		notComposite

	;else dividend is a composite
	mov		composite, 1
	jmp		endBlock2

notComposite:
	;set composite to false
	mov		composite, 0

endBlock2:
	ret
isComposite		ENDP
;---------------------------------------------------
;Procedure to display the goodbye message
;receives: n/a
;returns: console output 
;preconditions: n/a
;registers changed: n/a
;---------------------------------------------------
farewell		PROC
	
;Display goodbye message to the user
	call	CrLf
	mov		edx, OFFSET	goodbye_1	;"Goodye message"
	call	WriteString
	call	CrLf

	ret
farewell		ENDP


END main
