pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- rouge
function _init()
 _st_upd = {}
 _dbg = {}
	_wnd = {}
	_upd = upd_game
	_drw = drw_game
	push_upd(upd_game)
	_⬅️ = p(-1,0)
	_⬆️ = p(0,-1)
	_⬇️ = p(0,1)
	_➡️ = p(1,0)
	buttons = {⬅️,➡️,⬆️,⬇️}
	dirs = {_⬅️,_➡️,_⬆️,_⬇️}
	dir8 = {p(-1,0),p(-1,1),p(-1,-1),
	        p(0,1),p(0,-1),
	        p(1,0), p(1,1), p(1,-1)}
	sfx_wkl=0
	sfx_bmp=1
	sfx_lmp=2
	sfx_door=3
	initmap()
	start()
end

function dbg(str)
 add(_dbg,str)
end

function initmap()
 for y=1,64 do
  for x=1,65 do
   if mget(x,y) == 1 then
    local tbx,tby=x,y+1
    if mget(tbx,tby) == 0 then
     mset(tbx,tby,17)
    end
   end
  end
 end
end

function _draw()
	cls()
 _drw()
 drw_win()
 
 cursor(100,20)
 for s in all(_dbg) do
  print(s)
 end
 
 _dbg ={}
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
	_hp = {10,1,5}
	_atk = {1,1,1}
	_anims = {240,210,194}
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
		[16] = crt_eqp("swd",2,on_equip),
		[17] = crt_eqp("grt swd",3,on_equip),
		[18] = crt_eqp("slv swd",4,on_equip),
	}
								 
	_plyr = add_mob(1,p(4,3))
	_plyr.upd = upd_plyr
	_pl = anim_pl(4)
	_plyr.ease = ease_lerp
	
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
 add_itm(1,p(13,4))
 add_itm(0,p(5,3))
 -- </test>
end

function chk_tile(p,flag)
 local tile = mget(p.x,p.y)
 return fget(tile,flag),tile
end

function ent_at(p)
 for ent in all(_ents) do
  if ent.pos.x == p.x
  and ent.pos.y == p.y then
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
	
	if(btnp(❎))then
--	 add_inv_win(_bpack)
  add_menu_win()
	end
	
	local has_player_input = _d
  
	if has_player_input then
	 _t⧗ = 0
	
	 for e in all(_ents) do
   e:upd()
	 end
	 
  push_upd(upd_ease)

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
 _t⧗=min(_t⧗+0.1,1)
 if(_t⧗ == 1) then
  pop_upd()
  foreach(_ents,set_lst_pos)
  return
 end
 
 for e in all (_ents) do
  e.pos_ren.x,
  e.pos_ren.y = e.ease(e)
 end
 
 _cam.pos_ren.x,
 _cam.pos_ren.y = ease_lerp(_cam)
end

-->8
-- drawing

function drw_ent(ent,at)
	palt(0,false)
	palt(14,true)
	local flash=ent.flash
	if(flash and flash > 0) then
	 pal(9,7)
	 ent.flash -= 1
	end
	spr(ent.sprid,
				 at.x*8,
				 at.y*8,
				 1,1,ent.hflip)
	pal()
	palt(0,false)
	palt(14,true)

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
  local tx = pos.x
  local ty = pos.y
  print(txt,tx+di.x
     ,di.y+ty,bg)
 end
 
 print(txt,pos.x
      ,pos.y,fg)   
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
	
	 drw_box(w.x,wy,
	 w.w,wh,
	 6,0)
 
	 clip(w.x-8,wy-8,w.w+6,wh+6)
	 for i=1,#w.txt do
	  local txt=w.txt[i]
 
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

function drw_game()
	camera((_cam.pos_ren.x-8)*8.0,
	(_cam.pos_ren.y-6)*8)
	map()
	_pl.frame_cnt+=1
 _updt = min(_updt+1/60,1)

 for e in all(_ents) do
  e:upd_ren()
  e.sprid = upd_anim(_pl,e.anim)
	 drw_ent(e,e.pos_ren)
 end
 
 drw_dmg()
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

-->8
-- ent

function ent(id,po)
	return {id=id,
							  sprid=_anims[id],
							  pos=po,
							  hflip=false,
							  upd_ren=noop,
							  ease=ease_lerp,
							  on_ent=on_dmg,
							  pos_ren=p(po.x,po.y),
							  pos_lst=p(po.x,po.y)
							 }
end

