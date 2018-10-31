;CompleteSim v1.0.4 10/31/2018
;This Simulation is a combination of Occuppied, Phenology, and Pollination simulations.


;Global Variables that all Breeds can see
globals []

;Defined Breeds [pural singular]
breed [seeds seed]
breed [bees bee]
breed [flowers flower]
breed [hives hive]

;attributes of all breeds
turtles-own [
  species ;specify the type of breed between species
  age
  ;nectar was split to make the code more readable
]

;attributes of Bees
bees-own [
  chosen-flower
  previous-flower
  destination
  home-hive
  collection-start-time
  current-flower
  carry-nectar ;count of nectar the bee is currently carrying
  pollen
  last-flower-time
]

;attributes of Seeds
seeds-own [
  lifespan
  start-of-bloom
  occupied
  nectar-regeneration
  active
]

;attributes of flowers
flowers-own [
  flower-seeds
  flower-block
  lifespan
  nectar-regeneration
  start-of-bloom
  flower-nectar
  occupied
]

;patches attributes
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
  set bee-wait-time 5
  set bee-vision-length 7
  set bee-vision-degrees 45
  set max-bees 500
  set bee-lifetime 1000

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
  set Bee2-end-reproduction 3000

  set number-of-Pinene 50
  set number-of-Limonene 50
  set number-of-Ocimene 50
  set number-of-Benzaldehyde 50

  set Pinene-nectar-regeneration 1
  set Limonene-nectar-regeneration 1
  set Ocimene-nectar-regeneration 1
  set Benzaldehyde-nectar-regeneration 1

  set lifespan-Pinene 2500
  set lifespan-Limonene 2500
  set lifespan-Ocimene 2500
  set lifespan-Benzaldehyde 2500

  set start-of-bloom-Pinene 1000
  set start-of-bloom-Limonene 1000
  set start-of-bloom-Ocimene 500
  set start-of-bloom-Benzaldehyde 500


  set percent-seed-death 0.25
  set seeds-fall-radius 5
  set max-flowers 600

end

;On set setup button press
to setup
  clear-all ;clear-all objects
  reset-ticks ;reset tickes
  setup-patches ;set patch color and has seed to false
  make-seeds ;place seeds
  make-hives ;place hives
  make-bees ;make bees
end

;Altered procedure to set the default variables for the seeds and to remove the extra seeds.
to setup-patches
  ask seeds [
    set active true
    set hidden? false
  ]
  ask patches [
    set pcolor green - 3
    kill-seeds
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

;Places seeds randomly in the environment
to make-seeds
  ask patches [set has-seed? false]
  ask n-of number-of-Pinene patches
    [
    sprout-seeds 1 [
      set color white
      set size 1
      set species 1
      set shape "circle"
      set lifespan lifespan-Pinene
      set nectar-regeneration Pinene-nectar-regeneration
      set start-of-bloom start-of-bloom-Pinene
      set active true
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
      set active true
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
      set active true
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
      set active true
    ]
    set has-seed? TRUE
  ]
end


;On Go button press function
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
      make-new-bees
   ]
   if ticks mod 5000 = season-end[
      set producing-bees false
   ]
  ]
  move-bees
  collect-nectar
  bees-go-back-to-hive
  make-new-bees
  flowers-age
  bees-grow
  tick
end

;Simulate a new season
to new-season
  show "got to new season"
  ask flowers[die]
  ask bees [die]
  ask n-of (count seeds * percent-seed-death) seeds [die] ; Kills a certain amount of random seeds at the start of the season
  setup-patches
  make-new-bees
end

;New method to remove extra seeds
to kill-seeds
  if count seeds-here > 1 [
    ask n-of (count seeds-here - 1) seeds-here [die]
  ]
end

;have 0.7 of the flowers bloom at any given tick
to flowers-bloom
  ask seeds [
     if active = true[
      if ((ticks + 1) mod 5000) > start-of-bloom
      [
        if random 1000 < 7
        [
          hatch-a-flower
          die
        ]
      ]
    ]
  ]
end

;make a flower appear
to hatch-a-flower  ;this is a seeds routine whereas features like nectar regen is passed down
  if count flowers < max-flowers[ ;check if artificial cap has been reached
    if not any? flowers in-radius 1 [ ; If a flower has already bloomed next to the seed, the seed will not bloom into a new flower
      hatch-flowers 1
      [set shape "flower"
        set size 2
        set flower-nectar 0
        set age 0
        set flower-block 20
        set occupied false
      ]
    ]
  ]
end  ; end hatch-a-flower

;have the flowers die and sprout seeds
to flowers-age
  ask flowers [
    set age age + 1
    if age > lifespan
      [
        let x xcor
        let y ycor
        hatch-seeds flower-seeds [
         ; Drops the seeds in a certain radius around the flower determined by the user
         setxy x + (random seeds-fall-radius - (seeds-fall-radius / 2)) y + (random seeds-fall-radius - (seeds-fall-radius / 2))
         set active false
         set shape "circle"
         set size 1
         set hidden? true
        ]
        die
      ]
  ]
end

