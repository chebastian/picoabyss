--
--  SPLASH
-- 
function upd_splash()
	_splshy -= .5
	_splshy = max(_splshy,50)
	if btnp(3) then
		_starting = true
	end
	if _starting then
		_plyr.pos.y += .1
		if _plyr.pos.y > 20 then
			drw_loading()
			restart()
			pop_upd()
			_drw = drw_game
		end
	end
end

function drw_splash()
    pal(15, _levelpal[_plyr.lvl])
	map()
	_pl.frame_cnt+=1
	_updt = min(_updt+1/60,1)
	print("-- p i c o - a b y s s -- ", 20, _splshy)

	for e in all(_ents) do
		e:upd_ren()

		if e.anim then
			e.sprid = upd_anim(_pl,e.anim)
		end

		drw_ent(e,e.pos_ren)
	end

	if _splshy == 50 and t()%1 <= 0.5 then
		print("⬇️",60,110)
	end
end

-- 
--  Next level cutscene
-- 
function drw_nextlevel()
    drw_splash()
    local idx = ((_plyr.lvl-1)*2)-1
    msg = csv_to_arr("a bottled map,guiding you to sea,a inscribed seashell,its markings guide you,a magical compass,its needle shows the way", true)
    print(msg[idx], 20,40)
    print(msg[idx+1], 20,50)
    -- spr(103,40, 78)
end

function upd_nextlevel()
  _ship.pos_ren.x += 0.05
  if btnp(4) or _ship.pos_ren.x > 14 then
    drw_loading()
    restart()
    pop_upd()
    _drw = drw_game
  end
end


-- 
--  GAME OVER
-- 
function upd_endgame()
    if btnp(4) or btnp(5) then
        pop_upd()
        _drw = drw_game
        push_upd(upd_game)
        _plyr.lvl = 1
        _eqp = {}
        _plyr.atk = 1
        restart()
    end
end

function drw_endgame()
    print("Y O U   D I E D", 40,40)
    print("press a key to restart", 25,50)
end
