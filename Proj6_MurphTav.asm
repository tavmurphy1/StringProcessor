TITLE Designing Low-Level I/O Procedures     (Proj6_MurphTav.asm)

; Author: Tavner Murphy
; Last Modified: 12/07/23
; OSU email address: murphtav@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6             Due Date: 12/10/23
; Description: This program reinforces concepts related to string primitive
;			instructions and Macros by getting ten signed integers from the user as
;			strings, converting those strings to integers, calculating their sum
;			and truncated average, and finally converting back into strings
;			and printing the array of integers and the results. It does this all
;			without using ReadInt, ReadDec, WriteInt, or WriteDec. All print
;			operations are carried out by a custom macro called mDisplayString.

INCLUDE Irvine32.inc

mGetString MACRO prompt:REQ, output:REQ, max_size:REQ, byte_count:REQ

	mov	 EDX, prompt            ;prompt user
	mDisplayString EDX

	mov  EDX, output		    ;Preconditions of ReadString (1) pointer to string in EDX, (2) Maximum size in ECX
    mov  ECX, BUFFER_SIZE - 1
	call ReadString
	mov	 byte_count, EAX

ENDM

mDisplayString MACRO string_address:REQ

	MOV  EDX, string_address   ;EDX = offset address of first character in string

	call WriteString 		   ;Print the string 

ENDM

BUFFER_SIZE = 256 

CONV_FACTOR = 10

.data

intro_1	    BYTE   "				'Designing Low-Level I/O Procedures' by Tavner Murphy",13,10,0 
 
intro_2	    BYTE   "Please provide 10 signed decimal integers.",13,10
		    BYTE   "Each number needs to be small enough to fit inside a 32 bit register. After you have ",13,10
		    BYTE   "finished inputting the raw numbers I will display a list of the integers, their sum, ",13,10
		    BYTE   "and their average value.",13,10,0

prompt_1    BYTE   "Please enter a signed number: ",0

retort_1    BYTE   "You entered the following numbers: ",13,10,0
retort_2    BYTE   "The sum of these numbers is: ",0
retort_3    BYTE   "The truncated average is: ",0

goodbye1    BYTE   "Thanks for playing!",0

error_1     BYTE   "ERROR: You did not enter a signed decimal integer. Try again.",0
error_2     BYTE   "ERROR: You entered too large of a number. Try again.",0
error_3     BYTE   "ERROR: No input. Try again.",0

space       BYTE   " ",0

str_len     DWORD  ?					;For counting of string length

int_output  SDWORD ?

int_input   SDWORD ?

sum_1       SDWORD ?

average     SDWORD ?

is_negative SDWORD 0

varX        SDWORD 10

str_array   BYTE   256 DUP (?)	        ;numeric input to be entered by the user

num_array   SDWORD 10 DUP (?)

str_output  BYTE   12 DUP ("F")

.code
main PROC

_Introduction:
; -----------------------------
; Prints header and short intro

; Registers changed: EDX
; -----------------------------

	push OFFSET intro_1
	push OFFSET intro_2 
	call Introduction

_getInts:
; -----------------------------
; Calls ReadVal 10x times and
; stores outputs in an array

; Uses ECX for loop counter.
; -----------------------------

	mov	 EDI, OFFSET num_array	;EDI = num_array (SDWORD array size 10)
	mov  ECX, 10				;ECX Loop Counter = 10

_getIntsLoop:
	
	push OFFSET error_3
	push OFFSET error_2
	push OFFSET error_1
	push OFFSET int_output
	push OFFSET prompt_1
	push OFFSET str_array
	push str_len       
	call ReadVal

	MOV  EAX, int_output		;EAX = ReadVal output

	CLD
	STOSD				        ;[EDI] = EAX, EDI += 4
	LOOP _getIntsLoop

_getSum:
; ----------------------------------
; Divides sum by 10 for ten inputs
; and stores in 'average'
; ----------------------------------

	push OFFSET num_array
	push OFFSET sum_1
	call GetSum

_getAverage:
; ----------------------------------
; Divides sum by 10 for ten inputs
; and stores in 'average'
; ----------------------------------
	
	mov  EDX, 0
	MOV  EAX, sum_1
	IDIV varX

	MOV average, EAX            ;Store result in average

