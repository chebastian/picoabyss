# Todo 

- [] deleted entities animation does not finish?
    perhaps add a trailing animation which plays once then quits?
    Fade out via blink?
- [] chainable mines
- [] rubble is rendered over player
- [] add wobble to player idle (this is super for overall feeling and sells swimming)
- [] starfish charge til somethings hit  
- [] snek only charge til player last location  
- [] gras and smoke should be ontop of player?? (do i need ordering now)
- [] snakes can pickup items (when charging they bump into anything in the way)
- [] enemy idle patterns  
- [] enemy sight structure  
- [] random birds  
- [] clean, remov unused _upds  
- [] rooms are always generated in the same X position
- [] entities can now open doors? (verified, snakes)
- [] cleanup pline for tokens  
- [] enemy trail (manet with tail?)  
- [] potion drop when destroying pots  

## Chests
- [] noop entities should not affect player step time

## Tiles
- [] make tunnel floor more interesting (random spots gravel?)
- [] randomly shoose different straight walls with features
- [] 





-- █ done
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