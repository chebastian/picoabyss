# Todo 

- [] BUG, can spawn on another entity (fmmob rather)
- [] BUG, acid traps can be killed but they are not removed
- [] snek only charge til player last location  
- [] starfish charge til somethings hit  
- [] make tunnel floor more interesting (random spots gravel?)
- [] randomly shoose different straight walls with features
- [] add wobble to player idle (this is super for overall feeling and sells swimming)
- [] noop entities should not affect player step time
- [] rubble is rendered over player
- [] start updating entities only after seen
     to reduce amount of damage made by snakes xD
- [] enemy idle patterns  
- [] clean, remov unused _upds  
- [] rooms are always generated in the same X position
- [] cleanup pline for tokens  
- [] enemy trail (manet with tail?)  
- [] moraan or snek endboss that has a trail and chases the player
- [] place mine at current location

## potions and pickups
- [] increase oxygen level
- [] boost max oxycen level
- [] reduce oxycen reduction for x turns
- [] take no explosion dmg for x turns
- [] enemies do not charge or follow you
- [] mine

## Tiles



-- █ done
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