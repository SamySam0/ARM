; Laboratory

print_char	equ	0		; Define names to aid readability
stop		equ	2
print_str	equ	3
print_no	equ	4

cLF			equ	10		; Line-feed character

ADR	SP, _stack			; set SP pointing to the end of our stack
B		main
DEFS	100				; this chunk of memory is for the stack
_stack					; This label is 'just after' the stack space

wasborn		DEFB	"This person was born on ",0
was			DEFB	"This person was ",0
on			DEFB	" on ",0
is			DEFB	"This person is ",0
today		DEFB	" today!",0
willbe		DEFB	"This person will be ",0
			ALIGN

pDay		DEFW	23		;  pDay = 23    //or whatever is today's date
pMonth		DEFW	11		;  pMonth = 11  //or whatever is this month
pYear		DEFW	2005	;  pYear = 2005 //or whatever is this year







; def printAgeHistory (bDay, bMonth, bYear)

; parameters
;  R0 = bDay (on entry, moved to R6 to allow SVC to output via R0)
;  R1 = bMonth
;  R2 = bYear
;  local variables (callee-saved registers)
;  R4 = year
;  R5 = age
;  R6 = bDay - originally R0

printthedate	
	MOV	R0, R6
	SVC	print_no
	MOV	R0, #'/'
	SVC	print_char
	MOV	R0, R1
	SVC	print_no
	MOV	R0, #'/'
	SVC	print_char
	MOV	R0, R2
	SVC	print_no
	MOV	R0, #cLF
	SVC	print_char
	MOV	PC, LR


printAgeHistory	
STMFD SP!, {R0-R2, R4-R6}		; callee saves three registers

LDR	R6, [SP, #(6 + 2) * 4]		; Get parameters from stack
LDR	R1, [SP, #(6 + 1) * 4]
LDR	R2, [SP, #(6 + 0) * 4]

; year = bYear + 1
ADD	R4, R2, #1
; age = 1;
MOV	R5, #1

; print("This person was born on " + str(bDay) + "/" + str(bMonth) + "/" + str(bYear))
	ADRL	R0, wasborn
	SVC		print_str
	PUSH 	{LR}
	PUSH	{R0-R6}
	BL 		printthedate
	POP 	{R0-R6}

; this code does:
; while year < pYear or
;				(year == pYear and bMonth < pMonth) or
;				(year == pYear and bMonth == pMonth and bDay < pDay):

loop1	LDR	R0, pYear
		CMP	R4, R0
		BLT next

		BNE bool2
		LDR R0, pMonth
		CMP R1, R0
		BLT next

bool2	BNE end1
		LDR	R0, pYear
		CMP R4, R0
		BNE end1
		LDR R0, pDay
		CMP R6, R0
		BGE end1

;  print("This person was " + str(age) + " on " + str(bDay) + "/" + str(bMonth) + "/" + str(year))
next	ADRL	R0, was
		SVC	print_str
		MOV	R0, R5
		SVC	print_no
		ADRL	R0, on
		SVC	print_str
		MOV	R2, R4 			;update year parameter
		PUSH	{R0-R6}
		BL 	printthedate
		POP 	{R0-R6}

; year = year + 1
ADD	R4, R4, #1
; age = age + 1
ADD	R5, R5, #1
; //}
B	loop1

end1
; this code does:
; if (bMonth == pMonth and bDay == pDay):
	LDR	R0, pMonth
	CMP	R1, R0
	BNE	else1
	LDR	R0, pDay
	CMP	R6, R0
	BNE	else1

; print("This person is " + str(age) + " today!")
	ADRL	R0, is
	SVC	print_str
	MOV	R0, R5
	SVC	print_no
	ADRL	R0, today
	SVC	print_str
	MOV	R0, #cLF
	SVC	print_char

; else
	B	end2

else1
; print("This person will be " + str(age) + " on " + str(bDay) + "/" + str(bMonth) + "/" + str(year))
	ADRL	R0, willbe
	SVC	print_str
	MOV	R0, R5
	SVC	print_no
	ADRL	R0, on
	SVC	print_str
	MOV	R2, R4 			; we update year parameter
	PUSH	{R0-R6}
	BL 	printthedate
	POP 	{R0-R6}

; }// end of printAgeHistory
end2	
	POP	{PC}		

another		
	DEFB	"Another person",10,0
	ALIGN







; def main():
main
	LDR	R4, =&12345678			; Test value - not part of Java compilation
	MOV	R5, R4					
	MOV	R6, R4

; printAgeHistory(pDay, pMonth, 2000)
	LDR	R0, pDay
	STMFD SP!, {R0}				; Stack first parameter
	LDR	R0, pMonth
	STMFD SP!, {R0}				; Stack second parameter
	MOV	R0, #2000
	STMFD SP!, {R0}				; Stack third parameter
	BL	printAgeHistory
	LDMFD SP!, {R0-R2, R4-R6}
	ADD SP, SP, #12	

; print("Another person");
	ADRL	R0, another
	SVC	print_str

; printAgeHistory(13, 11, 2000)
	MOV	R0, #13
	STMFD SP!, {R0}				; Stack first parameter
	MOV	R0, #11
	STR	R0, [SP, #-4]!
	MOV	R0, #2000
	STMFD	SP!, {R0}			; The STore Multiple mnemonic for PUSH {R0}
	BL	printAgeHistory
	LDMFD SP!, {R0-R2, R4-R6}
	ADD SP, SP, #12
					
	; Now check to see if register values intact (Not part of Java)
	LDR	R0, =&12345678			; Test value
	CMP	R4, R0					; Did we preserve these registers?
	CMPEQ	R5, R0				;
	CMPEQ	R6, R0				;

	ADRLNE	R0, whoops1			; Oh dear!
	SVCNE	print_str			;

	ADRL	R0, _stack			; Have we balanced pushes & pops?
	CMP	SP, R0					;

	ADRLNE	R0, whoops2		; Oh no!!
	SVCNE	print_str		; End of test code

; }// end of main
		SVC	stop

; Error messages
whoops1		DEFB	"\n** BUT WE CORRUPTED REGISTERS!  **\n", 0
whoops2		DEFB	"\n** BUT MY STACK DIDN'T BALANCE!  **\n", 0
