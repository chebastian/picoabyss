-- game
function init_game()
	--
	-- spr ids
	-- 
	_splshy = 140
	_idweed = 19
	_idclam = 29
	
	--
	-- generators
	--
	_genweed =
	{
	id = _idweed,
	r  = 400,
	pred = function(sig)
		return sig_match(sig,0b1010000,0b00001111)
					or sig_match(sig,0b0101000,0b00001111)
	end
	}
	_genclam =
	{
	id = _idclam,
	r  = 100
	}
	
	-- 
	-- spr flags
	--
	_fsolid,
	_fchest,
	_flos_no,
	_frubble,
	_fgrass,
	_fanchor = unpack(csv_to_arr("0,1,2,3,4,5"))
	
	--
	-- mob init
	--
	_mobplyr,
	_mobexpl,
	_mobmine,
	_mobacid,
	_mobsqid,
	_mobsmok,
	_mobsnek = unpack(csv_to_arr("1,2,3,4,5,6,7"))

	-- 
	-- fmobs
	-- 
	_mobdoor,
	_mobchest,
	_mobgrass,
	-- 11 waterline
	_mobanchor = unpack(csv_to_arr("8,9,10,12"))

	_hp = csv_to_arr("4,1,5,1,1,1,3,1,0")
	_atk = csv_to_arr("1,2,1,1,1,0,1,1,0,0")
	_anims = csv_to_arr("240,206,226,198,214,222,218,68,70,72,50,90")
	_mobupd = {}
	_mobupd[_mobmine] = upd_mine
	_mobupd[_mobsqid] = upd_sqid
	_mobupd[_mobsnek] = upd_snek
	_mobupd[_mobdoor] = noop
	_mobupd[_mobanchor] = noop

	_fmobs = {}
	_fmobs[_mobdoor] = on_open
	_fmobs[_mobchest] = on_open
	_fmobs[_mobanchor] = on_open
	-- mob gen
	_gensqid =
	{
	id = _mobsqid,
	r = 35
	}
	_gensnek = 
	{
		id = _mobsnek,
		r = 45
	}
		
	--
	-- trap init
	-- 
	_trapupd ={}
	_trapupd[_mobsmok] = upd_smok
	_trapupd[_mobacid] = trap_noop
	_trapupd[_mobexpl] = upd_smok	
	_trapupd[11] = trap_noop -- waterline
	_traplife = {}
	_traplife[_mobsmok] = 5
	_traplife[_mobexpl] = 5
	_traplife[_mobacid] = nil
	_traplife[11] = nil -- waterline
	
	--
	-- rest
	--
	_t⧗ = 0
	_pid = 1
	_updt = 0 -- a global 1s timer which can be used to update idle anim


	_upds = {noop,noop,wobble_upd}
	_txts = {}  -- floating text
	_ents = {}  -- all entities, inc player
	_itms = {}  -- all pickups etc
	_bpack = {} -- player backpack
	_eqp = {}   -- player equipment
	_eqp_atk = {[0x50] = 2,
				[0x51] = 3}
	_lo_itms = {
		[0] = crt_itm("potion",on_use_potion),
		[1] = crt_itm("air", on_use_mana),
		[16] = crt_eqp("swd",2,2,on_equip),
		[17] = crt_eqp("grt swd",3,2,on_equip),
		[18] = crt_eqp("slv swd",4,3,on_equip),
	}

	-- 7430
	-- 7451
	_lo_chst = csv_to_arr("-1,0,0,0,1,1,1,1,1,1,1,1,1,1,16,16,16,16,17,17,17,18,18,19")

	_traps = {}
	-- test
	_plyr = add_mob(1,p(8,12))
	_plyr.upd = upd_plyr
	_pl = anim_pl(4)
	_plyr.ease = ease_lerp
	_plyr.upd_ren = wobble_upd
	_plyr.srchd = 6
	_plyr.air = 100
 	_cam = ent(99,p(_plyr.pos.x, _plyr.pos.y))

	-- sfx_wkl=0
	-- sfx_bmp=1
	-- sfx_lmp=2
	-- sfx_door=3
	_tile_sfx = { [9]=3, [13]=2, [15]=2, [1]=1 }

end

function start()
	init_game()
	for i=0,18 do
		add_trap(11,p(i,10))
	end
end

function restart()
	init_game()
	start_rnd_gen()
	_srch_tiles = flood_fill(_plyr.pos,{},_plyr.srchd)
	 upd_vistiles()
end

function get_vis_ents()
	local res = {}
	for ent in all(_ents) do
		if fget(ent.sprid,_flos_no) then
