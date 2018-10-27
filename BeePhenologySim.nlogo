;BeePhenologySim v1.0.1 10/16/2018
;This Simulation tests how two Species of Bees
;interact with different flowers based on the Bee's preferences
;The flowers also bloom over time over the simulation of different seasons
;The flowers start as seeds and can bloom at different times
;Bees are produced in proportion to the amount of nectar they collect and store

;Global Variables that all Breeds can see
globals []

;Defined Breeds [pural singular]
breed [seeds seed]
breed [bees bee]
breed [flowers flower]
breed [hives hive]

;attributes of all breeds
turtles-own [
  species
  age
]

;attributes of Bees
bees-own [
  chosen-flower
  previous-flower
  destination
  home-hive
  current-flower
  carry-nectar
]

;attributes of Seeds
seeds-own [
  lifespan
  nectar-regeneration
  start-of-bloom
]

flowers-own [
  lifespan
  nectar-regeneration
  flower-nectar
]
patches-own [has-seed?]

hives-own [
  producing-bees
  season-start
  season-end
  storage-nectar
]


;Reset the sliders to default values
to defaults
  set starting-number-of-bees 30
  set bee-vision-length 7
  set bee-vision-degrees 45


  set Bee1-Pref-Pinene 80
  set Bee1-Pref-Limonene 60
  set Bee1-Pref-Ocimene 35
  set Bee1-Pref-Benzaldehyde 20
  set Bee1-start-reproduction 500
  set Bee1-end-reproduction 3500

  set Bee2-Pref-Pinene 10
  set Bee2-Pref-Limonene 60
  set Bee2-Pref-Ocimene 40
  set Bee2-Pref-Benzaldehyde 20
  set Bee2-start-reproduction 500
  set Bee2-end-reproduction 4000

  set number-of-Pinene 100
  set number-of-Limonene 100
  set number-of-Ocimene 100
  set number-of-Benzaldehyde 100

  set Pinene-nectar-regeneration 10
  set Limonene-nectar-regeneration 8
  set Ocimene-nectar-regeneration 5
  set Benzaldehyde-nectar-regeneration 5

  set lifespan-Pinene 2500
  set lifespan-Limonene 2500
  set lifespan-Ocimene 2500
  set lifespan-Benzaldehyde 2500

  set start-of-bloom-Pinene 3000
  set start-of-bloom-Limonene 1000
  set start-of-bloom-Ocimene 3000
  set start-of-bloom-Benzaldehyde 500
end

;On set up button press
to setup
  clear-all
  reset-ticks
  setup-patches
  make-seeds
  make-hives
end

;set all patches to have no seeds and change the color
to setup-patches
  ask patches [
    set pcolor green - 3
    set has-seed? FALSE
  ]
end

;make the hives for the bees
to make-hives
  let i 1
  repeat 2 [
    create-hives 1 [
      setxy random-xcor random-ycor
      set size 5
      set shape "beehive"
      ifelse i = 1 [set color orange] [set color yellow]
      set storage-nectar 0
      set species i
      ; additionally set the time variables for the hives that are controlled with sliders
      ifelse i = 1 [
        set color orange
        set season-start Bee1-start-reproduction
        set season-end Bee1-end-reproduction
      ]
      [
        set color yellow
        set season-start Bee2-start-reproduction
        set season-end Bee2-end-reproduction
      ]
      set producing-bees false
    ]
    set i i + 1
  ]
end