_displayInts:
; -------------------------------------
; Calls WriteVal 10x times to convert
; each value of num_array into a string
; and print.
; -------------------------------------
	
	call CrLf
	mDisplayString OFFSET retort_1

	mov	 ESI, OFFSET num_array	;ESI = num_array (SDWORD array size 10)
	mov  ECX, 10				;ECX Loop Counter = 10
	CLD

_dispIntsLoop:

    LODSD						;EAX = [ESI], ESI += 4

	MOV  int_input, EAX		    ;Load EAX into input variable

	push is_negative
	push OFFSET str_output
	push int_input				;SDWORD value
	call WriteVal

	mDisplayString OFFSET space ;Print a space

	mov  is_negative, 0

	LOOP _dispIntsLoop

_displaySum:
; -------------------------------------
; Calls WriteVal to convert 'sum_1'
; into a string and print.
; -------------------------------------

	call CrLf
	mDisplayString OFFSET retort_2

	push is_negative
	push OFFSET str_output
	push sum_1
	call WriteVal

_displayTruncAverage:
; -------------------------------------
; Calls WriteVal to convert 'average'
; into a string and print.
; -------------------------------------

	call CrLf
	mDisplayString OFFSET retort_3

	push is_negative
	push OFFSET str_output
	push average
	call WriteVal
	
	CALL Crlf

_sayGoodbye:
; -------------------------------------
; Calls Goodbye to print a short 
; goodbye message to the user before
; exiting program
; -------------------------------------
	
	PUSH OFFSET goodbye1
	call Goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ------------------------------------------------------------------------------------
; Name: introduction
;
; Description: Prints a header and short introduction to the program
;
; Preconditions: None
;
; Postconditions: intro_1 and intro_2 printed
;
; Receives: intro_1 (reference, input), intro_2 (reference, input)
;				 [EBP+12] = intro_1
;				[EBP+8]   = intro_2
;
; Returns: None
;
; Registers changed: EDX
;
; ------------------------------------------------------------------------------------
Introduction PROC

	PUSH EBP				;Build Stack Frame
	MOV  EBP, ESP  

	PUSH EDX				;Preserve Used Registers

	MOV  EDX, [EBP+12]

	mDisplayString EDX
	call CrLf

	MOV  EDX, [EBP+8]       ;Access intro_2
	mDisplayString EDX
	call CrLf

	POP  EDX			    ;Restore used registers
	POP  EBP
	RET  8


introduction ENDP

; ------------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: Gets user input as string and converts to signed integer
;
;
; Preconditions: None
;
; Postconditions: user input string validated and converted 
;				to signed integer in int_output
;
; Receives: prompt_1 (reference, input/output), str_array (reference, input), 
;			int_output (reference, output), str_len(reference, input),
;			error_1 (reference, output), error_2(reference, output), 
;			error_3 (reference, output)
;				
;				[EBP+32] = error_3
;				[EBP+28] = error_2
;				[EBP+24] = error_1
;				[EBP+20] = int_output (SDWORD)
;				[EBP+16] = prompt_1
;				[EBP+12] = str_array
;				[EBP+8]  = str_len
;
; Returns: int_output holds converted int, outputs error 1 2 or 3 and continues
;	  prompting if the input is invalid
;
; Registers changed: EBP, ESI, EDI, EDI, EAX, EBX, ECX, EDX
;
; -----------------------------------------------------------------------------------
ReadVal PROC

	PUSH  EBP				;Build Stack Frame
	MOV   EBP, ESP  

	PUSHAD					;Preserve registers

	mov   ESI, [EBP+12]		;ESI = OFFSET str_array (user string input)
	mov	  EDI, [EBP+20]		;EDI = int_output (SDWORD passed by value)

_rePrompt:

	mov   ESI, [EBP+12]		;reset ESI pointer