;have flowers make nectar
to make-nectar
  ask flowers [
    if flower-nectar < 100 [
      set flower-nectar flower-nectar + nectar-regeneration
    ]
  ]
end

;make initial bees
to make-bees
  ask hives [
    hatch-bees starting-number-of-bees [
      set home-hive myself
      set size 1
      set shape "bee"
      set age 0
      set carry-nectar 0
      set chosen-flower NOBODY
      set previous-flower NOBODY
      set destination NOBODY
      set pollen [ 0 0 0 0 ]
      set current-flower NOBODY
      set species [species] of myself
    ]
  ]
end

;bee chooses a flower to go to
to choose-flower
; if there is a bee already on the flower, choose another. Make bee sit there for a bit.
; check again when they get to the flower
; call flower occupancy first
  let temp-flower previous-flower
  let flower-list flowers in-cone bee-vision-length bee-vision-degrees with [self != temp-flower and occupied = false]   ;Liz added cone-length cone-degrees and sliders
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

;bee collects nectar from a flower
to collect-nectar
  ask bees [
    let bee-pollen pollen ; Sets a temporary variable that can be used within the 'ask flower' statement

    if chosen-flower != NOBODY [
      let flower-occupied true ; a temporary variable to reference later in the method
      ask chosen-flower [set flower-occupied occupied]
      if distance chosen-flower < 1  and flower-occupied = false[
        move-to chosen-flower

        let current-species 0 ; Sets a temporary variable to be used in the ask statement
        set current-flower chosen-flower
        set collection-start-time ticks ; Starts a counter for how long the bee is on the flower
        set carry-nectar carry-nectar + [flower-nectar] of chosen-flower

        ask chosen-flower [
          set occupied true
          set current-species (species - 1)
          set flower-nectar 0

          ifelse random 50 < (item current-species bee-pollen)   ; The pollen values stored by the bee are the chance of that species flower being pollinated by the bee
          [if flower-seeds < flower-block [set flower-seeds flower-seeds + 1]]   ; flowers can make a max of flower-block seeds
          [set flower-block flower-block - 1]  ; each time the wrong pollen is transmitted, a potential seed is blocked

        ]

        set pollen replace-item current-species pollen 10 ; Refills the bee's pollen value of that specific species of flower

        set previous-flower chosen-flower
        set chosen-flower NOBODY
        set destination NOBODY
        set last-flower-time ticks
      ]
    ]
  ]
end

;bees teleport back to hive
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

;make new bees if the hive can "afford" it
to make-new-bees

  ask hives [

    while [storage-nectar > 2500 and ticks mod 5000 < season-end] [
      set storage-nectar storage-nectar - 2500
      if count bees < max-bees[ ;check if bees reach the sim capasity
        hatch-bees 1 [
          set home-hive myself
          set size 1
          set shape "bee"
          set age 0
          set carry-nectar 0
          set chosen-flower NOBODY
          set previous-flower NOBODY
          set destination NOBODY
          set heading random 360
          set pollen [ 0 0 0 0 ]
          set current-flower NOBODY
        ]
      ]
    ]
  ]
end

;moving bees only of they are not currently collecting nectar
to move-bees
    ask bees [
    if not collecting-nectar[
      ifelse destination = NOBODY [right (60 - random 120)]
      [face destination]
      forward 1
    ]
  ]
end

;bees age and die
to bees-grow
  ask bees [
    set age age + 1
    if age > bee-lifetime and random 100 < 1 [
      die
    ]
  ]
end


;function on a given bee that reports true if the bee is currently collecting nector, false if not
to-report collecting-nectar
  ifelse (current-flower = NOBODY) [
   report false
  ]
  [
    ;if the bee is not collecting nectar
    if ((ticks - bee-wait-time) > collection-start-time)[
      ;set the flower to not be occupied
      ask current-flower [
        set occupied false
      ]
     set current-flower NOBODY
     report false
    ]
  ]
  report true
end

;get the preference of flowers to each bee species
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
302
13
748
460
-1
-1
7.18033
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
0
0
1
ticks
30.0

BUTTON
20
10
104
81
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
118
12
199
82
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
754
31
971
64
number-of-Pinene
number-of-Pinene
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
759
417
970
450
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
212
13
294
82
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
322
465
456
498
show-energy?
show-energy?
1
1
-1000

PLOT
1237
330
1582
480
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
995
31
1215
64
number-of-Limonene
number-of-Limonene
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
988
228
1232
261
number-of-Benzaldehyde
number-of-Benzaldehyde
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
754
234
969
267
number-of-Ocimene
number-of-Ocimene
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
754
65
971
98
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
994
66
1216
99
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
754
268
970
301
Ocimene-nectar-regeneration
Ocimene-nectar-regeneration
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
988
268
1233
301
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
755
100
972
133
start-of-bloom-Pinene
start-of-bloom-Pinene
0
4000
1000.0
100
1
NIL
HORIZONTAL

SLIDER
993
102
1217
135
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
753
305
971
338
start-of-bloom-Ocimene
start-of-bloom-Ocimene
0
4000
500.0
100
1
NIL
HORIZONTAL