;randomly plant seeds in the area
to make-seeds
  ask n-of number-of-Pinene patches with [has-seed? = FALSE]
    [
    sprout-seeds 1 [
      set color white
      set size 1
      set species 1
      set shape "circle"
      set lifespan lifespan-Pinene
      set nectar-regeneration Pinene-nectar-regeneration
      set start-of-bloom start-of-bloom-Pinene
    ]
    set has-seed? TRUE
  ]
   ask n-of number-of-Limonene patches with [has-seed? = FALSE]
  [
    sprout-seeds 1 [
      set color red
      set size 1
      set shape "circle"
      set species 2
      set lifespan lifespan-Limonene
      set nectar-regeneration Limonene-nectar-regeneration
      set start-of-bloom start-of-bloom-Limonene
    ]
    set has-seed? TRUE
  ]
  ask n-of number-of-Ocimene patches with [has-seed? = FALSE]
  [
    sprout-seeds 1 [
      set color cyan
      set size 1
      set species 3
      set shape "circle"
      set lifespan lifespan-Ocimene
      set nectar-regeneration Ocimene-nectar-regeneration
      set start-of-bloom start-of-bloom-Ocimene
    ]
    set has-seed? TRUE
  ]
  ask n-of number-of-Benzaldehyde patches with [has-seed? = FALSE]
  [
    sprout-seeds 1 [
      set color green
      set size 1
      set species 4
      set shape "circle"
      set lifespan lifespan-Benzaldehyde
      set nectar-regeneration Benzaldehyde-nectar-regeneration
      set start-of-bloom start-of-bloom-Benzaldehyde
    ]
    set has-seed? TRUE
  ]
end

;run the simulation
to go
  if (ticks + 1) mod 5000 = 0 [new-season]
  flowers-bloom
  make-nectar
  ask bees [
  if chosen-flower = NOBODY [
  choose-flower
  ]]

  ; A new implementation of how to make bees. This way, no bees will be made out of the hives specific season
  ask hives [
   if producing-bees = true[
      make-new-bees
   ]
   if ticks mod 5000 = season-start[
      set producing-bees true
      make-bees
   ]
   if ticks mod 5000 = season-end[
      set producing-bees false
   ]
  ]


  move-bees
  collect-nectar
  bees-go-back-to-hive
  flowers-age
  bees-grow
  tick
end

;at tick 5000, kill everything and replant seeds
to new-season
  ;remove the make-new-bees from this method
  show "got to new season"
  ask flowers[die]
  ask bees [die]
  setup-patches
  make-seeds
end

;spawn a flower with
to flowers-bloom
  ask seeds [
    if ticks mod 5000 > start-of-bloom
     [if random 1000 < 7
        [hatch-a-flower
         die]
      ]
  ]
end

to hatch-a-flower  ;this is a seeds routine
  hatch-flowers 1
     [set shape "flower"
        set size 2
        set flower-nectar 0
        set age 0
      ]
end  ; end hatch-a-flower

;check if flowers should die (only if their age is greater than their lifespan)
to flowers-age
  ask flowers [
    if age > lifespan
      [die
      ]

  ]
end

to make-nectar
  ask flowers [
    set age age + 1
    if flower-nectar < 100 [
      set flower-nectar flower-nectar + nectar-regeneration
    ]
  ]
end

; Alter make-bees and make-new-bees to become hive methods instead of observer methods by removing "ask hives" and placing the calls to these methods within an "ask hives" statement
to make-bees
    hatch-bees starting-number-of-bees [
      set home-hive myself
      set size 1
      set shape "bee"
      set color [color] of myself
      set age 0
      set carry-nectar 0
      set chosen-flower NOBODY
      set previous-flower NOBODY
      set destination NOBODY
    ]
end


to choose-flower
; if there is a bee already on the flower, choose another. Make bee sit there for a bit.
; check again when they get to the flower
; call flower occupancy first
  let temp-flower previous-flower
  let flower-list flowers in-cone bee-vision-length bee-vision-degrees with [self != temp-flower]   ;Liz added cone-length cone-degrees and sliders
  if any? flower-list
  [
    let species-seen sort remove-duplicates [species] of flower-list
    let best-species 0
    foreach species-seen [i -> if prob-species i > prob-species best-species
      [set best-species i]]
    let best-flower one-of (flower-list with [species = best-species])
    set destination best-flower
    set chosen-flower best-flower

  ]
end

