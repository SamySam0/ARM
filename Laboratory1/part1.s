; Hello Someone program - version 1

	B main

hello	DEFB	"Hello \0"
goodbye	DEFB	"and good-bye!\n\0"
		ALIGN


main	
	ADR	R0, hello	; printf("Hello ")
	SVC 3

loop	 		; while R0 != 10 {// translate to ARM code
	SVC	1		; input a character to R0
	SVC	0		; output the character in R0

	CMP R0, #10
	BNE loop

	ADR	R0, goodbye 	; printf("and good-bye!")
	SVC	3

	SVC 2				; stop the program
