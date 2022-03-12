; Age History

	B  main

born	DEFB 	"you were born in \0"
were	DEFB 	"you were \0"
in		DEFB 	" in \0"
are		DEFB 	"you are \0"
this	DEFB 	" this year\n\0"
	ALIGN

; DEFWs initiation :
present DEFW	2021	; present = 2005
birth 	DEFW 	2003	; birth = 1959  
year 	DEFW 	0 		; year = 0      
age		DEFW	1		; age = 1       


main

	; Load 'present', 'birth', 'year', 'age' into R4, R5, R6, R7 respectively
	LDR R4, present
	LDR R5, birth
	LDR R6, year
	LDR R7, age

	; this code does print "you were born in " + str(birth) 
	ADR R0, born
	SVC 3
	MOV R0, R5 ; We use MOV to copy the value from Register 5 to Register 0 in order to use it for the SVC instruction
	SVC 4
	MOV R0, #10
	SVC 0

	ADD R6, R5, #1 	; year = birth + 1

loop ; while year != present //{

	; this code does print "you were " + str(age) + " in " + str(year)
	ADR R0, were
	SVC 3
	MOV R0, R7 ; We use MOV to copy the value from Register 7 to Register 0 in order to use it for the SVC instruction
	SVC 4
	ADR R0, in
	SVC 3
	MOV R0, R6 ; We use MOV to copy the value from Register 6 to Register 0 in order to use it for the SVC instruction
	SVC 4
	MOV R0, #10
	SVC 0

	ADD R6, R6, #1 		;   year = year + 1 
	ADD R7, R7, #1		;   age = age + 1   

	; Branch condition :
	CMP R6, R4
	BNE loop			; } 

	; this code does print "you are " + str(age) + "this year" 
	ADR R0, are
	SVC 3
	MOV R0, R7 	; We use MOV to copy the value from Register 7 to Register 0 in order to use it for the SVC instruction
	SVC 4
	ADR R0, this
	SVC 3

	; We store back the values from registers to memory, as we store them slowly during execution in part 4 :
	STR R4, present
	STR R5, birth
	STR R6, year
	STR R7, age

	SVC 2 ; stop
	