# Esli's bday vn

## Scene 1

bgi Rose.png
clear
clear chars

bgm KouyaoArukePiano.mp3 plays at -10db
bgm goes to 20 db
sfx vineboom.mp3 plays at -10db

Character 1 enters from the left
Character 1 changes into Nanjo.png

Character 2 enters from the right
Character 2 changes into Ed.png

Character 1: Hello, [i]italic[/i] [b]bold[/b] the story.
Character 2: Hiiii [font_size=24]Big text[/font_size] [font=res://fonts/CyberpunkWaifus.ttf]skibidi[/font]

<!-- Narrator: This is a comment. -->
Narrator: really spooky
clear chars
<!-- you MUST introduce the characters again if you clear chars -->
bgm KouyaoArukePiano.mp3 pauses
bgm nothingisbutwhatisnot.mp3 plays from 10 sec
pause for 2 sec
bgm stops
bgm KouyaoArukePiano.mp3 resumes
<!-- wont save the position of nothingisbutwhatisnot, also will override the audio volume with new volume-->
bgm KouyaoArukePiano.mp3 resumes

* Option 1: [Go to the forest](#scene-2)
* Option 2: [Stay in town](#scene-3)

## Scene 2

bgi Forest.jpg
clear
clear chars

Character 1 enters from the right
<!-- By default, left sprite is at 0,0, right sprite is at 1024, 0, both have a scale of 700, 1000 -->
right sprite translates to 700, 0
right sprite scales to 100, 100
Character 1 changes into Nanjo.png

Character 1: You decided to go to the forest.
Character 1 moves to the left
<!-- this will NOT carry over the transforms -->
bgm nothingisbutwhatisnot.mp3 plays from 10 sec
wait for click
clear sprites

hide textbox
fullscreen effect show Image sprites/Ed.png
pause for 1 sec
<!-- no support for 1 min 1 hour etc, this just tells you what the units are -->
show textbox
fullscreen effect hide Image sprites/Ed.png
fullscreen effect show Image backgrounds/Metaworld.png at 100 100 sized 500 500
fullscreen effect show YakuzaRadial
pause for 1 sec
fullscreen effect hide Image backgrounds/Metaworld.png
fullscreen effect show Titlecard [font_size=100]skibidi test[/font_size]
<!-- hide specificity must always be lesser than or equal to the specificity of the corresponding show, i.e. im just checking if its a substring :skull:-->
fullscreen effect hide YakuzaRadial

Character 1: not a whole lot here now is there
fullscreen effect hide Titlecard [font_size=100]skibidi test[/font_size]
Character 1: What: The: Hell


* Option 1: [Go deeper into the forest](#scene-4)
* Option 2: [Go back to the crossroads](#scene-1)

## Scene 3

bgi Rose.png
bgm tsurupettan.mp3 plays at -20db
clear
clear chars
Character 1: You decided to stay in town.
clear
fullscreen effect show Danmu happyyy birthdayyyyy esliiii|Slappy turd day dumbass (love meep)|[img]res://images/sprites/ups.webp[/img]|Epic Greek Birthday. Word.|Happy Birthday Mr. Elsi|[b]TAKE THAT![/b] Happy Birthday Esli!!!!  Love, Gil
credits roll
[font_size=96]
skibidi
awesome
great
gort
pink
edward
goof
mepea
meeee
godot engine
raul
awesome people
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
Reg Moss, aka Alexander Dimitriou, resident of 39.70810705498792, 19.702100145879694
[/font_size]
