STACK SEGMENT PARA 'STACK'
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
   WINDOW_WIDTH DW 140H 	; video mode width
   WINDOW_HEIGHT DW 0C8H 	; height 
   WINDOW_BOUNDS  DW 6	    ;to check for collisons early
   
   TIME_VAR  DB 0			; save the current second (dl)
   
   BALL_X  DW 0AH 			; current x position of the ball
   BALL_Y DW 0AH 			; current y position of the ball
   
   BALL_SIZE DW 04H			; ball size (how many pixels in hieght and width)
   
   BALL_ORIGINAL_X DW 0A0H 	; intial x position of the ball
   BALL_ORIGINAL_Y DW 64H   ; intial y position of the ball
   
   BALL_X_VELOCITY DW 05H   ;the ball velocity in x
   BALL_Y_VELOCITY DW 02H  
   
   PADDLE_LEFT_X  DW  0AH   ;x position of the left paddle
   PADDLE_LEFT_Y DW   0AH	
	
   PADDLE_RIGHT_X DW 130H   
   PADDLE_RIGHT_Y DW 0AH    ;y position of the right paddle 
   
   PADDLE_WIDTH  DW 05H
   PADDLE_HEIGHT DW 1FH
   PADDLE_VELOCITY DW 05H
   
DATA ENDS
CODE SEGMENT PARA 'CODE'
	MAIN PROC FAR
	 ASSUME   SS:STACK, DS:DATA, CS:CODE
     MOV AX, DATA         ;set address of data segment in ds
     MOV DS, AX
	CALL CLEAR_SCREEN
	
		CHECK_TIME:
			MOV AH, 2CH; get time mode int 21h
			INT 21H; ch=hour cl= minutes dh=seconds dl= 1/100seconds
			
			CMP DL,TIME_VAR; if they're equal compare again
			JE CHECK_TIME
			
			MOV TIME_VAR,DL
			
			
			CALL CLEAR_SCREEN ;clear screen before drawing another ball
			CALL MOVE_BALL    ;move ball to new position
			CALL DRAW_BALL    ;draw every 1/100 of a seconds
			CALL MOVE_PADDELS
			CALL DRAW_PADDELS ; draw the two paddels
			
			JMP CHECK_TIME    ; check again
	RET
	MAIN ENDP
	
	MOVE_BALL PROC NEAR
	
		MOV AX, BALL_X_VELOCITY
		ADD BALL_X,AX
		
		MOV AX,WINDOW_BOUNDS
		SUB AX,BALL_SIZE
		CMP BALL_X,AX       ; if it's less than the value detection (collided)
		JL RESET_BALL_ORGINAL 
		
		MOV AX,WINDOW_WIDTH ; if it's larger than the width 
		SUB AX,BALL_SIZE  ;to prevent the bounce before colliding
		SUB AX,WINDOW_BOUNDS ;to early check before the collisonUNCE
		CMP BALL_X, AX;
		JG RESET_BALL_ORGINAL

		MOV AX, BALL_Y_VELOCITY
		ADD BALL_Y,AX
		
		MOV AX,WINDOW_BOUNDS ;to prevent the bounce before colliding
		SUB AX,BALL_SIZE     ; to early check before the collison
		CMP BALL_Y,AX 		 ; if it's less than the value detection (collided)
		JL RESET_BALL_ORGINAL  
		
		MOV AX,WINDOW_HEIGHT ; if it's larger than the width 
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_Y, AX;
		JG RESET_BALL_ORGINAL
		
		RET
	   
	MOVE_BALL ENDP
	
	RESET_BALL_ORGINAL PROC NEAR
	    MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
		RET
	RESET_BALL_ORGINAL ENDP
	
	MOVE_PADDELS PROC NEAR
	
		;left paddle movement
		
		;check if any key is being pressed (if not check the other paddle)
		MOV AH,01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT ;if = 1, jz -> jump if zero
		
		;check which key is being pressed (AL = ASCII character of key being pressed)
		MOV AH,00h
		INT 16H
		
		;if it is 'w' or 'W' move up
		CMP AL,77h ;77 is 'w' in ASCII
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57h ;'W'
		JE MOVE_LEFT_PADDLE_UP
		
		;if it is 's' or 'S' move down
		CMP AL,73h ;73 is 's' in ASCII
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL,53h ;'S'
		JE MOVE_LEFT_PADDLE_DOWN
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		MOVE_LEFT_PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y,AX
			
			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y,AX
			JL FIX_PADDLE_LEFT_TOP_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV AX,WINDOW_BOUNDS
				MOV PADDLE_LEFT_Y,AX 
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
		
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y,AX
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT	
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
				
		
		;right paddle movement
		CHECK_RIGHT_PADDLE_MOVEMENT:
		
			;if it is 'o' or 'O' move up
			CMP AL,6Fh ;6F is 'o' in ASCII
			JE MOVE_RIGHT_PADDLE_UP
			CMP AL,4Fh ;'O'
			JE MOVE_RIGHT_PADDLE_UP
			
			;if it is 'l' or 'L' move down
			CMP AL,6Ch ;73 is 'l' in ASCII
			JE MOVE_RIGHT_PADDLE_DOWN
			CMP AL,4Ch ;'L'
			JE MOVE_RIGHT_PADDLE_DOWN
			JMP EXIT_PADDLE_MOVEMENT
			
			MOVE_RIGHT_PADDLE_UP:
				
				MOV AX,PADDLE_VELOCITY
				SUB PADDLE_RIGHT_Y,AX
				
				MOV AX,WINDOW_BOUNDS
				CMP PADDLE_RIGHT_Y,AX
				JL FIX_PADDLE_RIGHT_TOP_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
			FIX_PADDLE_RIGHT_TOP_POSITION:
				MOV PADDLE_RIGHT_Y,AX 
				JMP EXIT_PADDLE_MOVEMENT
			
			MOVE_RIGHT_PADDLE_DOWN:
			
				MOV AX,PADDLE_VELOCITY
				ADD PADDLE_RIGHT_Y,AX
				MOV AX,WINDOW_HEIGHT
				SUB AX,WINDOW_BOUNDS
				SUB AX,PADDLE_HEIGHT
				CMP PADDLE_RIGHT_Y,AX
				JG FIX_PADDLE_RIGHT_BOTTOM_POSITION
				JMP EXIT_PADDLE_MOVEMENT	
				
			FIX_PADDLE_RIGHT_BOTTOM_POSITION:
				MOV PADDLE_RIGHT_Y,AX
				JMP EXIT_PADDLE_MOVEMENT
			
		   EXIT_PADDLE_MOVEMENT:
				RET
	MOVE_PADDELS ENDP
	
	DRAW_BALL PROC NEAR
	MOV CX,BALL_X;set the intial coloumn (x)
	MOV DX,BALL_Y;set the intial line (y)
	
	DRAW_BALL_HORIZONTAL:
		MOV AH,0CH  ; write pixel
		MOV AL,	0FH ;white
		MOV BH,00H  ; page number
		INT 10H
		
		INC CX		;compare cx to the intial value of the position if it's not greater than ball_size then we itterate once more
		MOV AX,CX  ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
		SUB AX,BALL_X
		CMP AX,BALL_SIZE
		JNG DRAW_BALL_HORIZONTAL
		
		MOV CX,BALL_X;
		INC DX		; incremnt and compare as well
		MOV AX,DX  ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
		SUB AX,BALL_Y
		CMP AX,BALL_SIZE
		JNG DRAW_BALL_HORIZONTAL
	
	RET
	DRAW_BALL ENDP
	
	DRAW_PADDELS PROC NEAR
		MOV CX,PADDLE_LEFT_X;set the intial coloumn (x)
		MOV DX,PADDLE_LEFT_Y;set the intial line (y)
	
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0CH  ; write pixel
			MOV AL,	0FH ;white
			MOV BH,00H  ; page number
			INT 10H
			
			INC CX		;compare cx to the intial value of the position if it's not greater than PADDLE_WIDTH then we itterate once more
			MOV AX,CX  ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X; the cx register goes to the first column 
			INC DX		; we advance one line 
			MOV AX,DX   ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
	    MOV CX,PADDLE_RIGHT_X;set the intial coloumn (x)
		MOV DX,PADDLE_RIGHT_Y;set the intial line (y)
	
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0CH  ; write pixel
			MOV AL,	0FH ;white
			MOV BH,00H  ; page number
			INT 10H
			
			INC CX		;compare cx to the intial value of the position if it's not greater than PADDLE_WIDTH then we itterate once more
			MOV AX,CX  ;CX - PADDLE_RIGHT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X; the cx register goes to the first column 
			INC DX		; we advance one line 
			MOV AX,DX   ;DX - PADDLE_RIGHT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
	
		RET
	DRAW_PADDELS ENDP
	
	CLEAR_SCREEN PROC NEAR  ;clear the screen by resiting the video mode
	
			MOV AH,00H	; set video mode
			MOV AL,13H	; 256 color graphics
			INT 10H		; excute interrupt
			
			MOV AH, 0Bh ; scroll up function
			MOV BH, 00h ; black
			MOV BL, 00h ; black
			INT 10H
			
			MOV AH,0CH	; write pixel
			MOV AL,	0FH	;white
			MOV BH,00H	; page number
			
			RET
	CLEAR_SCREEN ENDP
CODE ENDS
END
