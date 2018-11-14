TITLE Programming Assignment #2     (Project02.asm)

; Author: James Wilson (wilsjame)
; CS 271 / Program 2                 Date: 1/29/2017 
; Description: This programs calculates the Fibonnaci numbers. It first displays
; the programmer's name then gets and displays the user's name. Then:
; -Prompt user to enter the number of Fibonacci terms to be displayed.
; -Suggest an integer in the range [1 .. 46].
; -Validate the user input (n).
; -Calculate and display all the Fibonacci numbers up to and including the nth term
; -Display results 5 term per line with atleast 5 spaces between them.
; -Display a goodbye message that includes the user's name


INCLUDE Irvine32.inc

UPPER_LIMIT EQU <46>	;alt constant syntax: UPPER_LIMIT = 46

.data

intro_1		BYTE	"			Fibonacci Numbers				by James Wilson",0
intro_2		BYTE	"Hello ",0
intro_3		BYTE	", nice to meet you :)",0
intro_4		BYTE	"			The Second-Order Fibonacci Sequence			",0
prompt_1	BYTE	"What is your name? ",0
prompt_2	BYTE	"# of numbers: ",0
instr_1		BYTE	"Enter the number of Fibonacci nunbers to display",0
instr_2		BYTE	"I recommend an integer value in the range [1 .. 46].",0
valid_1		BYTE	"INVALID, please enter a positive integer in the suggested range",0
valid_2		BYTE	"Good choice.",0
spaces		BYTE	"               ",0
goodbye_1	BYTE	"Goodbye ", 0

userName	BYTE	33 DUP(0)	;string to be entered by the user- Filled with zeros to guarantee null character at end of string
fiboNums	DWORD	?			;integer to be entered by the user- number of Fibonacci numbers to display
currentFibo	DWORD	0			;beginning of sequence
prevFibo	DWORD	1			;previous term in sequence, used as a placeholder for calculations
fiboCount	DWORD	?			;counts number of terms, used for printing a new line every five terms

.code
main PROC

;Display program title and programmers name
	mov		edx, OFFSET intro_1		;edx register is now pointing to the beginning of intro_1
	call	WriteString				;displays text as its stored in memory
	call	CrLf					;carry return line feed creates new line
	call	CrLf
;Get user name 
	mov		edx, OFFSET prompt_1	;"What is your name? "
	call	WriteString				
	mov		edx, OFFSET username	;Readstring preconditions 1) address to userName in edx 2) max number of characters to accept in ecx
	mov		ecx, 32
	call	ReadString				;input until [enter] is pressed
	
;Displays introduction
	mov		edx, OFFSET intro_2		;"Hello "
	call	WriteString	
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET intro_3		;", nice to meet you :)"
	call	WriteString
	call	CrLf

;Prompt user for data (with limits)
	mov		edx, OFFSET instr_1		;"Enter the number of Fibonacci nunbers to display"
	call	WriteString					
	call	CrLf

validationLoop:						;beginning of data post-test validation loop
	mov		edx, OFFSET instr_2		;"I recommend an integer value in the range [1 .. 46]."
	call	WriteString
	call	CrLf

	;get data from user
	mov		edx, OFFSET prompt_2	;"# of numbers: "
	call	WriteString
	Call	ReadInt

	;compound condition (AND): (1)data is greater than zero AND (1)less than UPPER_LIMIT
	mov		fiboNums, eax
	cmp		eax, 0					;check condition 1 
	jle		falseBlock				;fiboNums <= 0
	cmp		eax, UPPER_LIMIT		;check condition 2
	jg		falseBlock				;fiboNums > UPPER_LIMIT

;trueBlock
	mov		edx, OFFSET valid_2		;"Good choice"
	call	WriteString
	call	CrLf
	jmp		endBlock

falseBlock:
	mov		edx, OFFSET valid_1		;"INVALID..."
	call	WriteString
	call	CrLf
	jmp		validationLoop

endBlock:

;Calculate Fibonnaci numbers and display Fibonacci numbers according to requirements
	
	;check if there is one or more terms to calculate and jump accordingly 
	mov		eax, fiboNums
	cmp		eax, 1
	jne		multipleTerms

	oneTerm:
	mov		eax, fiboNums
	mov		edx, OFFSET fiboNums
	call	WriteDec				;output the 1st term of the sequence, 1
	jmp		goodbyeBlock

	multipleTerms:		
	mov		fiboCount, 1			;set terms per line counter to 1 
	mov		ecx, fiboNums			;set loop counter
		
	;Begin multiple terms fibo loop, every 5 terms will print a new line
	fiboLoop:
	mov		eax, currentFibo		;place the current term in eax
	mov		ebx, currentFibo		;place the current term in ebx for holding (will use later)
	add		eax, prevFibo			;add the previous term to the current term
	call	WriteDec				;print the newest term in the sequence: current+previous 
	mov		edx, OFFSET spaces
	call	WriteString				;print spacing between terms
	mov		currentFibo, eax		;move the newest term (eax) to current
	mov		prevFibo, ebx			;move the current term placed in ebx (ln 120) to previous term

	cmp		fiboCount, 5			;compare fibo terms per line with 5
	je		newLine					;if there are 5 terms on a line jump to newline
	inc		fiboCount				;if there are not 5 terms, add one to terms per line count
	
	jmp		resume

newLine:
	call	CrLf
	mov		fiboCount, 1			;reset terms per line counter to 1

resume:
	loop	fiboLoop				;repeat loop if counter has not reached zero
	
;Say goodbye to the user
goodbyeBlock:
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye_1	;"Goodbye "
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString				
	call	CrLf

	exit	; exit to operating system

main ENDP

END main