STACK SEGMENT PARA 'STACK'
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'

     TIME_AUX DB 0                        ;variable used when checking if the time has changed
     BALL_VELOCITY_X DW 05h               ;X (horizontal) velocity of the ball
	 BALL_VELOCITY_Y DW 02h               ;Y (vertical) velocity of the ball
     BALL_X  DW 0AH ; BALL INTIAL X POSITION
     BALL_Y DW 0AH ; BALL INTIAL Y POSITION
     BALL_SIZE DW 04H; BALL SIZE (HOW MANY PIXELS IN HIEGHT AND WIDTH)
	 
	 
DATA ENDS

CODE SEGMENT PARA 'CODE'
   
  MAIN PROC FAR
	ASSUME CS:CODE,DS:DATA,SS:STACK      ;assume as code,data and stack segments the respective registers
	PUSH DS                              ;push to the stack the DS segment
	SUB AX,AX                            ;clean the AX register
	PUSH AX                              ;push AX to the stack
	MOV AX,DATA                          ;save on the AX register the contents of the DATA segment
	MOV DS,AX                            ;save on the DS segment the contents of AX
	POP AX                               ;release the top item from the stack to the AX register
	POP AX                               ;release the top item from the stack to the AX register
	
	CALL CLEAR_SCREEN                ;set initial video mode configurations
	 
	
	    CHECK_TIME:                      ;time checking loop
		 
			
			MOV AH,2Ch 					 ;get the system time
			INT 21h    					 ;CH = hour CL = minute DH = second DL = 1/100 seconds
			
			CMP DL,TIME_AUX  			 ;is the current time equal to the previous one(TIME_AUX)?
			JE CHECK_TIME    		     ;if it is the same, check again
			
                   ;If it reaches this point, it's because the time has passed
  
			MOV TIME_AUX,DL              ;update time
			
			 CALL CLEAR_SCREEN                ;set initial video mode configurations
			 CALL MOVE_BALL
			 CALL DRAW_BALL
			
		JMP CHECK_TIME               ;after everything checks time again
			
			
			
		RET	
	 MAIN ENDP
	 
	 
	
	    MOVE_BALL PROC NEAR                  ;proccess the movement of the ball
		                       ; Move the ball horizontally
		     MOV AX,BALL_VELOCITY_X    
		     ADD BALL_X,AX                   
		     MOV AX,BALL_VELOCITY_y
		     ADD BALL_y,AX                   
		
		MOVE_BALL ENDP
	
 
		
		CLEAR_SCREEN PROC NEAR               ;clear the screen by restarting the video mode
	
			MOV AH,00h                   ;set the configuration to video mode
			MOV AL,13h                   ;choose the video mode
			INT 10h    					 ;execute the configuration 
		
			MOV AH,0Bh 					 ;set the configuration
			MOV BH,00h 					 ;to the background color
			MOV BL,00h 					 ;choose black as background color
			INT 10h    					 ;execute the configuration
			
			RET
			
	    CLEAR_SCREEN ENDP
	
	
	
	
	
	DRAW_BALL PROC NEAR                  
		
		MOV CX,BALL_X                    ;set the initial column (X)
		MOV DX,BALL_Y                    ;set the initial line (Y)
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch                   ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX          	  		 ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X 				 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX             		 ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
	 
CODE ENDS
END