--			add(res,ptoi(ent.pos))
			res[ptoi(ent.pos)] = true
		end
	end
	printh("vis" .. #res)
	return res
end

function chk_tile(p,flag)
 local tile = mget(p.x,p.y)
 return fget(tile,flag),tile
end

function chk_solid(po)
 return chk_tile(po,_fsolid)
end

-- 7378
function chk_solidx(x,y)
 return chk_tile(p(x,y),_fsolid)
end

function step_ent_at(p)
 for ent in all(_ents) do
  if ent.pos.x == p.x
  and ent.pos.y == p.y 
  and ent.can_walk 
  then
   return ent
  end
 end
end

function sld_ent_at(p)
 for ent in all(_ents) do
  if ent.pos.x == p.x
  and ent.pos.y == p.y 
  and not ent.can_walk then
   return ent
  end
 end
 
 return nil
end

function getnext_d()
 for i=1,#dirs do
 	if btnp(buttons[i]) then
 	 return dirs[i]
 	end
 end
 
 return nil
end

function buff_input()
 local nd = getnext_d()
	if nd then
	 _d = nd
 end
end

function is_solid(p)
 local tile = mget(p.x,p.y)
 return fget(tile,_fsolid)
end

function upd_plyr(ent)
 ent.d = _d
 move_ent(ent,ent.d)
 ent.d = nil
 _d = nil
 _cam.pos.x = ent.pos.x
 _cam.pos.y = ent.pos.y
 set_lst_pos(_cam)
end

function upd_splash()
	_splshy -= .5
	_splshy = max(_splshy,50)
	if btnp(3) then
		_starting = true
	end
	if _starting then
		_plyr.pos.y += .1
		if _plyr.pos.y > 20 then
		-- _drw = drw_game
			restart()
			pop_upd()
			_drw = drw_game
		end
	end
end

function upd_game()
	buff_input()
	
	if btnp(❎) then
  add_menu_win()
	end
	
	local has_player_input = _d
  
	if has_player_input then
	 plr_turn()
	end
end

function plr_turn()
	_t⧗ = 0
	if _d == nil then
  _d = p(0,0)
 end
 _plyr:upd()
 _on_turn_done = ai_turn
 _trn_spd = 1/10
 push_upd(upd_ease)
 _plyr.upd_ren = noop
 
 _srch_tiles =
   flood_fill(_plyr.pos,{},_plyr.srchd)
 
   upd_vistiles()
end

function upd_vistiles()
 _vis =
   flood_fill(_plyr.pos,
   {},
   _plyr.srchd,
	  function(p)
	  	return chk_tile(p,_flos_no)
	  end
   )
 _vis_lookup = arr_to_tbl(_vis)
 updatefow()
end

function is_visible(e)
 return _los[ptoi(e.pos)] != nil
end

function ai_turn()
	_t⧗ = 0
	_trn_spd = 1/2
 for e in all(_ents) do
 	if not is_player(e) then
 	 e:upd()
 	 if is_visible(e) then
 	 	_trn_spd = 1/6
 	 end
 	end
 end
 
 push_upd(upd_ease) 
 _on_turn_done = turn_done
end

function turn_done()
 _trn_spd = 1/10
 _on_turn_done = noop
   -- traps/poison
 foreach(_ents,chk_traps)

 _plyr.upd_ren = wobble_upd
 _plyr.air -= 1
end

function chk_traps(e)
	local key = ptoi(e.pos)
	local trap = _traps[key]
	if trap and trap != e and e.can_dmg then
	 trap:on_trap(e)
	end

	if trap and trap.life and trap.life <= 0 then
		_traps[key] = nil
	end
end

function chk_endgame()
 if _plyr.hp <= 0 then
	pop_upd()
	push_upd(upd_endgame)
	_drw = drw_endgame
 end
end

function upd_endgame()
	if btnp(4) or btnp(5) then
		pop_upd()
		_drw = drw_game
		push_upd(upd_game)
		restart()
	end
end

function drw_endgame()
	print("Y O U   D I E D", 40,40)
	print("press a key to restart", 25,50)
end

function ease_lerp(ent)
 --update positions

 return lerp(ent.pos_lst.x,
             ent.pos.x,
            _t⧗),
        lerp(ent.pos_lst.y,
             ent.pos.y,
             _t⧗)
end

function set_lst_pos(ent)
 ent.pos_lst.x = ent.pos_ren.x
 ent.pos_lst.y = ent.pos_ren.y
end

function ease_bump(ent)
 local tme = _t⧗
 if(_t⧗<0.50) tme = 1-_t⧗
 
 return lerp(ent.pos_lst.x,
             ent.pos.x,
             tme),
        lerp(ent.pos_lst.y,
             ent.pos.y,
             tme)
end

function upd_ease()
  buff_input()
 _t⧗=min(_t⧗+_trn_spd,1)
 
 
 for e in all (_ents) do
  e.pos_ren.x,
  e.pos_ren.y = e.ease(e)
 end
 
 _cam.pos_ren.x,
 _cam.pos_ren.y = ease_lerp(_cam)
 if _t⧗ == 1 then
  pop_upd()
  set_lst_pos(_cam)
  foreach(_ents,set_lst_pos)
  _on_turn_done()
  return
 end
end

function on_turn_done()
	_on_turn_done = noop
end