;bees collect nectar
to collect-nectar
  ask bees [
    if chosen-flower != NOBODY [
      if distance chosen-flower < 1 [
        move-to chosen-flower

        set carry-nectar carry-nectar + [flower-nectar] of chosen-flower
        ask chosen-flower [
          set flower-nectar 0
          ]
        set previous-flower chosen-flower
        set chosen-flower NOBODY
        set destination NOBODY
      ]
    ]
  ]
end



;have the bees teleport to the hive if they've collected over 200 units of nectar
to bees-go-back-to-hive
  ask bees [
    if carry-nectar > 200 [
      move-to home-hive
      ask home-hive [ set storage-nectar storage-nectar + 200 ]
      set carry-nectar carry-nectar - 200
      set heading random 360
    ]
  ]
end




;Have hives make new bees when nectar is above the threshhold and is the right season
to make-new-bees
    while [storage-nectar > 2500 and ticks mod 5000 < season-end] [ ; replace 4000 with the new season-end variable
      set storage-nectar storage-nectar - 2500
      hatch-bees 1 [
        set home-hive myself
        set size 1
        set shape "bee"
        set color [color] of myself
        set age 0
        set carry-nectar 0
        set chosen-flower NOBODY
        set previous-flower NOBODY
        set destination NOBODY
        set heading random 360
      ]
    ]
end

;moving bees only of they are not currently collecting nectar
to move-bees
    ask bees [
      ifelse destination = NOBODY [right (60 - random 120)]
      [face destination]
      forward 1
  ]
end


;bees grow and die if they've live for more than 1000 ticks
to bees-grow
  let life 1000
  ask bees [
    set age age + 1
    if age > life and random 100 < 1 [
      die
    ]
  ]
end


