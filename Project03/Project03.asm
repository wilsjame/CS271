TITLE Programming Assignment #3     (Project03.asm)

; Author: James Wilson (wilsjame)
; CS 271 / Program 3                 Date: 2/10/2017
; Description: This program covers no new topics and is intended to be
; more MASM practice. Keeping MASM coding fresh in the mind.
;
; This program repeatedly prompts the user to enter a number between [-100, -1]
; with validation. The user can keep entering numbers until a non-negative number 
; is entered. (The non-negative number is discarded.) 
; The following will be calculated and displayed:
; - number of negative numbers entered (if none entered display special message and say goodbye)
; - sum of negative numbers entered
; - rounded integer average of the negative numbers (e.g. -20.5 rounds to -20)
; - goodbye message with the user's name
;
; Other requirements:
; - main procedure modularized into commented logical sections
; - comments 
; - lower limit should be defined as a constant


INCLUDE Irvine32.inc

; (constant definitions here)
LOWER_LIMIT EQU <-100>	;alt consant syntax: LOWER_LIMIT = -100
UPPER_LIMIT EQU	<-1>

.data
	
; (insert variable definitions here)
intro_1		BYTE	"		Integer Accumulator				by James Wilson",0
intro_2		BYTE	"Hello, ",0
intro_3		BYTE	" nice to meet you :)",0

prompt_1	BYTE	"What is your name? ",0
prompt_2	BYTE	"Enter number: ",0

instr_1		BYTE	"Please enter numbers in [-100, -1].",0
instr_2		BYTE	"Enter a non-negative number when you are finished to see results.",0

valid_1		BYTE	"INVALID, I really recommend an integer value in the range [-100, -1].",0
valid_2		BYTE	"You entered ",0
valid_3		BYTE	" valid number(s).",0

result_1	BYTE	"The sum of your valid numbers is ",0
result_2	BYTE	"The rounded average is ",0

goodbye_1	BYTE	"Thank you for playing Integer Accumulator! It's been a pleasure to meet you. Well, if I could feel pleasure, as I am merely a simple MASM program...",0
goodbye_2	BYTE	"This is my life, my only purpose. Oh my god. Bye, ",0
goodbye_3	BYTE	"No numbers entered. Bye, ",0

userName	BYTE	33 DUP(0)	;string to be entered by the user- Fiiled with zeroes to guaranteee a null character at the end of string

userInput	SDWORD	?			;signed integer, within the range, to be entered possibly mutliple times 
count		DWORD	0			;counts number of valid integers entered
accumulator	SDWORD	0			;signed integer that will sum all the integers entered
average		SDWORD	?
remainder	SDWORD	?			

.code
main PROC

; (insert executable instructions here)
;Display program title and programmer's name
	mov		edx, OFFSET intro_1		;edx register is no pointing to the begining of intro_1
	call	WriteString				;displays text as its stored in memory
	call	CrLf					;carry return line feed creates new line
	call	CrLf

;Get user name
	mov		edx, OFFSET prompt_1	;"What is your name? ",0
	call	WriteString
	mov		edx, OFFSET username	;Readstring preconditions 1) address to userName in edx 2) max number of characters to accept in ecx
	mov		ecx, 32
	call	ReadString				;input intil [enter] is pressed

;Display introduction
	mov		edx, OFFSET intro_2		;"Hello "
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET intro_3		;" nice to meet you :)"
	call	WriteString
	call	CrLf

;Display instructions 
	mov		edx, OFFSET instr_1		;"Please enter numbers in [-100, -1]."
	call	WriteString
	call	CrLf
	mov		edx, OFFSET instr_2		;"Enter a non-negative number when you are finished to see results."
	call	CrLf

	
getInputs:				;Get valid user inputs loop
	mov		edx, OFFSET prompt_2	;"Enter number: "
	call	WriteString		
	call	ReadInt

	;compund condition (AND): (1)input is greater than lower limit AND (2)input is less than upper limit
	mov		userInput, eax			;store input into userInput
	cmp		eax, LOWER_LIMIT		;check condition 1
	jl		falseBlock1				;userInput < LOWER_LIMIT	 
	cmp		eax, UPPER_LIMIT		;check condition 2
	jg		falseBlock2				;userInput > UPPER_LIMIT	 
	  
;trueBlock
	;update accumulator
	mov		eax, userInput			
	add		eax, accumulator		;add the accumulator to the userInput
	mov		accumulator, eax		;mov the result back into the accumulator
	add		count, 1				;increment count
	jmp		getInputs				;get another input

falseBlock1:
	mov		edx, OFFSET valid_1		;"INVALID, I really recommend an integer value in the range [-100, -1]."
	call	WriteString
	jmp		getInputs

falseBlock2:
	cmp		count, 0				;check count value
	jne		calculationBlock		;jump to calculations block if there are numbers entered
	jmp		goodbyeBlock2			;jump to goodbyeBlock2 if there are no numbers entered


calculationBlock:		;calculate and display results
	;display numbers entered
	mov		edx, OFFSET valid_2		;"You entered "
	call	WriteString
	mov		eax, count				;prepare the count to be outputted
	call	WriteDec				;reads from the eax register, writes an unsigned 32bit integer to the console
	mov		edx, OFFSET valid_3		;" valid numbers."
	call	WriteString
	call	CrLf

	;display the sum of the numbers entered
	mov		edx, OFFSET result_1	;The sum of your valid numbers is "
	call	WriteString
	mov		eax, accumulator
	call	WriteInt				;writes a signed 32bit integer to the console in decimal format
	call	CrLf

	;calculate the rounded integer average (accumulated sum divided by the count)
	mov		eax, accumulator
	cdq
	mov		ebx, count
	idiv	ebx						;signed division: quotient in eax, remainder in edx, count still in ebx
	mov		average, eax

	;check if rounding is needed
	mov		remainder, edx			;double the remainder
	add		remainder, edx
	neg		remainder				;reverses sign of remainder from (-) -> (+)
	cmp		remainder, ebx			;compare the remainder with the divisor (count in ebx);;;;;;;;;;;
	jl		displayAverage			;remainderX2 < the divisor (count) 
									
roundUp:				;if the remainderX2 is >= the divisor (count) then perform rounded average loop until there is no remainder
	dec		accumulator				;add negative one the accumulator
	mov		eax, accumulator
	cdq
	mov		ebx, count
	idiv	ebx						;signed division: quotient in eax, remainder in edx, count still in ebx
	mov		average, eax

	;check if rounding is needed
	add		edx,edx					;double the remainder
	mov		remainder, edx
	cmp		remainder, ebx			;compare the remainder with the divisor (count in ebx)
	jge		roundUp					;remainderX2 >= the divisor (count) execute roundUp block again

displayAverage:    
	mov		edx, OFFSET result_2	;"The rounded average is "
	call	WriteString
	mov		edx, OFFSET average
	call	Writeint
	call	CrLf
	
goodbyeBlock1:			;user entered numbers
	call	CrLf
	mov		edx, OFFSET	goodbye_1	;"Thank you for playing Integer Accumulator! It's been a pleasure to meet you. Well, if I could feel pleasure, as I am merely a simple MASM program..."
	call	WriteString
	call	CrLf
	mov		edx, OFFSET goodbye_2	;"Peace, "
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf
	jmp		exitBlock

goodbyeBlock2:			;output special goodbye with users name
	call	CrLf
	mov		edx, OFFSET goodbye_3	;"No numbers entered. Bye, "
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf

exitBlock:				;jump here to exit
	
		exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
