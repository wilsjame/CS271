TITLE Dog Years     (Project00.asm)

; Author: James Wilson
; CS 271 / Demo #0               Date: 1/17/2017
; Description: This program will introduce the programmer, get the user's name and age,
; calculate the user's "dog's age", and report the result.

INCLUDE Irvine32.inc

; (insert constant definitions here)
DOG_FACTOR = 7

.data

; (insert variable definitions here)
userName	BYTE	33 DUP(0)	;string to be entered by user- not filled string with zeros to gaurantee a 0 BYTE at the end of the string after user input
userAge		DWORD	?			;integer to be entered by user
intro_1		BYTE	"Hi, my name is James, and I'm here to tell you your age in dog years", 0	;all strings must be terminated by a 0 BYTE 
prompt_1	BYTE	"What's your name? ", 0
intro_2		BYTE	"Nice to meet you, ", 0
prompt_2	BYTE	"How old are you? ", 0
dogAge		DWORD	?
result_1	BYTE	"Wow . . . that's ", 0
result_2	BYTE	" in dog years !", 0
goodbye		BYTE	"Good-bye, ", 0

.code
main PROC

; (insert executable instructions here)
;PROBLEM/PROGRAM OUTLINE HERE
;Introduce programmer (1)
	mov		edx, OFFSET intro_1		;edx register is now pointing to beginning of intro_1
									;OFFSET gives address. Withour OFFSET its just the characters which will result in an error
	call	WriteString				;WriteString procedure displays text as it's stored in memory
	call	CrLf					;carry return line feed creates new line

;Get user name (4)
	mov		edx, OFFSET prompt_1
	call	WriteString
									;ReadString preconditions 1) address (pointer) to userName is edx 2) max number of characters to accept in ecx
	mov		edx, OFFSET userName
	mov		ecx, 32					;ReadString procedure requires a parameter that specifies the maximum length of string to accept
									;we declared the user name to be 33 character. go with 32 leaving 1 character for the null terminator 0
	call	ReadString				;input until [enter] is pressed

;Get user age (5)
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	mov		userAge, eax			;post condition for ReadInt- number is stored in eax register

;Calculate user age in dog years (6)
	mov		eax, userAge			;userAge is already is eax but good practice to set up register when starting a calculation
	mov		ebx, DOG_FACTOR 
	mul		ebx						;ebx is the operand. Multiply with whatevers in eax and stores result in eax
	mov		dogAge, eax

;Report user age in dog years (3)
	mov		edx, OFFSET result_1
	call	WriteString
	mov		eax, dogAge				;before printing an integer move value of integer into the eax register
	call	WriteDec				;originally use 'WriteInt' which displays integer as it's stored in memory, +0
									;WriteDec does the same without the '+'
	mov		edx, OFFSET result_2
	call	WriteString
	call	CrLf

;Say goodbye the user (2)
	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
