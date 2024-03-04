-- game
function start()
 --
 -- spr ids
 -- 
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
	_fsolid  = 0
	_fchest  = 1
	_flos_no = 2
	_frubble  = 3
	_fgrass = 4
	
	--
	-- mob init
	--
	_mobplyr = 1
	_mobslme = 2
	_mobbird = 3
	_mobacid = 4
	_mobsqid = 5
	_mobsmok = 6
	_mobsnek = 7
	_mobdoor = 8
	_hp = {10,1,5,1,1,1,1,1}
	_atk = {1,1,1,1,1,0,1,1,0}
	_anims = {240, --plyr
              210, --slme
              194, --bird
              198, --acid
              214, --sqid
              222, --smok
              218, --snek
              69} --door
	_mobupd = {}
	_mobupd[_mobsqid] = upd_sqid
	_mobupd[_mobsnek] = upd_snek
	_mobupd[_mobslme] = wlk_to_plyr	
	_mobupd[_mobbird] = wlk_to_plyr	
	_mobupd[_mobdoor] = noop	
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
 _traplife = {}
 _traplife[_mobsmok] = 5
 _traplife[_mobacid] = -1
 
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
		[1] = crt_itm("mana", on_use_mana),
		[2] = crt_itm("grt potion",on_use_grt_ptn),
		[3] = crt_itm("elixir",on_use_potion),
		[16] = crt_eqp("swd",2,2,on_equip),
		[17] = crt_eqp("grt swd",3,2,on_equip),
		[18] = crt_eqp("slv swd",4,3,on_equip),
		[19] = crt_eqp("gld swd",5,1,on_equip),
	}
	
	_lo_chst = {-1,
																0,0,0,
																16,16,16,16,
																17,17,17,
																18,18,
																19}

 _traps = {}
 -- test
 add_trap(4,p(7,2))								 
	_plyr = add_mob(1,p(8,3))
	_plyr.upd = upd_plyr
	_pl = anim_pl(4)
	_plyr.ease = ease_lerp
	_plyr.srchd = 6
 _cam = ent(99,p(_plyr.pos.x,
 																_plyr.pos.y))
	_tile_sfx = {
	[9]=sfx_door,
	[13]=sfx_lmp,
	[15]=sfx_lmp,
	[1]=sfx_bmp
	}
	
	_slime_anim = anim({210,211},3,1)

 -- <test>
 -- </test>
 
 -- init fov and search tiles
 _srch_tiles =
   flood_fill(_plyr.pos,{},_plyr.srchd)
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
 
 _srch_tiles =
   flood_fill(_plyr.pos,{},_plyr.srchd)
 
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
end

function chk_traps(e)
	local trap = _traps[ptoi(e.pos)]
	if trap and trap != e then
	 trap:on_trap(e)
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
--  foreach(_ents,on_ent_turn_done)
  _on_turn_done()
  return
 end
end

function on_turn_done()
	_on_turn_done = noop
end