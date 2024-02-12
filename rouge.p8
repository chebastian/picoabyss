pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- rouge
function _init()
 _st_upd = {}
 _dbg = {}
	_wnd = {}
	
	_drw_dbg = false
	_upd = upd_game
	_drw = drw_game
	push_upd(upd_game)
	_⬅️ = p(-1,0)
	_⬆️ = p(0,-1)
	_⬇️ = p(0,1)
	_➡️ = p(1,0)
	buttons = {⬅️,➡️,⬆️,⬇️}
	dirs = {_⬅️,_➡️,_⬆️,_⬇️}
	-- important to keep order
	-- used in tilesig
	dir8 = {p(-1,0),p(0,-1),
									p(1,0),	p(0,1),
									
									p(-1,-1), p(1,-1),
								 p(1,1),p(-1,1)}
	
	sfx_wkl=0
	sfx_bmp=1
	sfx_lmp=2
	sfx_door=3
	start()
	gen()
	flag_map()
	
	merge_areas()
 add_slimes()
end


function dbg(str)
 add(_dbg,str)
end

function _draw()
	cls()
 _drw()
 drw_win()
  
 if _drw_dbg then
	 cursor(0,20)
	 for i=0,10 do
	  print(_dbg[i])
	 end
 end
 
-- _dbg ={}
end

