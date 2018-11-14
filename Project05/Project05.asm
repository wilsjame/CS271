TITLE Program Template     (Project05.asm)

; Author: James Wilson (wilsjame)
; CS 271 / Program 5                Date: 3/7/2017
; Description: 

;- Generate random numbers in the range [100, 999]
;- Displays original list
;- Sorts the list
;- Calculates median value
;- Displays list sorted in descending order

;       ----Program Structure----
;- Display programmer's name, title, and description
;
;- Prompt to enter an integer (request) in the range [min = 10, max = 200]
;- Validate the number
;
;- Generate the number (request) of random integers in the range [lo = 100, hi = 999]
;-	Store them in consecutive elements of an array 
; 
;- Display the array of integers before sorting 10 numbers per line
;
;- Sort the array in descending order, (i.e., largest first)
;
;- Calculate the median value, rounded to the nearest integer
;-	Display the value 
;
;- Display the sorted array 10 numbers per line

; Implementaion notes:
;	min, max, lo, and hi must be global constants
;	Strings may be global variables or constants
;	This program is implemented using procedures
;	Parameters must be passed by value or reference on the system stack 
;
;**EC: DESCRIPTION (attempts)
; 2. Use a recursive (quicksort) sorting algorithm
; 5. Other, changed the color scheme to red and white. Go Blazers!
; 5. Other, farewell message


INCLUDE Irvine32.inc

;user input range
MIN			EQU <10>		;alt consant syntax: MIN = 1
MAX			EQU	<200>

;random number range
LO			EQU	<100>
HI			EQU	<999>

;array size
MAX_SIZE	EQU <200>	

.data

intro_1		BYTE	"		Sorting Random Integers			by James Wilson",0
intro_2		BYTE	"This program generates random numbers in the range [100, 999]",0
intro_3		BYTE	"displays the original list, sorts the list, and calculates the",0
intro_4		BYTE	"median value. Finally, it displays the list sorted in descending order.",0
prompt_1	BYTE	"How many numbers should be generated? [10, 200]: ",0
valid_1		BYTE	"Out of range. Try again.",0
valid_2		BYTE	"Good choice.",0
spaces		BYTE	"     ",0
title_1		BYTE	"Unsorted list:",0
title_2		BYTE	"The median is:",0
title_3		BYTE	"Sorted list:",0
result_1	BYTE	"The median is ",0

goodbye_1	BYTE	"Thank you for playing Sorting Random Integers! It's been a pleasure to serve you. Well, if I could feel pleasure, as I am merely a simple MASM program...",0
goodbye_2	BYTE	"This is my life, my only purpose. Oh my god. Bye, ",0

EC_2		BYTE	"**EC: Used a recursive sorting algorithm (QuickSort)",0
EC_5a		BYTE	"**EC: Changed color scheme to output red and white. Go Blazers!",0 
EC_5b		BYTE	"**EC: Created a program with a harsh realization about its own existence",0 

request		DWORD	?		;user input for amount of random numbers to generate
leftMost	DWORD	0		;left most value in the array, 0. (used by quicksort)
rightMost	DWORD	?		;right most value in the array, request - 1. (used by quicksort)

;array		element,	size,	initialize
array		DWORD	MAX_SIZE	DUP(?)