to-report prob-species [spnum]
  if species = 1 [
  if spnum = 0 [report 0]
  if spnum = 1 [report Bee1-Pref-Pinene]
  if spnum = 2 [report Bee1-Pref-Limonene]
  if spnum = 3 [report Bee1-Pref-Ocimene]
  if spnum = 4 [report Bee1-Pref-Benzaldehyde]
  ]
  if species = 2 [
   if spnum = 0 [report 0]
  if spnum = 1 [report Bee2-Pref-Pinene]
  if spnum = 2 [report Bee2-Pref-Limonene]
  if spnum = 3 [report Bee2-Pref-Ocimene]
  if spnum = 4 [report Bee2-Pref-Benzaldehyde]
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
279
13
740
475
-1
-1
7.43
1
10
1
1
1
0
1
1
1
-30
30
-30
30
1
1
1
ticks
30.0

BUTTON
9
12
84
78
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
91
12
168
77
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
749
38
987
71
number-of-Pinene
number-of-Pinene
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
313
552
537
585
starting-number-of-bees
starting-number-of-bees
1
30
30.0
1
1
NIL
HORIZONTAL

BUTTON
176
13
250
78
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
306
480
440
513
show-energy?
show-energy?
1
1
-1000

PLOT
760
401
1118
551
Flower Population
Time
Number of Flowers
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Pinene" 1.0 0 -1184463 true "" "plot count flowers with [species = 1]"
"Limonene" 1.0 0 -2674135 true "" "plot count flowers with [species = 2]"
"Ocimene" 1.0 0 -11221820 true "" "plot count flowers with [species = 3]"
"Benzaldehyde" 1.0 0 -10899396 true "" "plot count flowers with [species = 4]"

SLIDER
1018
38
1280
71
number-of-Limonene
number-of-Limonene
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
1016
232
1271
265
number-of-Benzaldehyde
number-of-Benzaldehyde
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
743
231
990
264
number-of-Ocimene
number-of-Ocimene
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
749
74
986
107
Pinene-nectar-regeneration
Pinene-nectar-regeneration
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
1012
73
1280
106
Limonene-nectar-regeneration
Limonene-nectar-regeneration
0
10
8.0
1
1
NIL
HORIZONTAL

SLIDER
747
273
993
306
Ocimene-nectar-regeneration
Ocimene-nectar-regeneration
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
1016
274
1274
307
Benzaldehyde-nectar-regeneration
Benzaldehyde-nectar-regeneration
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
747
107
985
140
start-of-bloom-Pinene
start-of-bloom-Pinene
0
4000
3000.0
100
1
NIL
HORIZONTAL

SLIDER
1016
108
1281
141
start-of-bloom-Limonene
start-of-bloom-Limonene
0
4000
1000.0
50
1
NIL
HORIZONTAL

SLIDER
747
312
993
345
start-of-bloom-Ocimene
start-of-bloom-Ocimene
0
4000
3000.0
100
1
NIL
HORIZONTAL

SLIDER
1017
311
1278
344
start-of-bloom-Benzaldehyde
start-of-bloom-Benzaldehyde
0
4000
500.0
100
1
NIL
HORIZONTAL

SLIDER
750
142
986
175
lifespan-Pinene
lifespan-Pinene
0
3000
2500.0
100
1
NIL
HORIZONTAL

SLIDER
1016
146
1278
179
lifespan-Limonene
lifespan-Limonene
0
3000
2500.0
100
1
NIL
HORIZONTAL

SLIDER
748
348
990
381
lifespan-Ocimene
lifespan-Ocimene
0
3000
2500.0
100
1
NIL
HORIZONTAL

SLIDER
1017
350
1275
383
lifespan-Benzaldehyde
lifespan-Benzaldehyde
0
3000
2500.0
100
1
NIL
HORIZONTAL

PLOT
762
553
1118
703
Total Flower Nectar Content
time
nectar
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Pinene" 1.0 0 -1184463 true "" "let fl1 count flowers with [species = 1]\nifelse fl1 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 1]\nplot-pen-down]\n[plot-pen-up]"
"Limonene" 1.0 0 -2674135 true "" "let fl1 count flowers with [species = 2]\nifelse fl1 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 2]\nplot-pen-down]\n[plot-pen-up]"
"Ocimene" 1.0 0 -11221820 true "" "let fl1 count flowers with [species = 3]\nifelse fl1 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 3]\nplot-pen-down]\n[plot-pen-up]"
"Benzaldehyde" 1.0 0 -10899396 true "" "let fl1 count flowers with [species = 4]\nifelse fl1 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 4]\nplot-pen-down]\n[plot-pen-up]"

SLIDER
4
115
271
148
Bee1-Pref-Pinene
Bee1-Pref-Pinene
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
4
151
271
184
Bee1-Pref-Limonene
Bee1-Pref-Limonene
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
6
186
272
219
Bee1-Pref-Ocimene
Bee1-Pref-Ocimene
0
100
35.0
1
1
NIL
HORIZONTAL

SLIDER
4
224
271
257
Bee1-Pref-Benzaldehyde
Bee1-Pref-Benzaldehyde
0
100
20.0
1
1
NIL
HORIZONTAL

PLOT
1122
401
1411
551
Bee Population
Time
Number of Bees
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"species 1" 1.0 0 -817084 true "" "plot count bees with [species =  1]"
"species 2" 1.0 0 -1184463 true "" "plot count bees with [species = 2]"

SLIDER
7
388
283
421
Bee2-Pref-Pinene
Bee2-Pref-Pinene
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
6
427
282
460
Bee2-Pref-Limonene
Bee2-Pref-Limonene
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
6
465
281
498
Bee2-Pref-Ocimene
Bee2-Pref-Ocimene
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
5
503
281
536
Bee2-Pref-Benzaldehyde
Bee2-Pref-Benzaldehyde
0
100
20.0
1
1
NIL
HORIZONTAL

