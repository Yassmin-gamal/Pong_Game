STACK SEGMENT PARA 'STACK'
	DB 64 DUP (' ')
STACK ENDS
DATA SEGMENT PARA 'DATA'
    WINDOW_WIDTH DW 280H ; video mode width
	WINDOW_HEIGHT DW 1E0H	; height 
    WINDOW_BOUNDS DW 6	   ;to check for collisons early
   
    TIME_AUX  DB 0			; save the current second (dl)
    GAME_ACTIVE DB 1                     ;is the game active? (1 -> Yes, 0 -> No (game over))
	WINNER_INDEX DB 0                    ;the index of the winner (1 -> player one, 2 -> player two)
	CURRENT_SCENE DB 0					 ;the index of the current scene (0 -> main menu, 1 -> game)
	EXIT_INDICATOR DB 0					 ; check if you want to exit game
	
    TEXT_PLAYER_ONE_POINTS DB '0','$'    ;text with the player one points
	TEXT_PLAYER_TWO_POINTS DB '0','$'    ;text with the player two points
	TEXT_GAME_OVER_TITLE DB '!GAME OVER!','$' ;text with the game over menu title
	TEXT_GAME_OVER_WINNER DB 'Player 0 won','$' ;text with the winner text
	TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to play again','$'; text with paly again
	TEXT_GAME_OVER_MAIN_MENU DB 'Press E to go to main menu','$' ;text with game over menu message
	TEXT_MAIN_MENU_TITLE DB 'MAIN MENU','$' ;text with the main menu title
	TEXT_MAIN_MENU_SINGLEPLAYER DB 'SINGLEPLAYER - press S','$' ;text with the single player message
	TEXT_MAIN_MENU_MULTIPLAYER DB 'MULTIPLAYER - press M','$' ;text with the multi player message
	TEXT_MAIN_MENU_EXIT DB 'EXIT GAME - press E','$'   ;text with exit game message
	
	BALL_X  DW 0AH 			; current x position of the ball
	BALL_Y DW 0AH 			; current y position of the ball

	BALL_SIZE DW 09H			; ball size (how many pixels in hieght and width)

	BALL_ORIGINAL_X DW 0A0H 	; intial x position of the ball
	BALL_ORIGINAL_Y DW 64H   	; intial y position of the ball

	BALL_X_VELOCITY DW 09H   	;the ball velocity in x
	BALL_Y_VELOCITY DW 04H  	;the ball velocity in y

	PADDLE_LEFT_X  DW  08H   	;x position of the left paddle
	PADDLE_LEFT_Y DW   0AH	 	;y position of the left paddle
	PLAYER_ONE_POINTS DB 00H  	;points of the left player 

	PADDLE_RIGHT_X DW 271H   	;x position of the right paddle 
	PADDLE_RIGHT_Y DW 0AH    	;y position of the right paddle 
	PLAYER_TWO_POINTS DB 00H 	;points of the right player 
	AI_CONTROL     DW 0h     	;check if user chose single player

	PADDLE_WIDTH  DW 9H			;default paddle width
	PADDLE_HEIGHT DW 4FH    	;default paddle height
	PADDLE_VELOCITY DW 0FH  	;default paddle velocity