.code
main PROC

	call	Randomize		;(Irvine) procedure initializes starting seed for Random32 and RandomRange procedures

	;introduce program
	call	introduction	

	;get valid user input for request
	push	OFFSET request	;pass request by reference
	call	getData			;get a valid value for request

	;Generate and fill array with random numbers
	push	OFFSET array	
	push	request			;user input for the number of random numbers to fill array with
	call	fillArray		;fills array with random numbers 

	;calculate the right most value's index in the array using the user input, request (rightMost = request -1) 
	mov		eax, request
	dec		eax
	mov		rightMost, eax
	mov		eax, rightMost				;Output the rightMost index for testing (it's good!) 
	call	WriteDec	
	call	Crlf
	
	;display the unsorted array of random numbers
	push	OFFSET title_1
	push	OFFSET array
	push	request
	call	displayList

	;sort the array in descending order (largest first)
	push	rightMost
	push	leftMost
	push	OFFSET array
	call	sortList
			;swapElement
	push	rightMost
	push	OFFSET array
	call	reverse

	;calculate and display the median of the array
	push	OFFSET title_2
	push	request
	push	OFFSET array
	call	median

	;display the sorted array of random numbers
	push	OFFSET title_3
	push	OFFSET array
	push	request
	call	displayList

	;display a goodbye message
	push	OFFSET goodbye_1
	push	OFFSET goodbye_2
	call	goodbye

	exit					; exit to operating system
main ENDP

;---------------------------------------------------
;Procedure to display the introduction and change color scheme 
;receives: n/a
;returns: console output 
;preconditions: n/a
;registers changed: n/a
;---------------------------------------------------
introduction	PROC

;Display program title, progammer's name
	mov		edx, OFFSET intro_1		;edx register is now pointing to the begining of intro_1
	call	WriteString				;displays text as its stored in memory
	call	CrLf					;carry return line feed creates new line
	call	CrLf

;Display brief description
	mov		edx, OFFSET intro_2		
	call	WriteString				
	call	CrLf
	mov		edx, OFFSET intro_3		
	call	WriteString				
	call	CrLf
	mov		edx, OFFSET intro_4		
	call	WriteString				
	call	CrLf

	;display extra credit attempts
	call	CrLf
	mov		edx, OFFSET EC_2
	call	WriteString				
	call	CrLf
	mov		edx, OFFSET EC_5a	
	call	WriteString				
	call	CrLf
	mov		edx, OFFSET EC_5b
	call	WriteString				
	call	CrLf
	call	CrLf

	mov		eax, white+(red*16)
	call	SetTextColor	;set to Blazers color scheme

	ret
introduction	ENDP

;---------------------------------------------------
;Procedure to get a a valid user input
;receives: address of parameter (request) on stack, an integer user input  
;returns: valid user input value for the amount of random numbers to generate 
;preconditions: n/a
;registers changed: eax, ebx, edx
;---------------------------------------------------
getData			Proc
	push	ebp						;set up stack fram (activation record)
	mov		ebp, esp
	mov		ebx, [ebp+8]			;get address of request into ebx

validationLoop:						;beginning of data post-test validation loop
	;get an integer for number
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		[ebx], eax				;store user input at address in ebx (which is request!)

	;compound condition (AND): (1)input greater than lower limit AND (1)less than upper limit
	cmp		eax, MIN				;check condition 1 (number should still be in eax)
	jl		falseBlock				;number < LOWER_LIMIT
	cmp		eax, MAX				;check condition 2
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
	jmp		validationLoop

endBlock:
	pop		ebp						;restore stack
	ret		4						;pop 4 additional byes off stak (we pushed OFFSET of request before call) 
getData			ENDP

;---------------------------------------------------
; Procedure to put request# of random numbers into the array.
; receives: array (reference), request (value)
; returns: array filled with random numbers
; preconditions: request is initialized in the range [10, 200]
; registers changed: eax, ecx, edi
;---------------------------------------------------
fillArray		PROC
	push	ebp						;set up stack fram (activation record)
	mov		ebp, esp
	mov		edi, [ebp+12]			;(starting) address of array in edi
	mov		ecx, [ebp+8]			;request (loop counter) in ecx

again:								;loop for adding random numbers to array
	;generate a random number in eax, [100, 999]
	mov		eax, HI					;999				
	sub		eax, LO					;999 - 100 = 899
	inc		eax						;900
	call	RandomRange				;eax is [0, 900 - 1] => [0, 899]
	add		eax, LO					;eax is [100, 999]

	;add random number to array
	mov		[edi], eax
	add		edi, 4
	loop	again

	pop		ebp
	ret		8
fillArray		ENDP

;---------------------------------------------------
; Procedure sort the array in descending order (largest first) using a quicksort algorithm
; receives: rightMost index of array, leftMost index of array, and address of array
; returns: sorted array
; preconditions: request is initialized in the range [10, 200]
;				 and the array is filled with request number of random numbers
; registers changed: eax, ebx, ecx, edx, esi, edi
;---------------------------------------------------
sortList		PROC
	pushad							;save all registers on stack, pushes an additional 32 bytes on stack
	mov		ebp, esp				;set up stack fram (activation record)

	;create space for 3 local variable, i, j, pivot. Where i and j are the left and right indexes of the array, respectively 
	sub		esp, 12					;make space for 3 DWORDS on the stack (12 bytes) 
	i_local			EQU DWORD PTR [ebp-4]
	j_local			EQU DWORD PTR [ebp-8]
	pivot_local		EQU DWORD PTR [ebp-12]
	
	mov		edx, [ebp+44]			;rightMost index in edx
	mov		ecx, [ebp+40]			;leftMost index in ecx
	mov		esi, [ebp+36]			;address to array in esi

	;set up i and j with their values
	mov		i_local, ecx			;i = initial low index of array, leftMost
	mov		j_local, edx			;j = initial high index of array, rightMost
	
	;set pivot as the midpoint of the array
	mov		eax, ecx				;eax = i
	add		eax, edx				;eax = i = i + j 
	cdq								;edx = 0
	mov		ebx, 2					;ebx = 2
	div		ebx						;eax/ebx => quotient in eax, remainder in edx, no change ebx
									;eax now the midpoint of the array
	mov		ecx, [esi+eax*4]		;move the actual midpoint array value into ecx
	mov		pivot_local, ecx		
	
whileLoop1:							;while(i <= j), leftMost is less than or equal to rightMost
	mov		eax, i_local	
	cmp		eax, j_local
	jg		endWhileLoop1			;jump if greater (leftOp > rightOp)

whileLoop2:							;while(array[i] < pivot) => increment i
	mov		ecx, i_local
	mov		eax, [esi+ecx*4]		;move value of array[i] into eax
	cmp		eax, pivot_local
	jge		endWhileLoop2			;jump is greater than or equal
	inc		i_local
	jmp		whileLoop2				;continue while loop
endWhileLoop2:

whileLoop3:							;while(array[j] > array[pivot]) => decrement j
	mov		ecx, j_local
	mov		eax, [esi+ecx*4]		;move value of array[j] into eax
	cmp		eax, pivot_local
	jle		endWhileLoop3			;jump is less than or equal
	dec		j_local
	jmp		whileLoop3				;continue while loop
endWhileLoop3:

;compare i and j
	mov		ecx, i_local
	mov		ebx, j_local
	cmp		ecx, ebx
	jg		endCompare;					;eventually jumps to whileLoop1

;swap array[i] and array[j] elements as i is less than or equal to j, then inc i and dec j
	;set up stack before calling swap procdure
	mov		ecx, i_local 
	mov		ebx, j_local 
	mov		esi, [ebp+36]			;address of array in esi
	lea		edi, [esi+ecx*4]		;load address of array[i] in edi
	push	edi						
	lea		edi, [esi+ebx*4]		;load address of array[j] in edi
	push	edi
	call	swap			
	inc		i_local
	dec		j_local
endCompare:
	jmp		whileLoop1

endWhileLoop1:
	;quicksort is recursive, here is the recursion component of the algorithm
	;set up stack before calling quicksort again
	mov		eax, [ebp+40]			;move leftMost into eax
	cmp		eax, j_local			
	jge		byPass					;leftMost is greater than or equal to rightMost
	mov		ebx, j_local			
	push	ebx						;push rightMost j index
	push	eax						;push leftMost i index
	push	esi						;push address of array
	call	sortList

byPass:
	mov		eax, [ebp+44]			;move rightMost ino eax
	cmp		i_local, eax
	jge		endQuicksort			
	mov		ebx, i_local
	push	eax
	push	ebx
	push	esi
	call	sortList

endQuicksort:
	mov		esp, ebp				;clear local variables from stack
	popad							;restore general purpose registers
	ret		12
sortList		ENDP

;---------------------------------------------------
; Procedure to swap elements between two arrays
; receives: address of specific array (source) element, address of specific array (destination) element
;			array[i] address, array[j] address
; returns: swapped values in arrays
; preconditions: reference to array 1 and array 2 on stack
; registers changed: eax, ebx, esi, edi
;---------------------------------------------------
swap		PROC
	push	ebp						;set up stack fram (activation record)
	mov		ebp, esp				
	pushad							;save general purpose registers

	;set up array registers for swap
	mov		esi, [ebp+8]			;address of specific source array element 
	mov		edi, [ebp+12]			;address of specific destination array element

	;perform swap
	mov		eax, [esi]				;eax now has source array element value
	mov		ebx, [edi]				;ebx now has destination array element value
	mov		[esi], ebx				;destination value, ebx   ---> replaces source value [esi]
	mov		[edi], eax				;source value, eax        ---> replaces destination value [edi]

	popad							;restore general purpose registers
	pop		ebp
	ret		8
swap		ENDP

;---------------------------------------------------
; Procedure to reverse the order of elements in an array
; receives: value of the right most index of the array, address of array
; returns: none, swaps values in the reference array
; preconditions: correct array size index and reference array passed
; registers changed: eax, ebx, ecx, edx, esi, edi
;---------------------------------------------------
reverse			PROC
	push	ebp
	mov		ebp, esp				;set up stack frame(activation record)

	;create space for 2 local variable, i, j. Where i and j are the left and right indexes of the array, respectively 
	sub		esp, 8					;make space for 2 DWORDS on the stack (8 bytes) 
	i_local			EQU DWORD PTR [ebp-4]
	j_local			EQU DWORD PTR [ebp-8]

	mov		esi, [ebp+8]			;address of array is in esi
	mov		ecx, 0					;left most array index is in ecx
	mov		ebx, [ebp+12]			;right most array index is in ebx

	;set up i and j with their values
	mov		i_local, ecx			;i = initial low index of array, leftMost
	mov		j_local, ebx			;j = initial high index of array, rightMost

	;check if the rightMost index is even,

	mov		ecx, [ebp+12]			;request (size of array) in ecx

	;check if right most array index is odd
	mov		eax, ebx				;rightMost index is in now eax
	cdq
	mov		ebx, 2
	div		ebx						;eax/ebx => quotient in eax, remainder in edx, no change ebx
	cmp		edx, 1					;compare the remainder with 1. 1 means the right most array index is odd
	jne		oddReversal				;right most index is even, there is an odd number of elements in the array

evenReversal:						;there is an even number of elements in the array 
	;set up stack before calling swap procdure
	mov		ecx, i_local 
	mov		ebx, j_local 
	lea		edi, [esi+ecx*4]		;load address of array[i] in edi
	push	edi						
	lea		edi, [esi+ebx*4]		;load address of array[j] in edi
	push	edi
	call	swap	

	inc		i_local					;increment i (left index)
	dec		j_local					;decrement j (left index)
	mov		ecx, i_local 
	mov		ebx, j_local
	
	;check if the swap has reached the two middle values
	inc		ecx
	cmp		ecx,ebx
	jl		evenReversal

	;swap the remaining two middle values
	;set up stack before calling swap procdure
	mov		ecx, i_local 
	mov		ebx, j_local 
	inc		ecx
	dec		ebx
	lea		edi, [esi+ecx*4]		;load address of array[i] in edi
	push	edi						
	lea		edi, [esi+ebx*4]		;load address of array[j] in edi
	push	edi
	call	swap

	jmp		endReversal	
	
oddReversal:						
	;set up stack before calling swap procdure
	mov		ecx, i_local 
	mov		ebx, j_local 
	lea		edi, [esi+ecx*4]		;load address of array[i] in edi
	push	edi						
	lea		edi, [esi+ebx*4]		;load address of array[j] in edi
	push	edi
	call	swap
		
	inc		i_local					;increment i (left index)
	dec		j_local					;decrement j (left index)
	mov		ecx, i_local 
	mov		ebx, j_local 
	cmp		ecx,ebx					;check if the swap has reached the absolute middle
	jne		oddReversal		
	
endReversal:
	mov		esp, ebp		;clear local variables from stack
	pop		ebp
	ret		12
reverse		ENDP

;---------------------------------------------------
; Procedure to calculate and display the median value, rounded to the nearest integer
; receives: address of an array, size of array
; returns: none 
; preconditions: array is sorted
; registers changed: eax, ebx, ecx, edx, esi
;---------------------------------------------------
median			PROC
	push	ebp
	mov		ebp, esp				;set up stack frame(activation record)

	;print the list title
	call	CrLf
	mov		edx, [ebp+16]			;address of title_3 is in edx
	call	WriteString
	call	CrLf

	mov		esi, [ebp+8]			;(starting) address of array in esi
	mov		ecx, [ebp+12]			;request (size of array) in ecx

	;check if the number of elements in the array is odd
	mov		eax, ecx
	cdq
	mov		ebx, 2
	div		ebx						;eax/ebx => quotient in eax, remainder in edx, no change ebx
	cmp		edx, 1					;compare the remainder with 1. 1 means the number of elements in the array is odd
	je		oddArray				;median will by the middle number of the array

;else the number of elements is even (~middle of array is in eax)
	mov		ebx, eax				
	dec		ebx						;the median is now between ebx and eax
	mov		ecx, [esi+eax*4]		;put the right median value in ecx
	mov		edx, [esi+ebx*4]		;put the left median value in edx
	add		ecx, edx				;the sum of the two values is now in ecx

	;calculate and display median to the nearest integer for an even number of elements
	mov		eax, ecx
	cdq
	mov		ebx, 2
	div		ebx						;eax/ebx => quotient in eax, remainder in edx, no change ebx
	call	WriteDec
		
	jmp		endMedian

	;display the median for an odd number off elements
oddArray:							;middle array index is in eax
	mov		ebx, eax				;move the middle array index into ebx
	mov		eax, [esi+ebx*4]
	call	WriteDec
				
endMedian:
	call	CrLf
	pop		ebp
	ret		12	
median			ENDP

;---------------------------------------------------
; Procedure to display array in its current state (10 numbers per line)
; receives: address of array, value of request (size,count), and address of the title on system stack
; returns: displays the contents of the array
; preconditions: request is initialized in the range [10, 200]
;				 and the array is filled with request number of numbers
; registers changed: eax, ebx, ecx, edx, esi
;---------------------------------------------------
displayList		PROC
	push	ebp
	mov		ebp, esp				;set up stack frame

	;print the list title
	call	CrLf
	mov		edx, [ebp+16]			;address of title_1 is in edx
	call	WriteString
	call	CrLf

	;set up other parameters
	mov		esi, [ebp+12]			;(starting) address of array in esi
	mov		ecx, [ebp+8]			;address of request (size, count) in ecx
	mov		ebx, 0					;terms per line counter

more:
	mov		eax, [esi]				;get current element
	call	WriteDec
	mov		edx, OFFSET spaces		;puts spaces between terms
	call	WriteString
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
	ret		12						;title_1, array, request => 4, 4, 4 bytes
displayList		ENDP

;---------------------------------------------------
; Procedure to display a goodbye message to the user
; receives: offsets of goodbye strings
; returns: none, displays the contents of strings
; preconditions: offset of correct strings on stack
; registers changed: edx
;---------------------------------------------------
goodBye		PROC
	push	ebp
	mov		ebp, esp				;set up stack frame

	;print goodbye message
	call	Crlf
	call	CrLf
	mov		edx, [ebp+12]			;address of goodbye message is in edx
	call	WriteString
	call	CrLf

	call	CrLf
	mov		edx, [ebp+8]			;address of goodbye message is in edx
	call	WriteString
	call	CrLf

	pop		ebp
	ret		8						;title_1, array, request => 4, 4, 4 bytes
goodbye		ENDP

END main

;---Procedure Description Template---
;---------------------------------------------------
;Description: A description of the task accomplished by the procedure (one task, one sentence! even if thats calling other procedures( 
;receives: A list of input parameters; state usage and requirements
;returns: A description of the values returned by the procdedure
;preconditions: List of requirements that must be satisfied before the procedure is called (set required registers before calling)
;registers changed: List of registers that may have different values than they had when the procedure was called
;---------------------------------------------------