function add_mob(id,p)
 local e = ent(id,p)
 local frames = {}
 local anim_id = _anims[id]
 for i=0,3 do
  add(frames,anim_id+i)
 end
 
 e.anim = anim(frames,3,1)
 e.hp = _hp[id]
 e.atk = _atk[id]
 e.upd = rand_wlk
 e.upd_ren = noop
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

function move_ent(ent,d)
	ent.hflip = d.x < 0 or (ent.hflip and d.x == 0)
 local np = add_t(ent.pos,d) 
 local sld,tile = chk_tile(np,0)
 local ent2 = ent_at(np)
 if(sld)then
  ent.ease=ease_bump
  on_bump(tile,np,ent,d)
  return
 elseif(ent2)then
  ent.ease=ease_bump
  ent2:on_ent(ent,np,d)
  return
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
 if(ent.hp <= 0) then
	 del(_ents,ent)
 end
 
 sfx(4)
end

function on_atk(atk,ent,at,d)
 bump_at(atk,d)
 
 ent.hp-=atk.atk
 ent.flash=10
 add_atk(atk,ent)
 if(ent.hp <= 0) then
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
   if(flr(rnd(10)) > 1)then
    local itm = flr(rnd(4))
    add_itm(17,p(at.x,at.y))
   end
  end

  if tile == 11 and is_player(ent) then
   show_msg("the chest is empty")
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
  add_inv_win(_eqp,on_eqp_sel)
 elseif idx == 2 then
  add_inv_win(_bpack,on_inv_sel)
 end
end