PLOT
1121
554
1410
703
Hive Nectar
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Hive 1" 1.0 0 -955883 true "" "let hive1 hives with [species = 1]\nifelse any? hive1 \n[plotxy ticks mean [storage-nectar] of hives with [species = 1]\nplot-pen-down]\n[plot-pen-up]"
"Hive 2" 1.0 0 -1184463 true "" "let hive2 hives with [species = 2]\nifelse any? hive2 \n[plotxy ticks mean [storage-nectar] of hives with [species = 2]\nplot-pen-down]\n[plot-pen-up]"

SLIDER
4
259
269
292
Bee1-start-reproduction
Bee1-start-reproduction
0
1000
500.0
100
1
NIL
HORIZONTAL

SLIDER
5
543
282
576
Bee2-start-reproduction
Bee2-start-reproduction
0
1000
500.0
100
1
NIL
HORIZONTAL

SLIDER
4
296
270
329
Bee1-end-reproduction
Bee1-end-reproduction
1000
5000
3500.0
100
1
NIL
HORIZONTAL

SLIDER
8
579
284
612
Bee2-end-reproduction
Bee2-end-reproduction
1000
5000
4000.0
100
1
NIL
HORIZONTAL

SLIDER
312
588
538
621
bee-vision-length
bee-vision-length
1
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
312
622
537
655
bee-vision-degrees
bee-vision-degrees
0
360
45.0
1
1
NIL
HORIZONTAL

BUTTON
545
484
672
518
Reset-Sliders
defaults
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
91
97
241
115
Bee 1 Variables
12
0.0
1

TEXTBOX
356
540
506
558
Bee Common Variables
12
0.0
1

TEXTBOX
87
372
237
390
Bee 2 Variables
12
0.0
1

TEXTBOX
809
16
959
34
Pinene Variables
12
0.0
1

TEXTBOX
1085
20
1235
38
Limonene Variables
12
0.0
1

TEXTBOX
806
209
956
227
Ocimene Variables\n
12
0.0
1

TEXTBOX
1072
214
1222
232
Benzaldehyde Variables
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This Simulation tests how two Species of Bees interact with different flowers based on  Bee's preferences set by the user. In addition, every 5000 ticks starts a "new season" where the flower locations reset. The flower types also bloom at different times.

This simulation also allows the bee population to be proportional to the amount of nectar they collect the previous season.

## HOW IT WORKS

Using the sliders, you can alter:

Bee Vision Length and Angle
Bee start and end time for collecting nectar (2 for each Bee type)

The starting number of bees per hive
The preference percentage each Bee has to each type of flower

The starting number of each flower type
How fast each flower type can produce nectar
How long it takes for each flower type to bloom
How long each flower type stays live


## THINGS TO NOTICE

What happens at after each season?
Is it possible that one type of Bee dies out but the other survive?

## RELATED MODELS

OccupiedSim
PollinationSim

## CREDITS AND REFERENCES

Original By Kevin
Modifications by Daniel McDonough & Professor Ryder
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
4
Polygon -1184463 true true 152 149 77 163 67 195 67 211 74 234 85 252 100 264 116 276 134 286 151 300 167 285 182 278 206 260 220 242 226 218 226 195 222 166
Polygon -16777216 true false 150 149 128 151 114 151 98 145 80 122 80 103 81 83 95 67 117 58 141 54 151 53 177 55 195 66 207 82 211 94 211 116 204 139 189 149 171 152
Polygon -7500403 true false 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
Polygon -16777216 true false 70 185 74 171 223 172 224 186
Polygon -16777216 true false 67 211 71 226 224 226 225 211 67 211
Polygon -16777216 true false 91 257 106 269 195 269 211 255
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100