_getString:
; --------------------------------------
; Reads the user input into byte string
; by calling mGetString, then handles
; empty inputs, signed inputs, and 
; invalid inputs with non-digits
; --------------------------------------

	mGetString [EBP+16], [EBP+12], BUFFER_SIZE, [EBP+8]	 

	mov   ECX, [EBP+8]		;ECX = str_len for each new string
    MOV   EDX, 0			;Reset EDX for each new string

	cmp   ECX, 0			;handle an empty input
	je    _noInput
	

	CLD
	LODSB					;AL = ESI, ESI +=1

	DEC   ECX 

	cmp   AL, '-'			;handle a signed integer
	je    _innerLoop

	cmp   AL, '+'		
	je    _innerLoop

	DEC   ESI				;if 1st char isn't a sign, skip over it
	INC   ECX

_innerLoop:
	LODSB					;AL = [ESI], inc ESI

	cmp   AL, '0'			;handles if user input is < '0' 
	jl    _badVal

	cmp   AL, '9'			;handles if user input is > '9'
	jg    _badVal

_goodVal:
; --------------------------------------
; Processes each char into its numeric
; value
; --------------------------------------

	SUB   AL, 48			;AL = AL - '0'

	PUSH  EAX				;Preserve EAX, ECX registers
	PUSH  ECX											 

	MOV   EAX, EDX			;EAX = running total
	MOV   ECX, CONV_FACTOR	;ECX = 10
	MUL   ECX										     
	jo _tooLarge

	MOV   EDX, EAX			;EDX = 10 * EDX

	POP   ECX				;Restore EAX, ECX registers
	POP	  EAX
	
	PUSH  EBX				;Preserve EBX

	MOVSX EBX, AL			;Sign extend AL into EBX
	ADD   EDX, EBX			;EDX = (total * 10) + (stringchar - 48)
	jo    _tooLarge			;jump if carry

	POP   EBX				;Restore EBX

	LOOP  _innerLoop

_checkSign:
; --------------------------------------
; Checks for negatives and handles
; --------------------------------------

	PUSH  ESI				;Preserve ESI and EAX
	PUSH  EAX

	MOV   ESI, [EBP+12]		;reset ESI pointer

	mov   AL, [ESI]
	cmp   AL, '-'			;handle a negative integer
	je    _isNeg

	POP   EAX				;Restore ESI and EAX					
	POP   ESI
	jmp   _isPos

_isNeg:
	POP   EAX
	POP   ESI

	NEG   EDX				;EDX = absolute value of EDX

_isPos:
	PUSH  EAX				;Preserve EAX
	MOV   EAX, EDX

	STOSD					;[EDI] = EAX, EDI += 4

	POP   EAX				;Restore EAX

	jmp   _finish

_badVal:

	call  CrLf
	MOV   EDX, [EBP+24]		;EDX = error_1

	mDisplayString EDX
	mov   EDX, 0

	call  CrLf
	jmp   _rePrompt
	
_tooLarge:
	
	call  CrLf
	MOV   EDX, [EBP+28]		;EDX = error_2

	mDisplayString EDX
	MOV   EDX, 0

	POP   ECX				;Restore used registers
	POP   EAX

	CALL  CrLf
	jmp   _rePrompt

_noInput:
	
	call  CrLf
	mov   EDX, [EBP+32]		;EDX = error_3

	mDisplayString EDX

	CALL  CrLf
	jmp   _rePrompt
	
_finish:

	POPAD					;Restore Used Registers
	POP EBP
	RET 28

ReadVal ENDP

; ------------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: Converts a numeric SDWORD value (input parameter, by value) 
;         to a string of ASCII digits. Invokes the mDisplayString macro to print
;         the ASCII representation of the SDWORD value to the output.
;
;Preconditions:
;				[EBP+16] = is_neg (input/output, value) flag variable initalized to 0
;				[EBP+12] = OFFSET str_output (output, reference) 12x byte array
;				[EBP+8] = int_input (input, value)
;
;Postconditions: OFFSET str_output holds string representation of int_input
;				int_input has been printed as a string
;
;Registers changed: EBP, EDI, ESI, EAX, EBX, ECX, EDX
;
; ------------------------------------------------------------------------------------
WriteVal PROC

	PUSH   EBP				     ;Build Stack Frame
	MOV    EBP, ESP  

	PUSHAD					     ;Preserve Used Registers

	MOV    EDI, [EBP+12]         ;EDI = OFFSET str_output
	MOV    ESI, [EBP+8]          ;ESI = input value
	MOV    ECX, 0			     ;ECX = index of buffer

	CLD						     ;Clear direction flag

    cmp    ESI, 0
    jge    _isPos                ;Jump to positive label if not negative