function add_inv_win(inv,sel_cbk)
 local str = {}
 for i in all(inv) do
  add(str,"".._lo_itms[i.id].name)
 end
 local win = add_win(8,11,40,10*#inv,str) 
 win.upd = upd_inv
 win.on_sel = sel_cbk
 win.sel = 1
 win.t = nil
end

function on_eqp_sel(idx)
	eqp_item(idx,_plyr)
end

function on_inv_sel(idx)
 use_item(idx,_plyr)
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
  if(w.t == nil) then 
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

function crt_eqp(name,atkp,onuse)
 local itm = crt_itm(name,onuse)
 itm.atkp = atkp
 return itm
end

function add_itm(id,po)
 local ent = ent(id,po)
 ent.anim = anim({64+(id)},1,1)
 ent.upd = noop
 ent.upd_ren = wobble_upd
 ent.itm = true
 ent.on_ent = on_pickup
 ent.on_use = _lo_itms[id].on_use --on_use_potion
 add(_ents,ent)
end

function on_pickup(itm,ent,po,d)
 bump_at(ent,d)
 del(_ents,itm)
 
 if(itm.id >= 0 and itm.id < 0x10) then
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
 local eqp = _eqp[idx]
 ent.atk = _lo_itms[eqp.id].atkp
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
-->8
-- utils

-- types
function p(x,y)
	return {x=x,y=y}
end


-- functions
function is_player(ent)
 return ent.id == _pid
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
 if(pl.frame_cnt >= 60/pl.fps) then
  pl.frame_i+=1
  pl.frame_cnt=0
 end
 
 return anim.f[pl.frame_i%#anim.f+1]
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000055550000888800000000000000000000000000000000000000000000000000
00000000555555500000000000000000000000000000000000000000000000000550055008800880000000000000000000000000000000000000000000000000
00700700555555500000000000000000000000000000000000000000000000005500005588000088000000000888888000000000088888800000000000000000
000770005555555000000000000b0000000000000000000000000000000000005000000580088008055555508888888800000000008888000000000008888880
00077000555555500000000000b0b000000000000000000000000000000000005000000580888808550000558880088805550550088088800550000008888808
007007005555555000000000000000000000b0000000000000000000000000005000000580088808500000050000000055000055880888885550000508888088
0000000055555550000000000000000b000b0b000000000000000000000000005000000580888808555005558880088800055050088088800000500000880880
000000000000000000000000000000b0000b00000000000000000000000000000000000000000000555555558888888800055000000880000005500000088800
00000000550055050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000505505500000000000000000000000000000000000000000000000000000000000000000000888800000000000000000088888800000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000008800000888880000000000000000000eeee000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000088000088888800000000000000000088088800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000008888000088888800000000000000000880888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000008888000080008800000000000000000088088800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000008008000080008000000000000000000000880000000000000000000
00000000000000006660666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555500000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555506066606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555506660606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555506666066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee9eeeeeee9eeeeeee9eeeeeee9eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee909eeeee909eeeee909eeeee909ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e990009ee990009ee990009ee990009e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9bbbb9ee9cccc9ee988889ee9aaaa9ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9bbb9eee9ccc9eee98889eee9aaa9eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e9bb9eeee9cc9eeee9889eeee9aa9eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee99eeeeee99eeeeee99eeeeee99eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000009900000999000000090000909900009099000990990000000000000090000000900000009000090000900009990000000000000000
00000990000009900000099900009999000009000000090900009909009099090000090000000990000009900000009000999000090990090000000000000000
00009990000099900000999009099999000009900000099000090990000009900000990000009990000099900000099009999900009000900000000000000000
00099900090999000909990009999990000090000000900900009099000090990909090000090900090999000900999000990990090900900000000000000000
09009000099990000099900000999900000900000009000000090900000900090990900009909000009990000099990000099999090099000000000000000000
00900000009900000009000000099000009000000090000000900000009000900099000000990000000900000009000000909990900090090000000000000000
09090000090990000900900009009900090000000900000009000000090000000909900009090000090090000900900009000900909900900000000000000000
00000000900000009000000090000000900000009000000090000000900000009000000090000000900000009000000090000000990009090000000000000000
00000000000900000099000000009000000999090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000000990000009900000099990009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009000000099000900990000999990099009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900900009009909990099009009999090090990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09990090099900999999009900000990900900990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000099990009999900900000900000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09990000099900009999990000009000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999900000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000a0000000900009000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000aa00000099000000900000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000aa000000990000090090000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000090aa0000909900000999009000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000009a00000099000000999900000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000900000009000000999000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000090090000900900000000000000000000000000000000000000000000
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
00000000000000000009890000098900000989000009890000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009900900099000900990090009900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009909009909090090990900990909009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000e99999ee99999999e99999ee9999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009e999e9e9999999e9e999e9e9999999e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ee9e9eeeee9e9eeeee9e9eeeee9e9eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000e9eee9eee9eee9eee9eee9eee9eee9ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ee9999eeeeeeeeeeee9999eeee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000e999999eee9999eee999999ee998989e00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000099989899e999999e99989899e999999e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000999999999998989999999999e999999e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000999999999999999999999999e999999e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000e999999e99999999e999999eee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099990000000000000000000000000000000000009990000009990000099900000999000000000000000000000000000000000000000000
00000000000000000999909000999900000000000000000000000000009990000009990000099900000999000009900000000000000000000000000000000000
00000000000000000099990009999090000000000000000000000000000900000009900000099000000990000009900000000000000000000000000000000000
00000000000000000000000900999900000000000000000000000000098889000051110000058800005888000098800000000000000000000000000000000000
00000000000000000999999009000000000000000000000000000000098889000511116000658800058888600098890000000000000000000000000000000000
00000000000000000909900009099009000000000000000000000000095559000522226000045400054444600009590000000000000000000000000000000000
00000000000000000099090000090000000000000000000000000000005050000022020000440660004044000066500000000000000000000000000000000000
00000000000000000090099000099000000000000000000000000000005050000050066000500000006605500000500000000000000000000000000000000000
ee9999eeeeeeeeeeee9999eeeeeeeeee006660000000000000000000000000000000000000000000000000000009900000000000000000000000000000000000
e999909eee9999eee999909eee9999ee006660000000000000606000060006000600060000000000000000000009900000000000000000000000000000000000
ee9999eee999909eee9999eee999909e006660000660000006606600000000000000000000000000000000000009000000000000000000000000000000000000
eeeeee5eee99995eee00005eee99995e000000000000000000000000000600000600060000000000000000000098800000000000000000000000000000000000
e9999956e9900956e9999956e9900956000000000006600006606600000000000000000000000000000000000098890000000000000000000000000000000000
e909905eee909e5ee909905eee909e5e066600000000000000606000060006000600060000000000000000000009690000000000000000000000000000000000
ee9909eeeee9eeeeee99e9eeeee9eeee066600000000066000000000000000000000000000000000000000000066600000000000000000000000000000000000
ee90099eeee99eeeee9ee99eeee99eee000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000
__gff__
0001000000000000000300030003000300000000000000000000000000030000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001000d000000000f010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000102020b0101000d010101010100000000010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000010109010101020d000100000101010101010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000010000000001000d000900020100000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000010000020b010d0f0d0100000100000000090000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101010d01010101010101090100000000010901010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010d0f0d0d0f0d0000000100000001010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010d0f0d0d0d0d0f0d0f0100000001000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010f0f0f00000000000f0101010101000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010d000202020202020f0900000009000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010f0f02020202020f0d0101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