bee 2
true
0
Polygon -955883 true false 195 150 105 150 90 165 90 225 105 270 135 300 165 300 195 270 210 225 210 165 195 150
Rectangle -16777216 true false 90 165 212 185
Polygon -16777216 true false 90 207 90 226 210 226 210 207
Polygon -16777216 true false 103 266 198 266 203 246 96 246
Polygon -955883 true false 120 150 105 135 105 75 120 60 180 60 195 75 195 135 180 150
Polygon -16777216 true false 150 15 120 30 120 60 180 60 180 30
Circle -16777216 true false 105 30 30
Circle -16777216 true false 165 30 30
Polygon -7500403 true true 120 90 75 105 15 90 30 75 120 75
Polygon -16777216 false false 120 75 30 75 15 90 75 105 120 90
Polygon -7500403 true true 180 75 180 90 225 105 285 90 270 75
Polygon -16777216 false false 180 75 270 75 285 90 225 105 180 90
Polygon -7500403 true true 180 75 180 90 195 105 240 195 270 210 285 210 285 150 255 105
Polygon -16777216 false false 180 75 255 105 285 150 285 210 270 210 240 195 195 105 180 90
Polygon -7500403 true true 120 75 45 105 15 150 15 210 30 210 60 195 105 105 120 90
Polygon -16777216 false false 120 75 45 105 15 150 15 210 30 210 60 195 105 105 120 90
Polygon -16777216 true false 135 300 165 300 180 285 120 285

beehive
false
0
Polygon -7500403 true true 75 270 225 270 240 255 240 240 255 225 255 210 270 195 270 180 285 165 285 150 270 135 270 120 255 105 255 90 240 75 240 60 225 45 195 30 165 15 135 15 75 45 60 60 60 75 45 90 45 105 30 120 30 135 15 150 15 165 30 180 30 195 45 210 45 225 60 240 60 255 75 270 120 270 120 210 135 195 165 195 180 210 180 270 120 270
Line -16777216 false 60 240 120 240
Line -16777216 false 180 240 240 240
Line -16777216 false 120 210 45 210
Line -16777216 false 180 210 255 210
Line -16777216 false 30 180 270 180
Line -16777216 false 30 135 270 135
Line -16777216 false 45 105 255 105
Line -16777216 false 60 75 240 75
Line -16777216 false 75 45 225 45
Polygon -16777216 false false 120 270 75 270 60 255 60 240 45 225 45 210 30 195 30 180 15 165 15 150 30 135 30 120 45 105 45 90 60 75 60 60 75 45 135 15 165 15 225 45 240 60 240 75 255 90 255 105 270 120 270 135 285 150 285 165 270 180 270 195 255 210 255 225 240 240 240 255 225 270 180 270 180 210 165 195 135 195 120 210 120 270

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

mouse top
true
0
Polygon -7500403 true true 144 238 153 255 168 260 196 257 214 241 237 234 248 243 237 260 199 278 154 282 133 276 109 270 90 273 83 283 98 279 120 282 156 293 200 287 235 273 256 254 261 238 252 226 232 221 211 228 194 238 183 246 168 246 163 232
Polygon -7500403 true true 120 78 116 62 127 35 139 16 150 4 160 16 173 33 183 60 180 80
Polygon -7500403 true true 119 75 179 75 195 105 190 166 193 215 165 240 135 240 106 213 110 165 105 105
Polygon -7500403 true true 167 69 184 68 193 64 199 65 202 74 194 82 185 79 171 80
Polygon -7500403 true true 133 69 116 68 107 64 101 65 98 74 106 82 115 79 129 80
Polygon -16777216 true false 163 28 171 32 173 40 169 45 166 47
Polygon -16777216 true false 137 28 129 32 127 40 131 45 134 47
Polygon -16777216 true false 150 6 143 14 156 14
Line -7500403 true 161 17 195 10
Line -7500403 true 160 22 187 20
Line -7500403 true 160 22 201 31
Line -7500403 true 140 22 99 31
Line -7500403 true 140 22 113 20
Line -7500403 true 139 17 105 10

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