_isNeg:

	MOV    [EBP+16], DWORD PTR 1 ;Set flag to 1

	NEG    ESI					 ;Get the absolute value

_isPos:

_convertSDWORDtoBytes:
; --------------------------------------
; Converts each digit to its char
; representation and stores in a buffer
; --------------------------------------

	mov   EAX, ESI				 ;Preconditions of DIV (1) Clear EDX, (2)Divisor in EAX
	mov   EDX, 0				 
	mov   EBX, 10			
	DIV   EBX					 ;Postconditions of Div (1)EAX = quotient, (2) EDX = remainder

	mov   EBX, EAX               ;EBX preserves quotient

	MOV   EAX, EDX
	ADD   EAX, '0'				 ;Convert to ASCII char

	PUSH  EAX					 ;Push char onto the stack

	INC   ECX					 ;Increment index

	mov   ESI, EBX
	cmp   ESI, 0
	jne   _convertSDWORDtoBytes
	
	mov   EDI, [EBP+12]			 ;Set EDI to point to beginning of buffer

	MOV   EAX, [EBP+16]			 ;Check the sign flag variable

	cmp   EAX, 0
	jnz   _addNegSign
	jmp   _fillarrayLoop

_addNegSign:
	MOV   AL, '-'				 ;Insert negative sign
	STOSB

_fillarrayLoop:
; ----------------------------------------
; Fills the array by popping all converted
; chars off of the stack and storing in the
; buffer, adding a null terminator
; ----------------------------------------

	POP   EAX					 ;Pop char value off stack and store in array
	STOSB                        
	LOOP  _fillarrayLoop

	MOV   [EDI], BYTE PTR 0      ;Finally, add null terminator

	mDisplayString [EBP+12]		 ;Display final string (output)

_finish:

	POPAD				         ;Restore used Registers
	POP   EBP
	RET   12

WriteVal ENDP

; ------------------------------------------------------------------------------------
; Name: GetSum
;
; Description: Returns the sum of each integer in an input array
;
; Receives:
;				[EBP+8]  = num_array (input, reference)
;				[EBP+12] = sum_1 (output, value)
;				
; Returns: sum_1
;
; Postconditions: sum_1 holds sum of num_array
;
; Registers changed: EBP, ESI, EDI, EAX, ECX
;
; ------------------------------------------------------------------------------------
GetSum PROC

	PUSH   EBP				;Build Stack Frame
	MOV    EBP, ESP  

	PUSHAD					;Preserve registers

	MOV    ESI, [EBP+12]    ;ESI = OFFSET num_array (input, SDWORD array)
	MOV    EDI, [EBP+8]     ;EDI = sum_1 (output, SDWORD)

	MOV    ECX, 9			;Loop Counter = 9 (9 addition operations)

	MOV    EAX, [ESI]

	ADD    ESI, 4

_sumLoop:
	
	ADD    EAX, [ESI]       ;EAX += array element
	ADD    ESI, 4

	LOOP   _sumLoop

	MOV    [EDI], EAX	    ;[EDI] = total sum
	
	POPAD					;Restore registers

	POP    EBP
	RET    8

GETSUM ENDP

; ------------------------------------------------------------------------------------
; Name: Goodbye 
;
; Description: Prints a short goodbye message to the user
;
; Recieves: Goodbye message on top of stack
;			   [EBP+8] = goodbye1
;
; Returns: None
;
; Preconditions: Program has executed
;
; Postconditions: goodbye1 is printed 
;
; Registers changed: EBP, EDX
;
; ------------------------------------------------------------------------------------
Goodbye PROC

	PUSH EBP				;Build Stack Frame
	MOV  EBP, ESP  

	PUSH EDX				;Preserve Used Registers

	CALL CrLf
	MOV  EDX, [EBP+8]
	mDisplayString EDX
	CALL CrLf

	POP  EDX			    ;Restore registers
	POP  EBP
	RET  4

Goodbye ENDP

END main