function _update60()
--	_upd()
 _st_upd[#_st_upd]()
end

function push_upd(upd)
 add(_st_upd,upd)
end

function pop_upd()
 del(_st_upd,_st_upd[#_st_upd])
end


-->8
-- game
function start()
	_t⧗ = 0
 _pid = 1
 _updt = 0 -- a global 1s timer which can be used to update idle anim
	_hp = {10,1,5,1,1}
		_atk = {1,1,1,1,1}
	_anims = {240,210,194,198,214}
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
	_plyr = add_mob(1,p(4,3))
	_plyr.upd = upd_plyr
	_pl = anim_pl(4)
	_plyr.ease = ease_lerp
	_plyr.srchd = 5
 _cam = ent(99,p(_plyr.pos.x,
 																_plyr.pos.y))
	_tile_sfx = {
	[9]=sfx_door,
	[13]=sfx_lmp,
	[15]=sfx_lmp,
	[1]=sfx_bmp
	}

	
	_slime_anim = anim({210,211},3,1)
 add_mob(2,p(9,10))
 add_mob(2,p(9,11))
 add_mob(3,p(5,5))
 
 -- <test>
 -- </test>
 
 -- init fov and search tiles
 _srch_tiles =
   flood_fill(_plyr.pos,{},_plyr.srchd)
 updatefow()

end

function chk_tile(p,flag)
 local tile = mget(p.x,p.y)
 return fget(tile,flag),tile
end

function chk_solid(po)
 return chk_tile(po,0)
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
 return fget(tile,0)
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
	 on_atk(trap,e,nil,p(0,0))
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

function on_ent_turn_done(e)

end
-->8
-- drawing
function ini_pal()
	palt(0,false)
	palt(14,true)
end

function drw_ent(ent,at)
	ini_pal()
	local flash=ent.flash
	if flash and flash > 0 then
	 pal(9,7)
	 ent.flash -= 1
	end
	if ent.outline then
		drw_spr_8(ent,at,0)
		ini_pal()
	end
	spr(ent.sprid,
				 at.x*8,
				 at.y*8,
				 1,1,ent.hflip)
	pal()
	ini_pal()

end

function drw_rectf(x,y,w,h,c)
 rectfill(x,y,x+w-1,y+h-1,c)
end

function drw_box(x,y,w,h,fg,bg)
 drw_rectf(x,y,w,h,fg)
 drw_rectf(x+1,y+1,w-2,h-2,bg)
end

function drw_txt8(txt,pos,fg,bg)
	for di in all(dir8) do
  local tx,ty = pos.x, pos.y
  print(txt,tx+di.x
     ,di.y+ty,bg)
 end
 
 print(txt,pos.x
      ,pos.y,fg)   
end

function drw_spr_8(ent,at,bg)
	for i=1,16 do
		pal(i,bg)
	end
	for di in all(dirs) do
  local tx,ty = di.x, di.y
  spr(ent.sprid,
					 at.x*8+tx,
					 at.y*8+ty,
					 1,1,ent.hflip)
 end
 pal()
end

function drw_win()
	for w in all(_wnd) do
  local wh,wy = w.h,w.y
  if w.t then
   local si = abs(sin(w.t))
   
   if w.t < 0.2 then
	   wh = si*w.h	   
	  elseif w.t >= 0.8 then
	   wh = si*w.h
	  end
	  local df = w.h-wh
	  wy += df*.5
	 end
	 
	 -- fix for empty inv
	 if #w.txt == 0 then
		 wh = max(wh,10)
	 end
	
	 drw_box(w.x,wy,
	 w.w,wh,
	 6,0)
 
	 clip(w.x-8,wy-8,w.w+6,wh+6)
	 for i=1,#w.txt do
	  local txt=w.txt[i]
	  
	  if w.chk_idx and w.chk_idx == i then
	   txt = txt .. "●"
	  end
	  
	  print(txt,
		  w.x+2
		  ,wy+2+(i-1)*6
		  ,6)
  
	  if w.sel and w.sel == i then
    if w.t == nil then
     spr(175,w.x-4+(1.3*sin(.6*_updt)),
         wy+2+(i-1)*6-6)
    end
	  end
	  
  end
  clip()
 end
end

-- game

function get_cam_renpos()
 return p((_cam.pos_ren.x-8)*8,
    (_cam.pos_ren.y-6)*8)
end

--function to_wrl_spc(po)
-- local cp = get_cam_renpos()
-- return cp.x + po.x,cp.y+po.y
--end

function drw_game()
 local cp = get_cam_renpos()
 camera(cp.x,cp.y)
	map()
	_pl.frame_cnt+=1
 _updt = min(_updt+1/60,1)
 
 for e in all(_ents) do
  e:upd_ren()
  e.sprid = upd_anim(_pl,e.anim)
	 drw_ent(e,e.pos_ren)
 end
 
 if _drw_dbg then
  for dtil in all(_srch_tiles) do
  	print(dtil.dst,dtil.po.x*8,dtil.po.y*8)
  end
  
  if _plyr.dx then
	  for pt in all(atk_ptrn(_plyr,_plyr.atkptr)) do
	   print("★",pt.x*8,
	   											pt.y*8,
	   											6)
	  end
  end
 end
 
-- blackout()
 drw_dmg()
 
 if _drw_dbg then
	 for k,v in pairs(_flagmap) do
	 	print(v.f,v.po.x*8,v.po.y*8,2)
	 end
 end
 camera(0,0)
 drw_hud()
 
 if(_updt >= 1) _updt=0
end

function drw_dmg()
for dmg in all(_txts) do
  local dy = dmg.pos.y
  local off = 1-(dmg.t/dmg.ot)
  
  drw_txt8(dmg.txt,
           p(dmg.pos.x*8,
             8*dmg.pos.y-off*8),
           dmg.bg,dmg.fg)
  dmg.t-=1
  if(dmg.t<=0)del(_txts,dmg)
 end
end
-- 
function drw_hud()
  drw_rectf(0,0,128,10,1)
  drw_txt8("♥ ".._plyr.hp..
           " カ " .. _plyr.atk,p(8,2),3,7)
end

_los = {}
function updatefow()
	_los = {}
	for wt in all(_srch_tiles) do
	 local x = wt.po.x
	 local y = wt.po.y
	 if not line_of_sight(_plyr.pos,p(x,y)) then
  else
   _los[ptoi(p(x,y))]=true
  	for d in all(dir8) do
    _los[ptoi(p(x+d.x,y+d.y))] = true
  	end
  end
	end
end

function blackout()
 local mw = 17
 local mh = 17
 
 local cp = _cam.pos
 local cpx,cpy = cp.x-9
 																,cp.y-7
		
 for x=cpx,cpx+mw,1 do
	 for y=cpy,cpy+mh,1 do
	  local pxy = p(x,y)
	  local idx = ptoi(pxy)
	  local d = dist(pxy,_plyr.pos)
	  if not _los[idx] then
--   	print("▒",x*8,y*8+1,1)
   	drw_rectf(x*8,y*8,8,8,0)
	  end
		end
	end
end
-->8
-- ent

-- flags


function ent(id,po)
	return {id=id,
							  sprid=_anims[id],
							  pos=po,
							  hflip=false,
							  upd_ren=noop,
							  ease=ease_lerp,
							  on_ent=on_dmg,
							  pos_ren=p(po.x,po.y),
							  pos_lst=p(po.x,po.y),
							  dx=0,
							  dy=0,
							  can_dmg = false,
							  can_pickup = false,
							  can_walk = false
							 }
end

function add_trap(id,p)
 local mob = add_mob(id,p)
 mob.upd = noop
 mob.can_dmg = false
 mob.can_pickup = false
 mob.can_walk = true
 _traps[ptoi(p)] = mob
 return mob
end

function add_mob(id,p)
 local e,frames,anim_id 
 = ent(id,p),{},_anims[id]
 for i=0,3 do
  add(frames,anim_id+i)
 end
 
 e.anim = anim(frames,3,1)
 e.hp = _hp[id]
 e.atk = _atk[id]
 e.upd = wlk_to_plyr
-- e.upd = rand_wlk
 e.upd_ren = noop
 e.can_dmg = true
 e.can_walk = false
 e.can_pickup = false
 add_ent(e)
 return e
end

function add_ent(ent)
 add(_ents,ent)
end

function noop(e)
end

function rand_wlk(e)
	if e.d == nil then
  e.d = next_d()
 end
 move_ent(e,e.d)
 e.d = nil
end

function wlk_in_d(enta)
 local mini,mind = 0,999
 for i=1,#dirs do
  local nx,ny,ndist = enta.pos.x+dirs[i].x
																			  ,enta.pos.y+dirs[i].y
																			  ,dist(p(nx,ny),entb.pos)
  if ndist < mind then
   mini = i
   mind = ndist
  end
 end
 
 enta.d = dirs[mini]
 move_ent(enta,dirs[mini])
 enta.d = nil
end

function ptoi(po)
--★ arbitrary w, fix
 return po.x+po.y*128
end

function ptoix(x,y)
	return x+y*128
end

function arr_to_tbl(arr)
 local tbl = {}
 for ti in all(arr) do
  tbl[ptoi(ti.po)] = ti.dst
 end
 return tbl
end

function wlk_to_plyr(ent)
 local lookup = arr_to_tbl(_srch_tiles)
 local mini,mind,curpt,curd,ocp =
  -1,999
 ,ptoi(ent.pos)
 ,lookup[curpt]
 ,{}
 for e in all(_ents) do
 	if not e.can_walk and is_player(e) == false then
 		ocp[ptoi(e.pos)] = true
 	end
 end
 
 if curd then
  mind = curd
 end
 for i=1,#dirs do
  local nx = ent.pos.x+dirs[i].x
  local ny = ent.pos.y+dirs[i].y
  
  local ndist = 999
  local ptile = lookup[ptoi(p(nx,ny))]
  if ptile and ocp[ptoi(p(nx,ny))] == nil then
   ndist = ptile
  end
  
  if ndist < mind then
   mini = i
   mind = ndist
  end
 end
 
 if mini == -1 then
  return
 end
 
 ent.d = dirs[mini]
 move_ent(ent,dirs[mini])
 ent.d = nil
end

function move_ent(ent,d)
	ent.hflip = d.x < 0 or (ent.hflip and d.x == 0)
 ent.dx = ent.d.x
 ent.dy = ent.d.y
 local np = add_t(ent.pos,d) 
 local sld,tile = chk_tile(np,0)
 
 if sld then
  ent.ease=ease_bump
  on_bump(tile,np,ent,d)
  return
 end
 -- pickup item
 local itm = sld_ent_at(np)
 if itm and itm.can_pickup then
  ent.ease=ease_bump
  itm:on_ent(ent,np,d)
  return
 end
 
 -- atk with weapon
 local atk_tiles = atk_ptrn(ent,ent.atkptr)
 for atk in all(atk_tiles) do
  local ent2 = sld_ent_at(atk)
	 -- ★ atk self bugfix on use item
	 if ent2 and ent2.can_dmg and ent2 != ent then
	  ent.ease=ease_bump
	  ent2:on_ent(ent,np,d) --★ 223
	  return
	 end
	 
 end
 
 p_sfx(sfx_wlk,ent)
 move_t(ent.pos,d)
 ent.ease=ease_lerp
end

function on_dmg(ent,atk,at,d)
	bump_at(atk,d)
 ent.hp-=atk.atk
 ent.flash=10
 add_atk(atk,ent)
 if ent.hp <= 0  then
	 del(_ents,ent)
 end
 
 sfx(4)
end

function on_atk(atk,ent,at,d)
 bump_at(atk,d)
 
 ent.hp-=atk.atk
 ent.flash=10
 add_atk(atk,ent)
 if ent.hp <= 0 then
	 del(_ents,ent)
 end
 
 sfx(4)
end

function on_bump(tile,at,ent,d)
  if (tile == 9
  or tile == 11
  or tile == 13
  or tile == 15)
  and is_player(ent) then
   mset(at.x,at.y,tile-1)
   -- ★ add rnd potion 
  end
  
  -- ★ tmp to dig walls
  mset(at.x,at.y,0)

  if tile == 11 and is_player(ent) then
   local lo_idx = flr(max(1,rnd(#_lo_chst)))
   local itm_idx = _lo_chst[lo_idx] 
   if itm_idx >= 0 then
    add_itm(itm_idx,p(at.x,at.y))
   else
    show_msg("the chest is empty")
   end
  else
   bump_at(ent,d)
  end
  
  p_sfx(_tile_sfx[tile],ent)
end

-- ★ move code?
function bump_at(ent,d)
 ent.pos_lst.x,
 ent.pos_lst.y=ent.pos.x+d.x*1.5
     ,ent.pos.y+d.y*1.5
end
-->8
-- ui

function add_win(x,y,w,h,txt)
 local win = {x=x,y=y,w=w,h=h,txt=txt} 
 win.upd = win_noop
 add(_wnd,win)
 push_upd(upd_win)
 return win
end

function win_noop(win)
end

function add_menu_win()
 local choice = {
  "equip",
  "items",
  "close"
 }
 
 local win = add_win(8,11,40,10*#choice,choice)
 win.upd = upd_inv
 win.sel = 1
 win.on_sel = on_menu_sel
end

function on_menu_sel(idx)
 if idx == 1 then
 	if #_eqp == 0 then
 	 show_msg("nothing to equip")
 	else
 	 add_inv_win(_eqp,on_eqp_sel,_plyr.chk_idx)
 	end
 elseif idx == 2 then
  if #_bpack == 0 then
   show_msg("empty")
  else
   add_inv_win(_bpack,on_inv_sel)
  end
 end
end

function add_inv_win(inv,sel_cbk,chk_idx)
 local str = {}
 for i in all(inv) do
  add(str,"".._lo_itms[i.id].name)
 end
 local win = add_win(8,11,40,10*#inv,str) 
 win.upd = upd_inv
 win.on_sel = sel_cbk
 win.sel = 1
 win.t = nil
 win.chk_idx = chk_idx
end

function on_eqp_sel(idx)
	eqp_item(idx,_plyr)
 plr_turn()
end

function on_inv_sel(idx)

 use_item(idx,_plyr)
 plr_turn()
end

function upd_inv(win)
 local inv = win.txt
 
 if btnp(⬇️) and win.sel+1 <= #win.txt then
  win.sel+=1
 elseif btnp(⬆️) and win.sel-1>0 then
  win.sel-=1
 elseif btnp(🅾️) then
  win.on_sel(win.sel)
  win.t=0.2
 end
 
 win.sel%=#win.txt+1
 win.sel = max(0,win.sel)
end

function ok_msg(txt)
 local l = #txt[1]
 for msg in all(txt) do
   msg = " " .. msg .. " " 
   l = max(#msg,l)
 end
 
 local len=l/2
 local w = add_win(64-len*4,64
           ,(l+1)*4
           ,max(10,7*#txt)
           ,txt)
           
 return w
end

function show_msg(txt)
 	local msg = " " .. txt.. " "
 local len=#msg/2
 local w = add_win(64-len*4,64
           ,(#msg+1)*4
           ,10
           ,{msg})
           
 return w
end

function prl(txt,t,pos,bg,fg)
 return {txt=txt,
         ot=t,
         t=t,
         pos=pos,
         bg=bg,
         fg=fg}
end

function add_atk(ent,def)
 add(_txts,
    prl("-"..ent.atk
       ,40
       ,p(def.pos.x,def.pos.y),
       7,8))
end

function add_hp(ent,hp)
 add(_txts,
   prl("+"..hp
      ,40
      ,p(ent.pos.x,ent.pos.y),
      7,11))
end

function add_mp(ent,mp)
 add(_txts,
   prl("+"..mp
      ,40
      ,p(ent.pos.x,ent.pos.y),
      7,12))
end

function upd_win()
 if btnp(❎) then
  local w = _wnd[#_wnd]
  if w.t == nil then 
   w.t = .3
  else
   w.t = min(w.t,.3)
  end
 end
 
 if #_wnd > 0 then
  local win = _wnd[#_wnd]
  if win.t == nil then
	  win:upd()
  end
 end
 
 -- update and close all closing windows
 for w in all(_wnd) do
  if w.t then
   w.t -= 1/99;
  end
  if w.t and w.t <= 0 then del(_wnd,w) end
 end
 
 if #_wnd == 0 then
  pop_upd()
 end
end
-->8
-- items

function crt_itm(name,onuse)
	 return {name=name,on_use=onuse}
end

function crt_eqp(name,atkp,atkptr,onuse)
 local itm = crt_itm(name,onuse)
 itm.atkp = atkp
 itm.atkptr = atkptr
 return itm
end

function add_itm(id,po)
 local ent = ent(id,po)
 ent.anim = anim({64+(id)},1,1)
 ent.upd = noop
 ent.upd_ren = wobble_upd
 ent.itm = true
 ent.can_walk = false
 ent.can_dmg = false
 ent.can_pickup = true
 ent.outline = true
 ent.on_ent = on_pickup
 ent.on_use = _lo_itms[id].on_use --on_use_potion
 add(_ents,ent)
end

function on_pickup(itm,ent,po,d)
 bump_at(ent,d)
 del(_ents,itm)
 
 if itm.id >= 0 and itm.id < 0x10 then
	 add(_bpack,itm)
 elseif (itm.id >= 0x10 and itm.id < 0x20) then
  add(_eqp,itm)
 end
 p_sfx(5,ent)
end

function on_use_potion()
 _plyr.hp+=1
 add_hp(_plyr,1)
 p_sfx(5,_plyr)
end

function on_use_mana()
--★ fix mp _plyr.hp+=1
 add_mp(_plyr,1)
 p_sfx(5,_plyr)
end

function on_use_grt_ptn()
 _plyr.hp+=3
 add_hp(_plyr,3)
 p_sfx(5,_plyr)
end

function on_equip()
 sfx(2)
end

function eqp_item(idx,ent)
 if #_eqp == 0 then
  return
 end
 local eqp = _eqp[idx]
 local itm = _lo_itms[eqp.id]
 ent.atk = itm.atkp
 ent.atkptr = itm.atkptr --★ 222
 ent.chk_idx = idx --★ 111
 sfx(3)
end

function use_item(idx,ent)
 if #_bpack == 0 then
	 return
	end
 local item = _bpack[idx]
 item.on_use()
 del(_bpack,item)
end

function wobble_upd(ent)
 ent.pos_ren.x,
 ent.pos_ren.y = ease_sin(ent)
end

_updt = 0
function ease_sin(ent)
 return ent.pos.x,
        ent.pos.y+(sin(_updt)*.15)
end

-- weapons
function atk_ptrn(ent,wp)
 local drx,dry =vec_right(ent.dx,ent.dy) 
 local dlx,dly = -drx,-dry
 local dux,duy = ent.dx,ent.dy
 local lr = {
 	drx,dry,dlx,dly,0,0,dux,duy
 }
 
 local res = {}
 for i=1,#lr-1,2 do
 	add(res,p(ent.pos.x+ent.dx+lr[i],
 										 ent.pos.y+ent.dy+lr[i+1]))
 end
 
 if wp == 1 then
 	return {res[3]}
 elseif wp == 2 then
 	return {res[3],res[4]}
 elseif wp == 3 then
  return {res[1],res[2],res[3]}
 end
 
 return {res[3]}
end
-->8
-- utils

-- types
function p(x,y)
	return {x=x,y=y}
end

function vec_right(x,y)
 return y*-1,x	
end

function vec_reflect(x,y)
	return -x,-y
end

-- functions
function dist(a,b)
 local abx,aby = a.x-b.x, a.y-b.y
 return sqrt(abx*abx+aby*aby)
end

function p_len(a)
 return dist(a,p(0,0))
end

function is_player(ent)
 return ent.id == _pid
end

function arr_select(arr,sel)
 local res = {}
 for it in all(arr) do
  add(res,sel(it))
 end
 return res
end

-- projections
function ent_to_idx(ent)
 return ptoi(ent.pos)
end

function lerp(a,b,d)
	if(d >= 1.0) return b
 return a+(b-a)*d
end

function add_t(po,d)
 return p(po.x+d.x,po.y+d.y)
end

function move_t(po,d)
 po.x += d.x
 po.y += d.y
end

function next_d()
 return dirs[flr(rnd(4))+1]
end

function next_p(_p)
 local d = next_d()
 return p(_p.x+d.x,_p.y+d.y),d
end

function p_sfx(id,ent)
 if(is_player(ent)) sfx(id)
end

-- animations
function anim(f,fps,loop)
 return {f=f,fps=fps,loop=loop}
end

function anim_pl(fps)
 return
 {
  fps=fps,
  frame_cnt=0,
  frame_i=1,
 }
end

function upd_anim(pl,anim)
 if pl.frame_cnt >= 60/pl.fps then
  pl.frame_i+=1
  pl.frame_cnt=0
 end
 
 return anim.f[pl.frame_i%#anim.f+1]
end

-- note this expects 
-- b to wrap a point in po
function cmp_p(a,b)
assert(a != nil, "a is nil")
assert(b != nil, "b is nil")
 return a.x == b.po.x and a.y == b.po.y
end

-- straight poitn compare
function cmp_po(a,b)
 return a.x == b.x and a.y == b.y
end

function pline(x1,y1,x2,y2)
 local dx,dy = abs(x2-x1),
 													 abs(y2 - y1)
 local signx,signy = 1,1
 local derr = dx*0.5
 local px,py = x1,y1
 if( dy > dx)  derr = -dy * 0.5
 
 if( x2 < x1 ) signx = -1 
 if (y2 < y1)  signy = -1

 
 local points = {
 }
 while true do
 	add(points,{x=px,y=py})
 	
 	if px == x2 and py == y2 then
 	  return points
 	end
 	
 	if derr > -dx then
 		derr -= dy
 		px += signx
 	end
 	
 	-- check again, what happens without
 	if px == x2 and py == y2 then
   	add(points,{x=px,y=py})
 	  return points
 	end
	
	 if derr < dy then
	  derr += dx
	  py += signy
	 end
		
 		-- check again, what happens without
 	if px == x2 and py == y2 then
	  	add(points,{x=px,y=py})
 	  return points
 	end
 end
end

function line_of_sight(a,b)
 local l = pline(a.x,a.y,b.x,b.y)
 for _p in all(l) do
  if chk_tile(_p,2) then
   return false
  end  
 end
 
 return true
end

function sig_match(a,b,mask)
	return bor(a,mask) == bor(b,mask)
end

-- rnd

function rnd_rng(_min,_max)
 local r = max(_min,ceil(rnd()*_max))
 return min(r,_max)
end 

-- 
-- flood alt
-- 

function flood_fill(po,ocp,maxd)
 local dpth,queue,visited = 0,{},{}
 visited[ptoi(po)] = true
 local nxt = {}
 add(nxt,{po=p(po.x,po.y),dst=0})
	maxd = maxd or 255
 local found = {nxt[1]}
 while dpth < maxd do
 	dpth+=1
	 for ite in all(nxt) do
		 for d in all(dirs) do
		  local it = ite.po
		  local np = p(it.x+d.x,it.y+d.y)
		  local pi = ptoi(np)
		  if chk_solid(np) == false
					  and ocp[pi] == nil
					  and visited[pi] == nil
		  then
		   visited[ptoi(np)] = true
		   add(queue,{po=p(np.x,np.y),dst=dpth})
		  end
		 end
	 end
	 
	 nxt = {}
	 for q in all(queue) do
	  add(nxt,
	  {po=p(q.po.x,q.po.y),
	   dst=q.dst})
	  add(found,
	   {po=p(q.po.x,q.po.y),
	    dst=q.dst})
	 end
	 	 
	 if #queue == 0 then
	  return found
	 end
	 
	 queue = {}

 end
 
-- printh("maximum depth flooded")
-- stop()
 return found
end


-->8
-- gen

function go_to_o(lookup,pos,ocp)
 local cp,cd = min_d_on_map(lookup,pos,ocp)
 if not cp then
  return
 end
 local path = {p(pos.x+cp.x,pos.y+cp.y)}
 local nxtp = path[1]
 while cd > 0 do
 	cp,cd = min_d_on_map(lookup,nxtp,ocp)
 	local np = p(nxtp.x+cp.x,nxtp.y+cp.y)
 	add(path,p(np.x,np.y))
 	nxtp = np
 end
 
 return path
end

function min_d_on_map(lookup,pos,ocp)
-- local lookup = arr_to_tbl(nodes)
 local mini,mind = -1,999
 local curd = lookup[ptoi(pos)]
 
 -- if we are on map our min is our current dist
 if curd then
  mind = curd
 end
 
 for i=1,#dirs do
  local nx = pos.x+dirs[i].x
  local ny = pos.y+dirs[i].y
  
  local ndist = 999
  local look_d = lookup[ptoi(p(nx,ny))]
  -- if lookd_d is on path  
  -- and aint occupied
  -- and is new low
  if look_d 
  and ocp[ptoi(p(nx,ny))] == nil
  and look_d < mind
  then
			mini = i
			mind = look_d
  end
 end
 
 if mini == -1 then
  return
 end
 
 return dirs[mini],mind
end

function path_between(_a,_b,ocp)
	local dpth,queue,visited = 0,{},{}
 visited[ptoi(_a)] = true
 local nxt = {{po=_a,dst=0}}
 local found = {{po=_a,dst=0}}
 local goal_rch = false
 while not goal_rch do
 	dpth+=1
 	_dbg[2] = "t:"..dpth
		 _dbg[4] = "nxt: "..#nxt
	 for ite in all(nxt) do
	 	
		 for d in all(dirs) do
		 	local nxtp= ite.po
		  local np = p(nxtp.x+d.x
		  											,nxtp.y+d.y)
		  local pi = ptoi(np)
		  if chk_solid(np) == false
					  and ocp[pi] == nil
					  and visited[pi] == nil
		  then
		   visited[ptoi(np)] = true
		   add(queue,{po=p(np.x,np.y),dst=dpth})
		  end
		 end
	 end
	 
	 nxt = {}
	 for q in all(queue) do
	  add(nxt,
	  {po=p(q.po.x,q.po.y),
	   dst=q.dst})
	  add(found,
	   {po=p(q.po.x,q.po.y),
	    dst=q.dst})
	  if (q.po.x == _b.x 
	  and q.po.y == _b.y) then
	  	_dbg[5] = "✽ound" .. #found
	   return found
	  end
	 end
	 	 
	 if #queue == 0 then
	  _dbg[5] = "not found"

	  return found
	 end
	 
	 queue = {}

 end
 return found
end

-- generate

function add_door(r,hr,existing)
 local ranx = rnd()
 local np = {}
 if not hr then
     np =
         p(in_rng(r.x+flr(ranx*r.w),r.x+1,r.x+r.w-1),
     									r.y+r.h)
    else
      np = p(r.x+r.w,
           in_rng(r.y+flr(ranx*r.h),
                  r.y+1,r.y+r.h-1))
    end
 existing[ptoi(np)] = np
end

function regen(iter,sz)
--	 reload(0x1000, 0x1000, 0x2000)
  local w,h = sz,sz
  local rc = rct(0,0,w,h)
  local iters = iter
  local rs = {rc}	
  local cnt = 0
  _ps = {}
  while iters > 0 do
  	local nxt = {}
   for ir in all(rs) do
    local hr = iters%2==0
    local valid = false
    local retry = 10
    local nl,nr = {},{}
    while(not valid) do
	    nl,nr = spl_rct(ir,hr)
	    if not hr then
	     local a,b = p(nl.x,nl.y+nl.h),
	                 p(nl.x+nl.w,nl.y+nl.h)
	     valid = _ps[ptoi(a)] == nil and _ps[ptoi(b)] == nil
	    else
	      local a,b = p(nl.x+nl.w,nl.y),
	                 p(nl.x+nl.w,nl.y+nl.h)
	     valid = _ps[ptoi(a)] == nil and _ps[ptoi(b)] == nil
	    end
	    retry -= 1
	    if retry < 0 then
	     break
	    end
    end
    cnt += 1
    add_door(nl,hr,_ps)
    add(nxt,nl)
    add(nxt,nr)
   end
   
   rs = {}
   for n in all(nxt) do
   	add(rs,n)
   end
   iters-=1
  end
  
  return rs
end

-- utils

function in_rng(n,_min,_max)
 return min(_max,max(_min,n))
end

-- rect

function rct(x,y,w,h)
 return {x=x,y=y,w=w,h=h}
end

function spl_rct(r,hor)
	local x,y,w,h = r.x,r.y,r.w,r.h
 
 local sp = in_rng(rnd(),.34,.66)
 local nw,nh = flr(w*sp),
 														flr(h*sp)
 if hor then
  return rct(x,y,nw,h),
  							rct(x+nw,y,w-nw,h)
 else
  return rct(x,y,w,nh),
  							rct(x,y+nh,
  							w,h-nh)
 end
end

-- map things to tilemap
function map_rct(r)
 local x,y,w,h = r.x,r.y,r.w,r.h
 local idx = 1
 local flrid = 2+_room_idx
 for i=0,w,1 do
  mset(x+i,y,idx)
  mset(x+i,y+h,idx)
 end
 
 for i=0,h,1 do
  mset(x,y+i,idx)
  mset(x+w,y+i,idx)
  if i != 0 and i != h then
	  for mx=1,w-1,1 do
	  	mset(x+mx,y+i,flrid)
	  end
  end

 end
 
 _room_idx+=1
 _room_idx%=5
end

function map_rct_rnd(r)
-- ★ hack to never gen rooms of size 1
 local nw =	rnd_rng(r.w/2,r.w)
 local nh =	rnd_rng(r.h/2,r.h)
 local nx = r.x
 local x,y,w,h = nx,r.y,
 																nw,nh
 local idx = 1
 local flrid = 2+_room_idx
 for i=0,w,1 do
  mset(x+i,y,idx)
  mset(x+i,y+h,idx)
 end
 
 for i=0,h,1 do
  mset(x,y+i,idx)
  mset(x+w,y+i,idx)
  if i != 0 and i != h then
	  for mx=1,w-1,1 do
	  	mset(x+mx,y+i,flrid)
	  end
  end

 end
 
 _room_idx+=1
 _room_idx%=5
end

function map_doors()
 for k,v in pairs(_ps) do
  mset(v.x,v.y,9)
 end
end

-- 
-- ● gen maze
--

-- gen and dig
function init_gen()
	sig_dir = {
	0b11111111,
	0b01110110, -- left
	0b10110011, -- up
	0b11011001, -- right
	0b11101100, -- down
	}
	
	sig_msk = {
	0b00000000,
	0b00001001,
	0b00001100,
	0b00000110,
	0b00000011,
	}
	
	_iterations = 3
	_size = 30
	sig_dig = 255
	t_dig = 49
	t_ndig = 1
end


function update_digables()
	_digable = {}
	mapsig(function(x,y,sig)
								 if chk_solid(p(x,y)) and sig == sig_dig then
											mset(x,y,t_dig)
											add(_digable,{x=x,y=y})
									end								
								end)
end

function is_carvable(a)
	for i=1,#sig_dir do
	 if sig_match(a,sig_dir[i],sig_msk[i]) then
	 	return true
	 end
	end
	return false
end

function dig(po)
 local px,py,dx,dy = po.x,po.y,0,1
	mset(px,py,0)
	local nextdig = {}
	for dr in all(dirs) do
		if not chk_solid(po) and is_carvable(tile_sig(add_t(po,dr))) then
			add(nextdig,add_t(po,dr))
		end
	end	
	
	return nextdig
end

function dig_tunnel()
 local start = arr_choose(_digable)
 local ndig = dig(start)
 local keepdigging = #ndig > 0

	local dug = {}
 while keepdigging do
		local pdig = arr_choose(ndig)
		if dug[ptoi(pdig)] then
			printh("backtracking lets break")
			break
		end
		dug[ptoi(pdig)] = true
 	ndig = dig(pdig)

 	_curx=pdig.x*8
 	_cury=pdig.y*8
 	keepdigging = #ndig > 0 	
 end
end

function gen()
	init_gen()
 fill_map(1)
 _gen_rct = regen(_iterations,_size)	
 _room_idx = 0
 foreach(_gen_rct,map_rct_rnd)

-- set tiles digable when
-- sourounded by walls
	set_digable_start()
	
	update_digables()
	while #_digable>1 do
		local st = dig_tunnel()
		update_digables()
	end
	
 set_digable_start()
 
end

function set_digable_start()
	mapsig(function(x,y,sig)
								 if chk_solid(p(x,y)) then
									 if is_digable(sig) then
									 	mset(x,y,t_dig)
									 	add(digs,p(x,y))
									 else
									 	mset(x,y,t_ndig)
									 end
								 end
							end)
end

function is_digable(a)
 if sig_match(a,255) then
 	return true
 end
	return false
end

-- utils for rnd

function rnd_idx(n)
	return flr(rnd()*n) + 1
end

function arr_choose(myarr)
	local mri = rnd_idx(#myarr)
	return myarr[mri]
end

function mapsig(func)
	for y=0,_size do
		for x=0,_size do
			func(x,y,tile_sig(p(x,y)))
		end
	end
end

function fill_map(t)
	mapsig(function(x,y,sig)
		mset(x,y,t)
		end)
end

function flag_map()
 _cf = 0
 local mapf = {}
 mapsig(
 function(x,y,sig)
 		local idx = ptoi(p(x,y))
   if mapf[idx] then
   elseif not chk_solid(p(x,y)) then
   	flag_section(x,y,_cf,mapf)
   	_cf+=1
   end
 end
 )
 
 _flagmap = {}
 _flagmap = mapf
 _dbg[3] = #_flagmap
 _dbg[4] = _cf
end

function flag_section(x,y,f,res)
	local flooded = flood_fill(p(x,y),{})
	for po in all(flooded) do
--		add(res,{po=po.po, f=f})
		res[ptoi(po.po)] = {po=po.po, f=f}
	end
--	stop()
end

-- signature funcs

function tile_sig(po)
 local sig = 0
 for i=1,8 do
  local d = dir8[i]
  if chk_solid(add_t(po,d)) then
   sig += 1
  end
  if i < 8 then
  	sig = shl(sig,1)
  end
 end
 return sig
end

function inbound(x,y)
	return x > 0 and x < _size and y > 0 and y < _size
end

function gen_junctions()
	_junctions = {}
 mapsig(
	 function(x,y,sig)  
		 if inbound(x,y-1)
		 and inbound(x,y+1)
		 and  sig_match(sig,0b10100000,
		 																			0b00001111) 
		 and chk_solid(p(x,y))
			then
		 	add(_junctions,
		 	{
		 		x=x,
		 		y=y,
		 		a=_flagmap[ptoi(p(x,y-1))].f,
		 		b=_flagmap[ptoi(p(x,y+1))].f
	 		})
		 elseif inbound(x-1,y)
		 and inbound(x+1,y)
		 and sig_match(sig,0b01010000,
		 																		0b00001111)
			and chk_solid(p(x,y))
			then
			 add(_junctions,
			 	{
			 		x=x,
			 		y=y,
			 		a=_flagmap[ptoi(p(x-1,y))].f,
			 		b=_flagmap[ptoi(p(x+1,y))].f
		 		})
		 end 
	 end
 )
end

function merge_small_areas()
	for i=0,_cf do
  local cons = {}
 	local p = get_passage(_junctions,i)
 	if(#p > 0) then
	  for co in all(p) do
	  	if not cons[co.v] then
	  		cons[co.v] = true
	  		local minsz = 12
	  		if section_sz(co.v) <= minsz
	  				 and section_sz(i) <= minsz
	  	 then
	  			mset(co.x,co.y,48)
	  		end
	  	end
	  end 
 	end
	end
end

function merge_areas()
 
 gen_junctions()
 merge_small_areas()
 flag_map()
 gen_junctions()
 -- 
 -- add door to random passage
 -- 
 for i=0,_cf do
  local cons = {}

 	local p = get_passage(_junctions,i)
 	if(#p > 0) then
	 	local opn = arr_choose(p)
	  for co in all(p) do
	  	if not cons[co.v] then
	  		cons[co.v] = true
	  		mset(co.x,co.y,9)
	  	end
	  end 
 	end
	end
end

function section_sz(idx)
	cnt = 0
	for k,v in pairs(_flagmap) do
		cnt = v.f == idx and cnt+1 or cnt
	end
	
	return cnt
end

function get_passage(juncs,to)
	local res = {}
	for j in all(juncs) do
		if j.a != j.b and (j.a == to or j.b == to) then
			local other = j.a == to and j.b or j.a
			add(res,{x=j.x,y=j.y,v=other})
		end
	end
	return res
end

function add_slimes()
	mapsig(function(x,y,sig)
		local r = rnd(1000)
		if not chk_solid(p(x,y)) then
			if sig == 0 and r <= 100 then
			 add_trap(4,p(x,y))
			elseif r <= 25  then
			 add_mob(5,p(x,y))
			end
		end
	 
	end)
end

-->8
-- █ todo

-- [] poison tiles
-- [] poison slime trail
-- [] potion drop when destroying pots
-- [] slime idle patterns
-- [] slime sight
-- [] rand room layout
-- [] rand rooms
-- [] trigger trap dmg

-- █ done
-- [x] move blackout to screenspace
-- [x] spawn items only to chests
-- [x] fow
-- [x] atk adjecent
-- [x] atk dst
-- [x] turn order
-- [x] enemies turn is 2 frames in none visible


-- ★★★ defects ★★★

-- [] ★111 menu checked set on player for viewing selection in ui
-- [] ★222 atk and atk pattern set on entity directly
-- [] ★223 onent used for both atk and pickup, does not work when atk multiple tiles
-- [] ★224 sld_ent_at slow?

-- █ ideas

-- exploding barells
-- could be stationary enemies with 1:hp and eplosion on kill
-- bow n arrow, unlim range til hit enemy
-- whirlpools that suck everybody in for each turn active
-- thermal went traps
-- smoke/squid ink trap, lower visibility
-- bioluminance algea, step on to increase visibility
-- toxic spore tiles, release poision clouds
-- wave tiles, push the player in a direction
-- shells instead of pots
-- open seashells that slam shut, trap
-- jellyfish with a tail of dangerous tentacles
-- moray trap, peeking out of walls and attacking if the player gets close
-- 
__gfx__
0000000000000000000000050000000000000000010000101011110100000000ee5555ee00888800eeeeeeee00000000eeeeeeee00000000eeeeeeee00000000
0000000055555550000000000000000000000000101001010101101000000000e55ee55e08800880eeeeeeee00000000eeeeeeee00000000eeeeeeee00000000
007007005555555005050000000000000000000001011010101001010000000055eeee5588000088eeeeeeee08888880eeeeeeee08888880eeeeeeee00000000
00077000555555500000000000050000000000000011110001011010000000005eeeeee580088008e555555e88888888eeeeeeee00888800eeeeeeee08888880
00077000555555500000005000505000000000000011110001011010000000005eeeeee58088880855eeee5588800888e555e55e08808880e55eeeee08888808
00700700555555500050000000000000000050000101101010100101000000005eeeeee5800888085eeeeee50000000055eeee5588088888555eeee508888088
00000000555555500000500000000005000505001010010101011010000000005eeeeee580888808555ee55588800888eee55e5e08808880eeee5eee00880880
0000000000000000000000000000005000050000010000101011110100000000eeeeeeee000000005555555588888888eee55eee00088000eee55eee00088800
90000009000000000000000000000000005000000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000505505500000000000000000050000000001100003000000000000000000000000000000000000000800008000000000000000000000000000000000
00000000000000000000000005000005050005001010010100033300000000000000000000000000000000000888888000000000088888800000000000000000
0000000000000000000000000500005005000500010000100033333000000000000000000008800005555550888888880000000000eeee000000000000000000
00000000000000000000000000500050000000500100001000000000000000000000000000088000550000558880088800000000088088800000000000000000
00000000000000000000000000500050000000501010010133000030000000000000000008888000500000050000000000000000880888880000000000000000
00000000000000000000000000500000000000000001100000003333000000000000000008888000555005558880088800000000088088800000000000000000
90000009550055050000000000500000000000000010010000033333000000000000000008008000555555558888888800000000000880000000000000000000
000000000000000066606660ccc0ccc0000000001010010110111101000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555000000060000000c0000000000101101001011010000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555060666060c0ccc0c0000000001010010110100101000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555500000000000000000000000000100001011011011000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555066606060ccc0c0c0000000000100001011011011000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555500000000000000000000000001010010110100101000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555066660660cccc0cc0000000000101101001011010000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001010010110111101000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee1e1e1e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee1eee1e1e1e1e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee1e1e1e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eee1eee1e1e1e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee1e1e1e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee1eee1e1e1e1e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee1e1e1e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eee0eee1e1e1e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee9eeeeeee9eeeeeee9eeeeeee9eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee909eeeee909eeeee909eeeee909ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e990009ee990009ee990009ee990009e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9bbbb9ee9cccc9ee988889ee9aaaa9ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9bbb9eee9ccc9eee98889eee9aaa9eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9bb9eeee9cc9eeee9889eeee9aa9eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee99eeeeee99eeeeee99eeeeee99eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeee99eeeee999000000090000909900009099000990990000000000000090000000900000009000090000900009990000000000000000
eeeee99eeeeee99eeeeee999eeee9999000009000000090900009909009099090000090000000990000009900000009000999000090990090000000000000000
eeee999eeeee999eeeee999ee9e99999000009900000099000090990000009900000990000009990000099900000099009999900009000900000000000000000
eee999eee9e999eee9e999eee999999e000090000000900900009099000090990909090000090900090999000900999000990990090900900000000000000000
e9ee9eeee9999eeeee999eeeee9999ee000900000009000000090900000900090990900009909000009990000099990000099999090099000000000000000000
ee9eeeeeee99eeeeeee9eeeeeee99eee009000000090000000900000009000900099000000990000000900000009000000909990900090090000000000000000
e9e9eeeee9e99eeee9ee9eeee9ee99ee090000000900000009000000090000000909900009090000090090000900900009000900909900900000000000000000
eeeeeeee9eeeeeee9eeeeeee9eeeeeee900000009000000090000000900000009000000090000000900000009000000090000000990009090000000000000000
eeeeeeeeeee9eeeeee99eeeeeeee9eee000999090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee9eeeeeee99eeeeee99eeeeee9999e009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee9eeeeeee99eee9ee99eeee99999e099009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee9ee9eeee9ee99e999ee99ee9ee9999090090990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e999ee9ee999ee999999ee99eeeee99e900900990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9999eeee9999eee99999ee9eeeee9ee000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e999eeeee999eeee999999eeeeee9eee000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee99999eeeeeeeeeee000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000a0000000900009000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000aa00000099000000900000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000aa000000990000090090000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000090aa0000909900000999009000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000009a00000099000000999900000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000900000009000000999000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000090090000900900000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000d6000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000009900000000000000d6d000000d60009909055555500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000009900000009900000d6d000000d600099990056666650
000000000000000000000000000000000000000000000000000000000000000000000000000000000909900009009900090d6d000900d6000900999056666665
0000000000000000000000000000000000000000000000000000000000000000000000000000000000990000009990000099d000009960000009099056666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000900000009000000090000000900000090090056666665
00000000000000000000000000000000000000000000000000000000000000000000000000000000090090000900900009009000090090000900900056666650
00000000000000000000000000000000000000000000000000000000000000000000000000000000900000009000000090000000900000000000000055555500
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e99999ee
000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000e9999090
000000000000000000000000000000000000000000000000000000000000000000000000000000000009900000000000000000000000000000000000e9990909
000000000000000000000000000000000000000000000000000000000000000000000000000000009099000000000000000000000000000000000000e9999090
000000000000000000000000000000000000000000000000000000000000000000000000000000000990000000000000000000000000000000000000e9eee900
000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000ee99e090
000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000eeeeee09
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eee
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090ee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090999999
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090999900
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009099990e
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009900e
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0
000000000000000000098900000989000009890000098900eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000
000000000000000090099009000990009009900900099000eeeeeeeeeeeee3eeeeeeeeeeeeeeeeee009000900909000090900000090090000000000000000000
000000000000000099090099090900909909009909090090eee333eeeeee33eeeee333eeeee33eee000999000099900009990000009990000000000000000000
000000000000000099999999999999999999999999999999ee33333eeee3333eee33333ee333333e000898000089990008999000099980000000000000000000
0000000000000000e99999ee99999999e99999ee99999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000999000099900009990000009990000000000000000000
00000000000000009e999e9e9999999e9e999e9e9999999e33eeee3ee3ee3eee33eeee3e333eeeee000999000009990000999000000999000000000000000000
0000000000000000ee9e9eeeee9e9eeeee9e9eeeee9e9eeeeeee3333eee333eeeeee3333eeeee33e000999000009990000999000000999000000000000000000
0000000000000000e9eee9eee9eee9eee9eee9eee9eee9eeeee33333eee3333eeee33333eee33333000999900009999000099900009999000000000000000000
0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9999eeee9999eeee9999ee009998000000998000099800000099000000000000000000
0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeee9999eeee9999eee999999ee999999ee999999e009909900009099900990990000999800000000000000000
0000000000000000ee9999eeeeeeeeeeee9999eeee9999eee999999ee998989ee998989ee999999e009900000009000000990000009900990000000000000000
0000000000000000e999999eee9999eee999999ee998989ee998989ee999999ee999999ee998989e000990000009900000099900000990000000000000000000
000000000000000099989899e999999e99989899e999999ee999999ee999999eee9999eee999999e000099009900990009900990090099000000000000000000
0000000000000000999999999998989999999999e999999eee9999eeee9999eee9ee9e9eee9999ee990099000990990000999990099099000000000000000000
0000000000000000999999999999999999999999e999999ee9ee9e9ee9e9ee9ee9ee9e9ee9ee9e9e099990000099900000999000099990000000000000000000
0000000000000000e999999e99999999e999999eee9999eee9e9ee9e9ee9e9ee99e9ee999eee9ee9009900000000000000000000009900000000000000000000
00000000000000000099990000000000000000000000000000000000009990000009990000099900000999000000000000999900000000000099990000999900
00000000000000000999909000999900000000000000000000000000009990000009990000099900000999000009900009999990009999000999999009999990
00000000000000000099990009999090000000000000000000000000000900000009900000099000000990000009900009989890099999900998989009989890
00000000000000000000000900999900000000000000000000000000098889000051110000058800005888000098800009999990099898900999999009999990
00000000000000000999999009000000000000000000000000000000098889000511116000658800058888600098890000999900099999909099990000999900
00000000000000000909900009099009000000000000000000000000095559000522226000045400054444600009590009090090909999000900900009090090
00000000000000000099090000090000000000000000000000000000005050000022020000440660004044000066500090900900009009009009000000900900
00000000000000000090099000099000000000000000000000000000005050000050066000500000006605500000500000900900090090000000000000000900
ee9999eeeeeeeeeeee9999eeeeeeeeee006660000000000000000000000000000000000000000000000000000009900000000000000000000000000000000000
e999909eee9999eee999909eee9999ee006660000000000000606000060006000600060000000000000000000009900000000000000000000000000000000000
ee9999eee999909eee9999eee999909e006660000660000006606600000000000000000000000000000000000009000000000000000000000000000000000000
eeeeee5eee99995eee00005eee99995e000000000000000000000000000600000600060000000000000000000098800000000000000000000000000000000000
e9999956e9900956e9999956e9900956000000000006600006606600000000000000000000000000000000000098890000000000000000000000000000000000
e909905eee909e5ee909905eee909e5e066600000000000000606000060006000600060000000000000000000009690000000000000000000000000000000000
ee9909eeeee9eeeeee99e9eeeee9eeee066600000000066000000000000000000000000000000000000000000066600000000000000000000000000000000000
ee90099eeee99eeeee9ee99eeee99eee000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111777777711117777711111777111111177771111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111733733711117333711117737777111173371111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111733333711117377711117333337111177371111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111733333711117333711117737737111117371111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111773337711117773711117377737111177377111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111177377111117333711117377337111173337111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111117771111117777711117777777111177777111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
01010100010101000101010001010100515151505151515051515150515151505151515051515150515151505151515051515150515151505151515051515150
10101010101010101010101010101010151515101515151015151510151515101515151015151510151515101515151015151510151515101515151015151510
01010100010101000101010001010100515151505151515051515150515151505151515051515150515151505151515051515150515151505151515051515150
10101010101010101010101010101010151515101515151015151510151515101515151015151510151515101515151015151510151515101515151015151510
00000000000000000000000000000000555555505555555055555550555555505555555055555550555555505555555055555550555555505555555055555550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000002220000522200005222000052220000500000000220000002200000022000000220000000000000022200000
10101010101010101010101010101010151515102020101020201010202000002020000055555550121010101210101012101010121010101515151010201010
01010100010101000101010001010100515151502121010021210100252500002525000055555550020101000201010002010100020101005151515022210100
10101010101010101010101010101010151515102020101020201010202000002020000055555550121010101210101012101010121010101515151020101010
33013300333131000331010001010100515151502221015022210150222000502220005055555550222101002221010022210100222101005151515022210100
30103030131030101030101010101010151515101010101010101010005000000050000055555550101010101010101010101010101010101515151010101010
30003030030030000030000000000000555555500000500000005000000050000000500055555550000000000000000000000000000000005555555000050500
30003030030030000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000
33003030333033300330000000000000000000002220000522200005222000052220000500000000000000000000000000000000000000000000000022200000
10101010101010101010101010101010151515102020101020200000202000002020000055555550555555501515151015151510151515101515151010201010
33013300333131000331010001010100515151502121010025250000252500002325000055555550555555505151315051515150515151505151515022210100
30103030131030101030101010101010151515102020101020200000202000002020000055555550555555501313131015151510151515101515151020101010
31013130030131000131010001010100515151502221015022200050222000502220005055555550555555505151515051515150515151505151515022210100
30103030131030101030101010101010151515101010101000500000005000000050000055555550555555501315151015151510151515101515151010101010
33003030333033300330000000000000555555500000500000005000000050000000500055555550555555505555533055555550555555505555555000050500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333300000000000000000000000000050000
33003300333030000330000000000000000000002220000522200005222000052220000533300000000000002020000020200000202000000000000000000000
30103030131030101030101010101010151515102020000020200000202000002020000000300000000000002020101020201010202010101515151015151510
31013130030131000131010001010100515151502525000025250000232500002325000003300000000000002221010022210100222101005151515051515150
30103030131030101030101010101010151515102020000020200000202000002020000000300000000000001020101010201010102010101515151015151510
33013130333133300331010001010100515151502220005022200050222000502220005033300000000000000121010001210100012101005151515051515150
10101010101010101010101010101010151515100050000000500000005000000050000000000000000000001010101010101010101010101515151015151510
33300000000000000000000000000000555555500000500000005000000050000000500000000000000000000000000000000000000000005555555055555550
30300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30300000000000000000000000000000000000002220000522200005222000052220000500000000000000002020000000000000202000000000000000000000
30301010101010101010101010101010555555502020000020200000202000002320000055555550555555502020101015151510202010101515151015151510
33310100010101000101010001010100555555502525000023250000232500002325000055555550555555502221010051515150222101005151515051515150
10101010101010101010101010101010555555502020000020200000202000002320000055555550555555501020101015151510102010101515151015151510
33313330010101000101010001010100555555502220005022200050222000502220005055555550555555500121010051515150012101005151515051515150
10301030101010101010101010101010555555500050000000500000005000000050000055555550555555501010101015151510101010101515151015151510
33303330000000000000000000000000555555500000500000005000000050000000500055555550555555500000000055555550000000005555555055555550
30003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33303330000000000000000000000000000000002220000522200005222000052220000500060000202000002020000000000000202000002020000020200000
10101010101010101010101010101010555555502020000020200000232000002029990055666550202010102020101015151510202010102020101020201010
33013300333131000331010001010100555555502325000023250000232500002929909066666660222101002221010051515150222101002221010022210100
30103030131030101030101010101010555555502020000020200000232000002029995056666650102010101020101015151510102010101020101010201010
31013130030131000131010001010100555555502220005022200050222000502220095656555650012101000121010051515150012101000121010001210100
30103030131030101030101010101010555555500050000000500000005000000090905055555550101010101010101015151510101010101010101010101010
33003030333033300330000000000000555555500000500000005000000050000009500055555550000000000000000055555550000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000009900000000000000000000000000000000000000000000000000000000000
33003300333030000330000000000000000000000000000000000000333000000000000000000000202000000000000000000000000000000000000000000000
30103030131030101030101010101010555555505555555055555550003000005555555055555550202010101515151015151510151515101515151015151510
31013130030131000131010001010100555555505555555055555550333000005555555055555550222101005151515051515150515151505151515051515150
30103030131030101030101010101010555555505555555055555550300000005555555055555550102010101515151015151510151515101515151015151510
33013130333133300331010001010100555555505555555055555550333000005555555055555550012101005151515051515150515151505151515051515150
10101010101010101010101010101010555555505555555055555550000000005555555055555550101010101515151015151510151515101515151015151510
33003300333030000330000000000000555555505555555055555550000000005555555055555550000000005555555055555550555555505555555055555550
30003030030030000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30003030030030000030000000000000000000002020000020200000232000000000000000000000202000002020000020200000202000000000000021000010
30103030131030101030101010101010151515102020101020200000202000005555555015151510202010102020101020201010202010101515151020101111
33013130333133300331010001010100515151502221010022200000222000005555555051515150222101002221010022210100222101005151515022211110
10101010101010101010101010101010151515101020101000200000002000005555555015151510102010101020101010201010102010101515151020211110
33013300333131000331010001010100515151500121010000200000332000005555555051515150012101000121010001210100012101005151515022211100
30103030131030101030101010101010151515101010101000000000000000005555555015151510101010101010101010101010101010101515151011111010
30003030030030000030000000000000555555500000000000000000000000005555555055555550000000000000000000000000000000005555555010100101
30003030030030000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000010
33003030333033300330000000000000000000002020000000000000202000000000000000000000000000000000000000000000202000000000000021000010
10101010101010101010101010101010151515102020101015151510202010101515151015151510151515101515151015151510202010101515151020101111
33013300333131000331010001010100515151502221010051515150222101005151515051515150515151505151515051515150222101005151515022211110
30103030131030101030101010101010151515101020101015151510102010101515151015151510151515101515151015151510102010101515151020211110
31013130030131000131010001010100515151500121010051515150012101005151515051515150515151505151515051515150012101005151515022211100
30103030131030101030101010101010151515101010101015151510101010101515151015151510151515101515151015151510101010101515151011111010
33003030333033300330000000000000555555500000000055555550000000005555555055555550555555505555555055555550000000005555555010100101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000010
33003300333030000330000000000000000000002020000000000000202000002020000020200000202000002020000000000000202000000000000021000010
30103030131030101030101010101010151515102020101015151510202010102020101020201010202010102020101015151510202010101515151020101111
31013130030131000131010001010100515151502221010051515150222101002221010022210100222101002221010051515150222101005151515022211110
30103030131030101030101010101010151515101020101015151510102010101020101010201010102010101020101015151510102010101515151020211110
33013130333133300331010001010100515151500121010051515150012101000121010001210100012101000121010051515150012101005151515022211100
10101010101010101010101010101010151515101010101015151510101010101010101010101010101010101010101015151510101010101515151011111010
00000000000000000000000000000000555555500000000055555550000000000000000000000000000000000000000055555550000000005555555010100101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000010
00000000000000000000000000000000000000002020000000000000000000000000000000000000000000002020000020200000202000000000000021000010
10101010101010101010101010101010151515102020101015151510151515101515151015151510151515102020101020201010202919101515151020101111
01010100010101000101010001010100515151502221010051515150515151505151515051515150515151502221010022210100222191005151515022211110
10101010101010101010101010101010151515101020101015151510151515101515151015151510151515101020101010201010192818101515151020211110
01010100010101000101010001010100515151500121010051515150515151505151515051515150515151500121010001210100012191905151515022211100
10101010101010101010101010101010151515101010101015151510151515101515151015151510151515101010101010101010191919101515151011111010
00000000000000000000000000000000555555500000000055555550555555505555555055555550555555500000000000000000099999905555555010100101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999000000000001000010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000010
10101010101010101010101010101010151515101010101015151510151515101515151015151510151515101515151015151510151919101515151020101111
01010100010101000101010001010100515151500101010051515150515151505151515051515150515151505151515051515150519191505151515022211110
10101010101010101010101010101010151515101010101015151510151515101515151015151510151515101515151015151510191818101515151020211110
01010100010101000101010001010100515151500101010051515150515151505151515051515150515151505151515051515150519191905151515022211100
10101010101010101010101010101010151515101010101015151510151515101515151015151510151515101515151015151510191919101515151011111010
00000000000000000000000000000000555555500000000055555550555555505555555055555550555555505555555055555550599999905555555010100101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999000000000001000010
00000000000000000000000000000000000000002200222022002220220022202200222022002220220022202200222022002220220022200000000021000010
10101010101010101010101010101010151515101210202012102020121020201210202012102020121020201210202012102020121020201515151020101111
01010100010101000101010001010100515151500201212002012120020121200201212002012120020121200201212002012120020121205151515022211110
10101010101010101010101010101010151515101215202012152020121520201215202012152020121520201215202012152020121520201515151020211110
01010100010101000101010001010100515151502221222022212220222122202221222022212220222122202221222022212220222122205151515022211100
10101010101010101010101010101010151515101010101010101010101010101010101010101010101010101010101010101010101010101515151011111010
00000000000000000000000000000000555555500000000500000005000000050000000500000005000000050000000500000005000000055555555010100101
00000000000000000000000000000000000000000000005000000050000000500000005000000050000000500000005000000050000000500000000001000010
00000000000000000000000000000000000000002200222022002220220022202200222022002220220022202200222022002220220022200000000021000010
10101010101010101010101010101010151515101210202012102020121020201210202012102020121020201210202012102020121020201515151020101111
01010100010101000101010001010100515151500201212002012120020121200201212002012120020121200201212002012120020121205151515022211110
10101010101010101010101010101010151515101215202012152020121520201215202012152020121520201215202012152020121520201515151020211110
01010100010101000101010001010100515151502221222022212220222122202221222022212220222122202221222022212220222122205151515022211100
10101010101010101010101010101010151515101010101010101010101010101010101010101010101010101010101010101010101010101515151011111010
00000000000000000000000000000000555555500000000500000005000000050000000500000005000000050000000500000005000000055555555010100101
00000000000000000000000000000000000000000000005000000050000000500000005000000050000000500000005000000050000000500000000001000010
00000000000000000000000000000000000000002200222022002220220022202200222022002220220022202200222022002220220022200000000021000010
10101010101010101010101010101010151515101210202012102020121020201210202012102020121020201210202012102020121020201515151020101111
01010100010101000101010001010100515151500201212002012120020121200201212002012120020121200201212002012120020121205151515022211110
10101010101010101010101010101010151515101215202012152020121520201215202012152020121520201215202012152020121520201515151020211110
01010100010101000101010001010100515151502221222022212220222122202221222022212220222122202221222022212220222122205151515022211100
10101010101010101010101010101010151515101010101010101010101010101010101010101010101010101010101010101010101010101515151011111010
00000000000000000000000000000000555555500000000500000005000000050000000500000005000000050000000500000005000000055555555010100101
00000000000000000000000000000000000000000000005000000050000000500000005000000050000000500000005000000050000000500000000001000010

__gff__
0005000000000000000700030003000300000000000008000000000300030000000101010000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0102030505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020505010b0b0b0b0b0b01010505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0305050105140505050b0f010505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050105130b0b0b130d010101010105050505010101010101010105050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050114140101010313130113030101090101010505050505050105050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050113140505011414031314140905050505010505050505050105050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505011314130b010d0f0d0113030105050505090505050505050105050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005050101010d01010101010101140105050505010901010101010105050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005050505010d0f0d0d0f0d1313130105050501010505050501050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050505010d0f0d0d0d0d050d0f0105050501010101010501050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050505010f0f0f05050505050f0101010101010101010501050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050505010d050505050505050f0905050509050505050501050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010f0f05050505050f0d0101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010d0d0f0d0f0d0d0d0f0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
a20100000a0410a041030210302104001040010400104001030010300100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
0001000000000030500305000050030500305003050050500a0500e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0010000001001b15013150131501315013150111500c1500a1500865008650086500465006650056500465001630006300163000620006200161001610016100261002610016100161000600006000060000100
d001000013650136501c750217501d7501b7500b6500b650006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
010500001063010120101200a5500a5300c6200c6100c6000c6001060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001275016750187501c7501f750167501675016750187501b7501d7501f750227502775027750297502b75030750307502370023700297002a7002b7002c7002d7002d7000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c543005030050300503246250050000503005030c543005030050300503246250050300503005030c543005030050300503246250050300503005030c54300503005030050324625005030050300503
011000001174511715117451121511244112151174511715117451121511245114151174111715117451141511445114151174511715117451122511445117151174511215112451141511744117151144511715
a31000000c672006020060200602106720060200602006020c672006020060200602106720060200602006020c672006020060200602106720060200602006020c67200602006020060210672006020060200602
091000000c73710737137370c73710737137370c73711737187370c737187370c137187370c737187370c737117371d737117371d737117371d73711737187371b7371b7371b7371b7371b7371b7371b7371b737
__music__
03 10115253

