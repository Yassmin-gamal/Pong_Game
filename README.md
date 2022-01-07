# Ping-Pong Game

 <h1 align="center">
  <img src="https://user-images.githubusercontent.com/40550247/72228004-81071600-3581-11ea-9972-1cbe906001ed.png" width="120px" />
</h1>


<h1 align="center">
  PingPong 
Artificial Intelligence 
</h1>

## Dependencies
- x86 assembly language
- DOSBox
- x86 emulator

## How to play
At first you shall choose to play in a single mode by pressing '**s**' so choosing the computer to be your second player or multiple mode by pressing '**m**'so you can play it with a friend.

Each player (one could be the computer) controls a paddle by dragging it vertically across the screen's right or left sides.

The first player (the one on the left) drags the left paddle vertically: up by pressing the '**w**' letter and down by pressing the '**s**' letter. 

The second player (the one on the right) drags the left paddle vertically: up by pressing the '**o**' letter and down by pressing the '**l**' letter. In case the second player is the computer you certainly skip pressing the mentioned letters to move the right paddles as the computer is already doing it for you. 

All you have to do to win this game is just scoring your more-than-5-points which you earn by holding your self not making the moving ball to collide with the side you're playing next-to more than 5 times until your friend collects your points for you (of course when the ball collides with the screen side next to him).

Finally when you win and you just liked it enough (we hope) you could press the '**r**' letter to play it again in the same mood you have chosen before or press '**e**' to go back to the main menu (hopefully to try the other mood not to exit). 

And that's it, enjoy your game.



## Quick Start

### Build the game
```console
 masm /a pong.asm
```
 
### Run the game in DOSbox

```console
 link pong
```
### Result 
 
<h1 align="center">
  <img src="https://user-images.githubusercontent.com/66153260/148484162-266b5899-5c49-438f-9e01-799e4aadbc7b.PNG"/>
</h1>

## Controls
1. Main menu
- `S`, `s`- Single Player,
- `M`, `m`- Multi Player ,
- `E`, `e`- Exit,

2. During the game
- `O`, `o`-  MOVE_RIGHT_PADDLE_UP,
- `L`, `l` -  MOVE_RIGHT_PADDLE_DOWN,
- `W`, `W` -  MOVE_LEFT_PADDLE_UP,
- `S`, `s`-  MOVE_LEFT_PADDLE_DOWN,

3. Game over
- `R`, `r` - Play again,
- `E`, `e`-  Go to main menu,
  
## Features
1. Single Player " support Artificial Intelligence"
2. Two Player
<h1 align="center">
  <img  src="https://user-images.githubusercontent.com/66153260/148484362-ffa2fca4-c1da-410b-9614-17170ea67f93.PNG"/>
</h1>


## Support
Thanks to :
1. **Prof. Abdelhamid Attaby**
2. **Eng. Ahmed Bakr**
- we understand assamply language , and implement this Game.


## Authors
1. Yassmin Gamal.
2. Yara Khalid.
3. Menna Swilam.
4. Youssef Hassan.
5. Mahmoud mousad.