DATA ENDS
CODE SEGMENT PARA 'CODE'
	MAIN PROC FAR
	 ASSUME   SS:STACK, DS:DATA, CS:CODE  ;assume as code,data and stack segments the respective registers
     MOV AX, DATA        	 ;set address of data segment in ds
     MOV DS, AX
	
		CALL CLEAR_SCREEN                ;set initial configurations
		CHECK_TIME:
			CMP EXIT_INDICATOR,01H
			JE EXITING_PROCESS
			CMP CURRENT_SCENE,00h
			JE SHOW_MAIN_MENU
			CMP GAME_ACTIVE,00h
			JE SHOW_GAME_OVER
			MOV AH,2Ch 					 ;get the system time
			INT 21h    					 ;CH = hour CL = minute DH = second DL = 1/100 seconds
			add dl,55
			CMP DL,TIME_AUX  			 ;is the current time equal to the previous one(TIME_AUX)?
			JE CHECK_TIME 
			;if it is the same, check again
			;If it reaches this point, it's because the time has passed
  
			MOV TIME_AUX,DL              ;update time
			
			CALL CLEAR_SCREEN            ;clear the screen by restarting the video mode
			
			CALL MOVE_BALL               ;move the ball
			CALL DRAW_BALL               ;draw the ball
			
			CALL MOVE_PADDELS          ;move the two paddles (check for pressing of keys)
			CALL DRAW_PADDELS            ;draw the two paddles with the updated positions
			CALL DRAW_UI
			JMP CHECK_TIME   			 ; check again
            
			SHOW_GAME_OVER:
				CALL DRAW_GAME_OVER_MENU
				JMP CHECK_TIME
			
			SHOW_MAIN_MENU:
				CALL DRAW_MAIN_MENU
				JMP CHECK_TIME
			EXITING_PROCESS:
				CALL EXITING_GAME
		RET
	MAIN ENDP
    
	
	MOVE_BALL PROC NEAR  ;proccess the movement of the ball
		; Move the ball horizontally
	
		MOV AX, BALL_X_VELOCITY
		ADD BALL_X,AX
		
		;       Check if the ball has passed the left boundarie (BALL_X < 0 + WINDOW_BOUNDS)
		;       If is colliding, restart its position

		MOV AX,WINDOW_BOUNDS
		SUB AX,BALL_SIZE
		CMP BALL_X,AX       	;BALL_X is compared with the left boundarie of the screen (0 + WINDOW_BOUNDS) 
		JL GIVE_POINTS_TO_PLAYER_TWO	
		
		MOV AX,WINDOW_WIDTH ; if it's larger than the width 
		SUB AX,BALL_SIZE  ;to prevent the bounce before colliding
		SUB AX,WINDOW_BOUNDS ;to early check before the collisonUNCE
		CMP BALL_X, AX;
		JG GIVE_POINTS_TO_PLAYER_ONE
		JMP MOVE_BALL_VERTICALLY 
		
		GIVE_POINTS_TO_PLAYER_ONE:  				;give one point to the player one and reset ball position
		      INC PLAYER_ONE_POINTS             	;increment player one points
			  CALL UPDATE_TEXT_PLAYER_ONE_POINTS 	 ;update the text of the player one points
			  CALL NEG_X_VELOCITY               	;negate the ball velocity
			  CMP PLAYER_ONE_POINTS,05H        		 ;check player one has reached 5 points
			  JG GAME_OVER                     		 ;if this player points is 5 or more we move to the game over screen
			  RET
			  
		GIVE_POINTS_TO_PLAYER_TWO:						;give one point to the player two and reset ball position
		      INC PLAYER_TWO_POINTS                     ;increment player two points
			  CALL NEG_X_VELOCITY                        ;negate the ball velocity 
			  CALL UPDATE_TEXT_PLAYER_TWO_POINTS        ;update the text of the player two points
			  CMP PLAYER_TWO_POINTS,05H                  ;check player two has reached 5 points
			  JG GAME_OVER                               ;if this player points is 5 or more we move to the game over screen
			
			  RET
			  
	    GAME_OVER:                       ;someone has reached 5 points
			CMP PLAYER_ONE_POINTS,05h    ;check wich player has 5 or more points
			JNL WINNER_IS_PLAYER_ONE     ;if the player one has not less than 5 points is the winner
			JMP WINNER_IS_PLAYER_TWO     ;if not then player two is the winner
			
			WINNER_IS_PLAYER_ONE:
				MOV WINNER_INDEX,01h     ;update the winner index with the player one index
				JMP CONTINUE_GAME_OVER
			WINNER_IS_PLAYER_TWO:
				MOV WINNER_INDEX,02h     ;update the winner index with the player two index
				JMP CONTINUE_GAME_OVER
				
			CONTINUE_GAME_OVER:
				MOV PLAYER_ONE_POINTS,00h   ;restart player one points
				MOV PLAYER_TWO_POINTS,00h  ;restart player two points
				CALL UPDATE_TEXT_PLAYER_ONE_POINTS
				CALL UPDATE_TEXT_PLAYER_TWO_POINTS
				MOV GAME_ACTIVE,00h            ;stops the game
				RET	

			
		    
 ; move the ball vertically
		MOVE_BALL_VERTICALLY :
				MOV AX, BALL_Y_VELOCITY
				ADD BALL_Y,AX
				
				; check for collision if collided we revrse the velocity
				MOV AX,WINDOW_BOUNDS ;to prevent the bounce before colliding
				SUB AX,BALL_SIZE     ; to early check before the collison
				CMP BALL_Y,AX 		 ; if it's less than the value detection (collided)
				JL NEG_VELOCITY_Y
				
				MOV AX,WINDOW_HEIGHT ; if it's larger than the height
				SUB AX,BALL_SIZE
				SUB AX,WINDOW_BOUNDS
				CMP BALL_Y, AX
				JG NEG_VELOCITY_Y
				JMP CHECK_FOR_PADDLE
				NEG_VELOCITY_Y:
					NEG BALL_Y_VELOCITY ;reverse the velocity in Y of the ball (BALL_VELOCITY_Y = - BALL_VELOCITY_Y)
					RET		
				
				;Check if the ball is colliding with the right paddle
				; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
				; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
				; && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
		CHECK_FOR_PADDLE:
				MOV AX,BALL_X
				ADD AX,BALL_SIZE
				CMP AX,PADDLE_RIGHT_X
				JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
				
				MOV AX,PADDLE_RIGHT_X
				ADD AX,PADDLE_WIDTH
				CMP BALL_X,AX
				JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
				
				MOV AX,BALL_Y
				ADD AX,BALL_SIZE
				CMP AX,PADDLE_RIGHT_Y
				JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
				
				MOV AX,PADDLE_RIGHT_Y
				ADD AX,PADDLE_HEIGHT
				CMP BALL_Y,AX
				JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
				
				;If it reaches this point, the ball is colliding with the right paddle
				CALL NEG_X_VELOCITY
				;Check if the ball is colliding with the left paddle
				
		CHECK_COLLISION_WITH_LEFT_PADDLE:
				
				; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
				; BALL_X + BALL_SIZE > PADDLE_LEFT_X && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH 
				; && BALL_Y + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT
				
				MOV AX,BALL_X
				ADD AX,BALL_SIZE
				CMP AX,PADDLE_LEFT_X
				JNG EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
				
				MOV AX,PADDLE_LEFT_X
				ADD AX,PADDLE_WIDTH
				CMP BALL_X,AX
				JNL EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
				
				MOV AX,BALL_Y
				ADD AX,BALL_SIZE
				CMP AX,PADDLE_LEFT_Y
				JNG EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
				
				MOV AX,PADDLE_LEFT_Y
				ADD AX,PADDLE_HEIGHT
				CMP BALL_Y,AX
				JNL EXIT_COLLISION_CHECK  ;if there's no collision exit procedure
				
		;       If it reaches this point, the ball is colliding with the left paddle	
				CALL NEG_X_VELOCITY
	   				 
					
				
				EXIT_COLLISION_CHECK:
					RET
		   
	MOVE_BALL ENDP
	
	
	NEG_X_VELOCITY PROC NEAR
	    NEG BALL_X_VELOCITY
	
		RET
	NEG_X_VELOCITY ENDP
	
	
	MOVE_PADDELS PROC NEAR
		MOV AH,01H
		INT 16H
		JZ CHECK_RIGHT_PADDLE_MOVEMENT ;ZF = 1, JZ -> Jump If Zero
		
		MOV AH,00H
		INT 16H
		;check which key is being pressed (AL = ASCII character)
		
		;if it is 'w' or 'W' move up
		CMP AL,77H	;'w'
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57H	;'W'
		JE MOVE_LEFT_PADDLE_UP
		
	;if it is 's' or 'S' move down
		CMP AL,73h ;'s'
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
			JG  FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			;       Right paddle movement
		
		CHECK_RIGHT_PADDLE_MOVEMENT:
			CMP AI_CONTROL,01H
			JE AI_CONTROL_PANEL
			
		CHECK_FOR_MOVEMENT:
				;if it is 'o' or 'O' move up
			CMP AL,6Fh ;'o'
			JE MOVE_RIGHT_PADDLE_UP
			CMP AL,4Fh ;'O'
			JE MOVE_RIGHT_PADDLE_UP
				
				;if it is 'l' or 'L' move down
			CMP AL,6Ch ;'l'
			JE MOVE_RIGHT_PADDLE_DOWN
			CMP AL,4Ch ;'L'
			JE MOVE_RIGHT_PADDLE_DOWN
			JMP EXIT_PADDLE_MOVEMENT
				
		AI_CONTROL_PANEL:
				;if the ball is above the paddle we move the paddle up
			MOV AX,BALL_Y
			CMP AX,PADDLE_RIGHT_Y
			JL MOVE_RIGHT_PADDLE_UP
				; if the ball is below the paddle we move it down
			MOV AX,PADDLE_RIGHT_Y
			ADD AX,PADDLE_HEIGHT
			SUB AX,09H
			CMP AX,BALL_Y
			JL MOVE_RIGHT_PADDLE_DOWN
				;if neither we exit paddle movement
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
				JG  FIX_PADDLE_RIGHT_BOTTOM_POSITION
				JMP EXIT_PADDLE_MOVEMENT
			
				FIX_PADDLE_RIGHT_BOTTOM_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
			
		    EXIT_PADDLE_MOVEMENT:
				RET
		
	MOVE_PADDELS ENDP
	
	
	DRAW_BALL PROC NEAR
	MOV CX,BALL_X	;set the intial coloumn (x)
	MOV DX,BALL_Y	;set the intial line (y)
	
	DRAW_BALL_HORIZONTAL:
		MOV AH,0CH  ; write pixel
		MOV AL,	0FH ;white
		MOV BH,00H  ; page number
		INT 10H
		
		INC CX		;compare cx to the intial value of the position if it's not greater than ball_size then we itterate once more
		MOV AX,CX  	;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
		SUB AX,BALL_X
		CMP AX,BALL_SIZE
		JNG DRAW_BALL_HORIZONTAL
		
		MOV CX,BALL_X;
		INC DX		; incremnt and compare as well
		MOV AX,DX  	;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
		SUB AX,BALL_Y
		CMP AX,BALL_SIZE
		JNG DRAW_BALL_HORIZONTAL
	
	RET
	DRAW_BALL ENDP
	
	DRAW_PADDELS PROC NEAR
		MOV CX,PADDLE_LEFT_X	;set the intial coloumn (x)
		MOV DX,PADDLE_LEFT_Y	;set the intial line (y)
	
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0CH  	; write pixel
			MOV AL,	0FH 	;white
			MOV BH,00H  	; page number
			INT 10H
			
			INC CX				;compare cx to the intial value of the position if it's not greater than PADDLE_WIDTH then we itterate once more
			MOV AX,CX  			;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X	; the cx register goes to the first column 
			INC DX					; we advance one line 
			MOV AX,DX   			;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
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
	
	DRAW_UI PROC NEAR
		; draw player one points
		MOV AH,02H		;set cursor position
		MOV BH,00H		;set page number
		MOV DH,02H		;set row
		MOV DL,0EH		;set column
		INT 10H
		
		MOV AH,09h                       ;write string to standard output
		LEA DX,TEXT_PLAYER_ONE_POINTS     ;give DX a pointer to text to be displayed 
		INT 21h                          ;print the string
		
		; draw player two points
		MOV AH,02H		;set cursor position
		MOV BH,00H		;set page number
		MOV DH,02H		;set row
		MOV DL,3FH		;set column
		INT 10H
		
		MOV AH,09h                       ;write string to standard output
		LEA DX,TEXT_PLAYER_TWO_POINTS     ;give DX a pointer to text to be displayed 
		INT 21h                          ;print the string
		
		
		RET
	DRAW_UI ENDP
	
	UPDATE_TEXT_PLAYER_ONE_POINTS PROC NEAR
		XOR AX,AX
		MOV AL,PLAYER_ONE_POINTS
		ADD AL,30H
		MOV TEXT_PLAYER_ONE_POINTS,AL
	
	
		RET
	UPDATE_TEXT_PLAYER_ONE_POINTS ENDP
	
	UPDATE_TEXT_PLAYER_TWO_POINTS PROC NEAR
	
		XOR AX,AX
		MOV AL,PLAYER_TWO_POINTS
		ADD AL,30H
		MOV TEXT_PLAYER_TWO_POINTS,AL
		RET
	UPDATE_TEXT_PLAYER_TWO_POINTS ENDP
	
    DRAW_GAME_OVER_MENU PROC NEAR        ;draw the game over menu
    		CALL CLEAR_SCREEN                ;clear the screen before displaying the menu
	;       Shows the menu title
			MOV AH,02h                       ;set cursor position
			MOV BH,00h                       ;set page number
			MOV DH,04h                       ;set row 
			MOV DL,04h						 ;set column
			INT 10h							 
			
			MOV AH,09h                       ;write string to standard output
			LEA DX,TEXT_GAME_OVER_TITLE      ;give DX a pointer to text to be displayed 
			INT 21h                          ;print the string
		;       Shows the winner
			MOV AH,02h                       ;set cursor position
			MOV BH,00h                       ;set page number
			MOV DH,06h                       ;set row 
			MOV DL,04h						 ;set column
			INT 10h							 
			
			CALL UPDATE_WINNER_TEXT
			
			MOV AH,09h                       ;write string to standard output
			LEA DX,TEXT_GAME_OVER_WINNER      ;give DX a pointer to the string TEXT_GAME_OVER_WINNER
			INT 21h                          ;print the string
			
			;       Shows the play again message
			MOV AH,02h                       ;set cursor position
			MOV BH,00h                       ;set page number
			MOV DH,08h                       ;set row 
			MOV DL,04h						 ;set column
			INT 10h							 
			
			MOV AH,09h                       ;write string to standard output
			LEA DX,TEXT_GAME_OVER_PLAY_AGAIN     ;give DX a pointer to the string TEXT_GAME_OVER_PLAY_AGAIN
			INT 21h                          ;print the string
			

			;       Shows the main menu message
			MOV AH,02h                       ;set cursor position
			MOV BH,00h                       ;set page number
			MOV DH,0Ah                       ;set row 
			MOV DL,04h						 ;set column
			INT 10h							 
			
			MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
			LEA DX,TEXT_GAME_OVER_MAIN_MENU     ;give DX a pointer to the string TEXT_GAME_OVER_MAIN_MENU  
			INT 21h                          ;print the string
			
			
			
	;       Waits for a key press
			MOV AH,00h
			INT 16h
			
	;		if the key 'r' or 'R' is pressed, restart game		
			CMP AL,'r'
			JE RESTART_GAME
			CMP AL, 'R'
			JE RESTART_GAME
	;		if the key 'E' or 'e' is pressed, exit main menu
			CMP AL,'E'
			JE EXIT_TO_MAIN_MENU
			CMP AL,'e'
			JE EXIT_TO_MAIN_MENU
			
			RET
			
			RESTART_GAME:
				MOV GAME_ACTIVE,01h
				MOV BALL_X,0A0H  		;restart ball position 
				MOV BALL_Y,64H
				MOV PADDLE_LEFT_X,08H   ;restart left paddle position
				MOV PADDLE_LEFT_Y,0AH
				MOV PADDLE_RIGHT_X,271H  ;restart left paddle position  
				MOV PADDLE_RIGHT_Y,0AH 
				RET
			
			EXIT_TO_MAIN_MENU:
				MOV GAME_ACTIVE,00h
				MOV CURRENT_SCENE,00h
				RET
	DRAW_GAME_OVER_MENU ENDP
	
	DRAW_MAIN_MENU PROC NEAR
	
		CALL CLEAR_SCREEN