petals
false
0
Circle -7500403 true true 117 12 66
Circle -7500403 true true 116 221 67
Circle -7500403 true true 41 41 67
Circle -7500403 true true 11 116 67
Circle -7500403 true true 41 191 67
Circle -7500403 true true 191 191 67
Circle -7500403 true true 221 116 67
Circle -7500403 true true 191 41 67
Circle -7500403 true true 60 60 180

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="test bcbees v1" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>count bees = 0</exitCondition>
    <metric>count bees with [species = 1]</metric>
    <metric>[nectar] of hives</metric>
    <enumeratedValueSet variable="sp3-nectar-regeneration">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp3">
      <value value="500"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp2">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp4">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp3">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sp3-Oscemene">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp2">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp4">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp3">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sp2-Limenene">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sp4-Benzaldehyde">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-hives">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp4">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sp1-Pinene">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp2-nectar-regeneration">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp4-nectar-regeneration">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp1">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp2">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp1-nectar-regeneration">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bees">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp1">
      <value value="3000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control bees - vary sp3 parameters" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4998"/>
    <metric>[nectar] of hives</metric>
    <enumeratedValueSet variable="sp3-nectar-regeneration">
      <value value="3"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp3">
      <value value="1"/>
      <value value="1200"/>
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp1-Pinene">
      <value value="58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp2">
      <value value="2700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp4">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp3">
      <value value="500"/>
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp4-Benzaldehyde">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp2">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp4">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp3">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp2-Limonene">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp4">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-hives">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp3-Ocimene">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp2-nectar-regeneration">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp1-Pinene">
      <value value="58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp4-nectar-regeneration">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp4-Benzaldehyde">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp1">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp2">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp1-nectar-regeneration">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp3-Ocimene">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp1">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bees">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp2-Limonene">
      <value value="34"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control bees -- vary start and regen sp3" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4998"/>
    <metric>gl-nectar1</metric>
    <metric>gl-nectar2</metric>
    <enumeratedValueSet variable="sp3-nectar-regeneration">
      <value value="3"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp3">
      <value value="0"/>
      <value value="1250"/>
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp1-Pinene">
      <value value="58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp2">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp4">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp3">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp4-Benzaldehyde">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp2">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp4">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp3">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp2-Limonene">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp4">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-hives">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp3-Ocimene">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp2-nectar-regeneration">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp1-Pinene">
      <value value="58"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp4-nectar-regeneration">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp4-Benzaldehyde">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp2">
      <value value="1250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp1-nectar-regeneration">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp3-Ocimene">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp1">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bees">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp2-Limonene">
      <value value="34"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Baseline scenario" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4998"/>
    <metric>gl-nectar1</metric>
    <metric>gl-nectar2</metric>
    <enumeratedValueSet variable="sp3-nectar-regeneration">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp3">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp1-Pinene">
      <value value="82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp2">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp4">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp3">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp4-Benzaldehyde">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp2">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp4">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp3">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp2-Limonene">
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp4">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-hives">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp3-Ocimene">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp2-nectar-regeneration">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp1-Pinene">
      <value value="82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp4-nectar-regeneration">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp4-Benzaldehyde">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp2">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp1-nectar-regeneration">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp3-Ocimene">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bees">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp2-Limonene">
      <value value="64"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Baseline 2 reps April 22" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4998"/>
    <metric>gl-nectar1</metric>
    <metric>gl-nectar2</metric>
    <enumeratedValueSet variable="sp3-nectar-regeneration">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp3">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp1-Pinene">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp2">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp1">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp4">
      <value value="0"/>
      <value value="1500"/>
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp3">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp2">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp4-Benzaldehyde">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp4">
      <value value="2000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp3">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp2-Limonene">
      <value value="64"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-sp4">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-hives">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp3-Ocimene">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp1-Pinene">
      <value value="82"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp2-nectar-regeneration">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp4-nectar-regeneration">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp1">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp4-Benzaldehyde">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee2-Sp3-Ocimene">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sp1-nectar-regeneration">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="start-of-bloom-sp2">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lifespan-sp1">
      <value value="2200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bees">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Bee1-Sp2-Limonene">
      <value value="64"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