SLIDER
985
303
1232
336
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
755
135
974
168
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
995
139
1218
172
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
754
341
972
374
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
983
338
1231
371
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
1236
170
1584
320
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
"Pinene" 1.0 0 -1184463 true "" "let fl1 count flowers with [species = 1]\nifelse fl1 > 1\n[plotxy ticks sum [flower-nectar] of flowers with [species = 1]\nplot-pen-down]\n[plot-pen-up]"
"Limonene" 1.0 0 -2674135 true "" "let fl2 count flowers with [species = 2]\nifelse fl2 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 2]\nplot-pen-down]\n[plot-pen-up]"
"Ocimene" 1.0 0 -11221820 true "" "let fl3 count flowers with [species = 3]\nifelse fl3 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 3]\nplot-pen-down]\n[plot-pen-up]"
"Benzaldehyde" 1.0 0 -10899396 true "" "let fl4 count flowers with [species = 4]\nifelse fl4 > 1 \n[plotxy ticks sum [flower-nectar] of flowers with [species = 4]\nplot-pen-down]\n[plot-pen-up]"

SLIDER
15
118
296
151
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
13
155
295
188
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
16
192
296
225
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
19
230
298
263
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
1237
493
1582
643
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
"Bee Species 1" 1.0 0 -817084 true "" "plot count bees with [species =  1]"
"Bee Species 2" 1.0 0 -1184463 true "" "plot count bees with [species = 2]"

SLIDER
20
364
300
397
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
20
403
299
436
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
20
442
298
475
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
22
481
299
514
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
1236
10
1585
160
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

TEXTBOX
784
10
934
28
Pinene Flower Variables
12
0.0
1

TEXTBOX
1022
11
1237
41
Limonene Flower Variables
12
0.0
1

TEXTBOX
778
213
953
243
Ocimene Flower Variables
12
0.0
1

TEXTBOX
1011
211
1213
241
Benzaldehyde Flower Variables
12
0.0
1

TEXTBOX
103
97
253
115
Bee 1 Variables
12
0.0
1

TEXTBOX
110
342
260
360
Bee 2 Variables
12
0.0
1

SLIDER
757
451
969
484
bee-vision-degrees
bee-vision-degrees
0
180
45.0
1
1
NIL
HORIZONTAL

SLIDER
758
486
971
519
bee-vision-length
bee-vision-length
0
15
7.0
1
1
NIL
HORIZONTAL

BUTTON
583
465
709
498
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
798
395
948
413
Common Bee Variables
12
0.0
1

SLIDER
758
521
975
554
bee-wait-time
bee-wait-time
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
17
268
300
301
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
18
307
297
340
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
22
520
297
553
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
22
554
299
587
Bee2-end-reproduction
Bee2-end-reproduction
1000
5000
3000.0
100
1
NIL
HORIZONTAL

SLIDER
998
456
1222
489
percent-seed-death
percent-seed-death
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
997
417
1221
450
seeds-fall-radius
seeds-fall-radius
0
10
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
1018
394
1200
424
Common Flower Variables
12
0.0
1

SLIDER
759
558
976
591
max-bees
max-bees
0
500
500.0
1
1
NIL
HORIZONTAL

SLIDER
999
493
1219
526
max-flowers
max-flowers
0
1200
600.0
1
1
NIL
HORIZONTAL

SLIDER
759
595
974
628
bee-lifetime
bee-lifetime
10
1000
1000.0
50
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This Simulation tests how two Species of Bees interact with different flowers based on  Bee's preferences set by the user. In addition, every 5000 ticks starts a "new season" where the flower locations reset. The flower types also bloom at different times.

This simulation also accounts for the time bee's take to collect pollen from a single flower. The flowers that get pollenated will have more of their children appear in the next season. the bee population is also tied with the amount of nectar they collect.

## HOW IT WORKS

Using the sliders, you can alter:

Bee Vision Length and Angle
Amount of time a bee stays on a flower
The lifetime of a bee
The max number of bees that can be in the environment at once (for computer performance)

The starting number of bees per hive
The preference percentage each Bee has to each type of flower
The start and stop time to collect nectar for each bee species

The starting number of each flower type
How fast each flower type can produce nectar
How long it takes for each flower type to bloom
How long each flower type stays live
The percent of seeds that die between seasons
The radius in which the new seeds drop.
The max number of flowers that can be in the environment at once (for computer performance)

## THINGS TO NOTICE

How do all the factors intereact with each other?
How do the rate of flower reproduction corespond to bee population?

## RELATED MODELS

OccupiedSim
BeePhenologySim
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
Polygon -1184463 true true 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
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
Polygon -1184463 true false 195 150 105 150 90 165 90 225 105 270 135 300 165 300 195 270 210 225 210 165 195 150
Rectangle -16777216 true false 90 165 212 185
Polygon -16777216 true false 90 207 90 226 210 226 210 207
Polygon -16777216 true false 103 266 198 266 203 246 96 246
Polygon -6459832 true false 120 150 105 135 105 75 120 60 180 60 195 75 195 135 180 150
Polygon -6459832 true false 150 15 120 30 120 60 180 60 180 30
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
Circle -7500403 true true 15 15 270
Circle -16777216 true false 60 60 180

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