;       Shows the menu title
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,04h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;WRITE STRING TO STANDARD OUTPUT
		LEA DX,TEXT_MAIN_MENU_TITLE      ;give DX a pointer to text to be displayed 
		INT 21h          				 ;print the string
		
;       Shows the singleplayer message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,06h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;write string to standard output
		LEA DX,TEXT_MAIN_MENU_SINGLEPLAYER     ;give DX a pointer to text to be displayed 
		INT 21h          				 ;print the string
		
;       Shows the multiplayer message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,08h                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;write string to standard output
		LEA DX,TEXT_MAIN_MENU_MULTIPLAYER     ;give DX a pointer to text to be displayed 
		INT 21h          				 ;print the string

;       Shows the exit message
		MOV AH,02h                       ;set cursor position
		MOV BH,00h                       ;set page number
		MOV DH,0Ah                       ;set row 
		MOV DL,04h						 ;set column
		INT 10h							 
		
		MOV AH,09h                       ;write string to standard output
		LEA DX,TEXT_MAIN_MENU_EXIT       ;give DX a pointer to text to be displayed 
		INT 21h          				 ;print the string
        CHECK_FOR_PRESSED_KEYS:
;       Waits for a key press
			MOV AH,00h
			INT 16h
;       Check which key was pressed
			CMP AL,'S'
			JE START_SINGLEPLAYER_MODE
			CMP AL,'s'
			JE START_SINGLEPLAYER_MODE
			CMP AL,'M'
			JE START_MULTIPLAYER_MODE
			CMP AL,'m'
			JE START_MULTIPLAYER_MODE
			CMP AL,'E'
			JE EXIT_GAME
			CMP AL,'e'
			JE EXIT_GAME
			JMP CHECK_FOR_PRESSED_KEYS
			
			
		START_SINGLEPLAYER_MODE:
			MOV CURRENT_SCENE,01H  ;activate game
			MOV GAME_ACTIVE,01H
			MOV AI_CONTROL,01H     ;activate single player mode
			
		    RET
			
		START_MULTIPLAYER_MODE:
			MOV CURRENT_SCENE,01H  ; activate game 
			MOV GAME_ACTIVE,01H
			MOV AI_CONTROL,00H     ;activate multiplayer mode
			RET
			
		EXIT_GAME:
			MOV EXIT_INDICATOR,01H
			RET
		
	DRAW_MAIN_MENU ENDP
	
	UPDATE_WINNER_TEXT PROC NEAR
		
		MOV AL,WINNER_INDEX              ;if winner index is 1 => AL,1
		ADD AL,30h                       ;AL,31h => AL,'1'
		MOV [TEXT_GAME_OVER_WINNER+7],AL ;update the index in the text with the character
		
		RET
	UPDATE_WINNER_TEXT ENDP
	
	CLEAR_SCREEN PROC NEAR
		MOV AH,00H	;set the configuration to video mode
		MOV AL,11h	; bw color graphics
		INT 10H		; excute interrupt

	RET
	CLEAR_SCREEN ENDP
	
	EXITING_GAME PROC NEAR     ; returns the scene to text mode
	
		MOV AH,00H		;set the configuration to video mode
		MOV AL,00h		; text mode 
		INT 10H	
		
		MOV AH,4Ch      ; to terminate the program  
		INT 21H 
		
	EXITING_GAME ENDP
	
CODE ENDS
END
