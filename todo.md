# Game synops
The player dives down between the cliffs, the goal is to find Tritons Trident
the player sees the anchor which belongs to his boat on the surface.
When the player returns to the anchor they are asked to return to surface.
They may decide to do so because they are low on health, air or has found the levels item.
Unless they have found the next "key item" going to the surface will take 
them to a new location "regenerate the same level" to find the levels key.
The key is placed in a chest on each level, a map or token that will guide 
them to the next location.
They get the item and then return to the Anchor to go to the next location.
All in all there are 4 locations, each harder than the last.
The player progresses on each level by picking up items, and wapons
which persist between the levels. 
The last level containst tritons trident, but also a moran/snake guarding it.

# Technically
- at the start of level, iterate over all tiles from the player
 and place the key item furthest away from the anchor as possible

# Levels
1. Single randwalk enemy and grass (few to no traps)
2. add squids, snakes and more traps
3. adds mines and seastars
4. moran boss level


# Keys/Items ideas
Compass
Map
Mermaid
Tritons Trident


# Todo 
- [] BUG, anchor can be destroyed
- [] death on no air
- [] chests may contain enemies
- [] enemy that stuns, i.e you cannot move for one turn (electric eel trap, startfish on attack, knocked down for one turn)
- [] clear game screen
- [] BUG, bump wall should not be one turn (other bumps should)
- [] BUG, can spawn on another entity (fmmob rather)
- [] BUG, acid traps can be killed but they are not removed
- [] snek should only charge til player last location  
- [] starfish charge til somethings hit  
- [] make tunnel floor more interesting (random spots gravel?)
- [] randomly choose different straight walls with features
- [] noop entities should not affect player step time
- [] clean, remov unused _upds  
- [] rooms are always generated in the same X position
- [] cleanup pline for tokens  
- [] moraan or snek endboss that has a trail and chases the player

# Wont do
- [] place mine at current location
- [] enemy trail (manet with tail?)  
- [] start updating entities only after seen
     to reduce amount of damage made by snakes xD

## potions and pickups
- [] increase oxygen level
- [] boost max oxycen level
- [] reduce oxycen reduction for x turns
- [] take no explosion dmg for x turns
- [] enemies do not charge or follow you
- [] mine
- [] reveal map

## Tiles



-- █ done
- [x] splash screen
- [x] gameover screen
- [x] add wobble to player idle (this is super for overall feeling and sells swimming)
- [x] rubble is rendered over player
- [x] deleted entities animation does not finish?
    perhaps add a trailing animation which plays once then quits?
    Fade out via blink?
- [x] gracefull death
- [x] on death restart game
- [x] mines can now destroy clams and doors, perhaps ok?
- [x] chainable mines
- [x] trap which has frames enabled and disabled
      perhaps make acid trap idle n turns then enable, would also add dynamic
- [x] random start point, on open tile
- [x] BUG, trap sno longer work?
    cause of the life introduced for splosions
- [x] indicate that snake charge you
- [x] rework chests to entity
- [x] doors are now opened by broad sword when diagonal or in front oops
- [x] tiles and other entities can accidentially be generated on the same spot
- [x] chests can be opened at attack distance
-- [x] only update visible (or once visible) entities  
--				major slowdowns if updating all ents and ink etc.  
-- [x] enemies wont walk on other entities, so they cant walk through doors 
        fixed by setting is_walkable to true once opened.
-- [x] order rendering of ents (smoke on top of enemies, slime bellow)
-- [x] thermal vent traps
-- [x] lower visibility in inktrap
-- [x] squid ink trap
-- [x] add structure to traps callback and creation
-- [x] trigger trap general callback
-- [x] random sneks
-- [x] shells instead of pots
-- [x] trigger trap dmg
-- [x] poison tiles
-- [x] rand room layout
-- [x] rand rooms
-- [x] move blackout to screenspace
-- [x] spawn items only to chests
-- [x] fow
-- [x] atk adjecent
-- [x] atk dst
-- [x] turn order
-- [x] enemies turn is 2 frames in none visible
-- [x] snek charge plyr


-- ★★★ defects ★★★

-- [] ★111 menu checked set on player for viewing selection in ui
-- [] ★222 atk and atk pattern set on entity directly
-- [] ★223 onent used for both atk and pickup, does not work when atk multiple tiles
-- [] ★224 sld_ent_at slow?
-- [] ★xxx smoke interupts traps
-- [] ★666 dirs hack, for interpolation perhaps? cant remember
-- [] 321, hardcoded tile value when mergeing areas
-- █ ideas

-- spear gun, unlim range til hit enemy
-- whirlpools that suck everybody in for each turn active
-- bioluminance algea, step on to increase visibility
-- toxic spore tiles, release poision clouds
-- wave tiles, push the player in a direction
-- open seashells that slam shut, trap
-- jellyfish with a tail of dangerous tentacles
-- moray trap, peeking out of walls and attacking if the player gets close
-- 