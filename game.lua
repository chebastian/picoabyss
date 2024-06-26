-- game
function init_game(eqp, lvl, atk)
	--
	-- spr ids
	-- 
	_splshy = 140
	_idweed = 19
	_idclam = 29
	
	-- 
	-- spr flags
	--
	_fsolid,
	_fchest,
	_flos_no,
	_frubble,
	_fgrass,
	_fanchor = csv_to_val("0,1,2,3,4,5")

	_lvlkey = lvl and 47 + lvl or 48
	--
	-- mob inint
	--
	_mobplyr,
	_mobexpl,
	_mobmine,
	_mobacid,
	_mobsqid,
	_mobsmok,
	_mobsnek = csv_to_val("1,2,3,4,5,6,7")

	-- 
	-- fmobs
	-- 
	_mobdoor,
	_mobchest,
	_mobgrass,
	-- 11 waterline
	_mobanchor,
	_mobwave,
	_mobboat,
	_mobchest2 = csv_to_val("8,9,10,12,13,14,15")

	_hp = csv_to_arr("4,1,5,1,1,1,3,1,0")
	_atk = csv_to_arr("1,2,1,1,1,0,1,1,0,0")
	_anims = csv_to_arr("240,206,226,198,214,222,218,68,70,72,50,90,33,248,86")
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
	_eqp = eqp and eqp or {}   -- player equipment
	_eqp_atk = {[0x50] = 2,
				[0x51] = 3}
	_lo_itms = {
		[0] = crt_itm("potion",on_use_potion),
		[1] = crt_itm("air", on_use_air),
		[16] = crt_eqp("swd",2,2,on_equip),
		[17] = crt_eqp("grt swd",3,2,on_equip),
		[18] = crt_eqp("slv swd",4,3,on_equip),
		[_lvlkey] = crt_itm("treasure", on_use_key)
	}

	-- 7430
	-- 7451
	_level_items = {
		csv_to_arr("16"), -- one in four to get sword
		-- csv_to_arr("0,0,0,16"), -- one in four to get sword
		csv_to_arr("0,0,0,0,0,16,17"), --  1/7 sword 1/7 great swrd
		csv_to_arr("0,0,0,0,0,16,17,18"), --  1/8 sword 1/8 great swrd 1/8 slv swrd
		csv_to_arr("0,0,0,0,0,16,17,18") --  1/8 sword 1/8 great swrd 1/8 slv swrd
	}

	-- 
	-- on each level replace picked up equipment with next lvl eqp
	-- so if the plyr has sword, replace it with great sword (on enter level, or pickup)
	-- 

	-- _lo_chst = csv_to_arr("0,0,0,16,16,16,16,17,17,17,18,18")
	_lo_chst = upgd_itm_lookup(eqp or {},_level_items[lvl])
	_lo_clam = csv_to_arr("1,1")

	_traps = {}
	-- test
	_plyr = add_mob(1,p(8,12))
	_plyr.has_key = true
	_plyr.upd = upd_plyr
	_pl = anim_pl(4)
	_plyr.ease = ease_lerp
	_plyr.upd_ren = wobble_upd
	_plyr.srchd = 6
	_plyr.lvl = lvl and lvl or 1
	_plyr.air = 100
	_plyr.atk = atk and atk or 1
 	_cam = ent(99,p(_plyr.pos.x, _plyr.pos.y))

	-- sfx_wkl=0
	-- sfx_bmp=1
	-- sfx_lmp=2
	-- sfx_door=3
	_tile_sfx = { [9]=3, [13]=2, [15]=2, [1]=1 }

	_levelpal = csv_to_arr("5,4,3,2")
	pal(15, _levelpal[_plyr.lvl])
end

function start()
	init_game()
	for i=0,18 do
		add_trap(11,p(i,10)) -- add waves to startscreen
	end
end

function restart()

	init_game(_eqp, _plyr.lvl, _plyr.atk)
	start_rnd_gen()
	_srch_tiles = flood_fill(_plyr.pos,{},_plyr.srchd)
	 upd_vistiles()
end

function get_vis_ents()
	return get_flg_ent(_flos_no)
end

-- returns both a table of hashes of the entities with the flags position
-- and their positions in an array
function get_flg_ent(flag)
	local res = {}
	local pos = {}
	for ent in all(_ents) do
		if fget(ent.sprid,flag) then
			res[ptoi(ent.pos)] = true
			add(pos,ent.pos)
		end
	end

	return res, pos
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
 if not is_valid_move(ent, _d) then
    ent.ease = ease_bump
    on_bump(0, add_pt(_plyr.pos, _d), ent, _d)
	_d = nil
	return false
 end
 move_ent(ent,ent.d)
 ent.d = nil
 _d = nil
 _cam.pos.x = ent.pos.x
 _cam.pos.y = ent.pos.y
 set_lst_pos(_cam)
 return true
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
 local valid = _plyr:upd()
 -- dont move to ai turn if move was not valid
 _on_turn_done = valid and ai_turn or on_turn_done

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
 if _plyr.air <= 0 then
	kill_ent(_plyr)
 end
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
 if (_plyr.hp <= 0 or _plyr.air <= 0) and _plyr.death <= 0 then
	pop_upd()
	push_upd(upd_endgame)
	_drw = drw_endgame
 end
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