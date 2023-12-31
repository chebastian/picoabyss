pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--rouge
function _init()
 _st_upd = {}
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
	start()
end

function _draw()
	cls()
 _drw()
 drw_win()
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
--game
function start()
	_t⧗ = 0
 _pid = 1
 _updt = 0 -- a global 1s timer which can be used to update idle anim
	_hp = {10,1,5}
	_atk = {1,1,1}
	_anims = {240,210,194}
 _upds = {noop,noop,wobble_upd}
	_txts = {} -- floating text
	_ents = {} -- all entities, inc player
 _itms = {} -- all pickups etc
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
 add_itm(88,p(13,4))
 add_itm(88,p(5,3))
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
	 add_win(0,0,40,10,{"heuooo"})
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
--utils

--globals
-- types
function p(x,y)
	return {x=x,y=y}
end


-- functions
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


-- drawing
function drw_ent(ent,at)
	palt(0,false)
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

function is_player(ent)
 return ent.id == _pid
end
-->8
--ui

function add_win(x,y,w,h,txt)
 local win = {x=x,y=y,w=w,h=h,txt=txt} 
 add(_wnd,win)
 push_upd(upd_win)
 return win
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
 
	 clip(w.x,wy,w.w-2,wh-2)
	 for i=1,#w.txt do
	  local txt=w.txt[i]
	  print(txt,
	  w.x+2
	  ,wy+2+(i-1)*6
	  ,6)
  end
  clip()
 end
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
--ent

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
 
 sfx(sfx_wlk)
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
   if(flr(rnd(10)) > 8)then
    add_itm(88,p(at.x,at.y))
   end
  end

  if tile == 11 and is_player(ent) then
   show_msg("the chest is empty")
  else
   bump_at(ent,d)
  end
  
  sfx(_tile_sfx[tile])
end

-- ★ move code?
function bump_at(ent,d)
 ent.pos_lst.x,
 ent.pos_lst.y=ent.pos.x+d.x*1.5
     ,ent.pos.y+d.y*1.5
end
-->8
--items

function add_itm(id,po)
 local ent = ent(id,po)
 ent.anim = anim({88},1,1)
 ent.upd = noop
 ent.upd_ren = wobble_upd
 ent.ease = ease_sin
 ent.itm = true
 ent.on_ent = on_pickup
 add(_ents,ent)
end

function on_pickup(itm,ent,po,d)
 bump_at(ent,d)
 ent.hp+=1
 del(_ents,itm)
 add_hp(ent,1)
 sfx(5)
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
__gfx__
00000000666066600000000000000000000000000000000000000000000000000055550000888800000000000000000000000000000000000000000000000000
00000000000000600000000000000000000000000000000000000000000000000550055008800880000000000000000000000000000000000000000000000000
00700700606660600000000000000000000000000000000000000000000000005500005588000088000000000888888000000000088888800000000000000000
000770000000000000000000000b0000000000000000000000000000000000005000000580088008055555508888888800000000008888000000000008888880
00077000666060600000000000b0b000000000000000000000000000000000005000000580888808550000558880088805550550088088800550000008888808
007007000000000000000000000000000000b0000000000000000000000000005000000580088808500000050000000055000055880888885550000508888088
0000000066660660000000000000000b000b0b000000000000000000000000005000000580888808555005558880088800055050088088800000500000880880
000000000000000000000000000000b0000b00000000000000000000000000000000000000000000555555558888888800055000000880000005500000088800
00000000055055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000505505500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888800000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeee000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088088800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000880888880000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088088800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000880000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090000000000000000000099999000999990000000000000000000009000000000000000000000000000000000000000000000000000000000000
00000000000990009999999000000000090009000900090009909900099099000099900000000000000000000000000000000000000000000000000000000000
00000000000990000999990000900000009090000090900000909000009090000009000000000000000000000000000000000000000000000000000000000000
09999000000990000999990009990000090009000900090009909900099099000099900000000000000000000000000000000000000000000000000000000000
0999999000099000099999000999900009999900090009000988890009bbb9000999990000000000000000000000000000000000000000000000000000000000
0999909009999990009990000999990009999900099999000988890009bbb9000999990000000000000000000000000000000000000000000000000000000000
0999999000000000000900000999900009999900099999000988890009bbb9000999990000000000000000000000000000000000000000000000000000000000
00999000000990000000000000000000099999000999990009999900099999000099900000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000090009000009000009999900000000000000000000000000000000000000000000000000
00000000000000a00000009000090000000000000000000090000090009090000099900000090000000000000000000000000000000000000000000000000000
000000000000aa000000990000009000000000000000000009000900009090000009000000989000000000000000000000000000000000000000000000000000
00000000000aa000000990000090090000000000000000009000009000909000009b900000989000000000000000000000000000000000000000000000000000
0000000090aa000090990000099900900000000000000000999999900900090009bbb90009888900000000000000000000000000000000000000000000000000
0000000009a0000009900000099990000000000000000000999999900999990009bbb90098888890000000000000000000000000000000000000000000000000
000000000090000000900000099900000000000000000000099999000999990009bbb90009888900000000000000000000000000000000000000000000000000
00000000900900009009000000000000000000000000000000999000009990000099900000999000000000000000000000000000000000000000000000000000
00000000000000000000000900000000000000d60000000000000099000000990000000000000000000000000000000000000000000000000000000000000000
0000000000000000000009900000000000000d6d000000d600000999000009990000099000000000000000000000000000000000000000000000000000000000
000000000000000000009900000009900000d6d000000d6000009990000090900000999000009900000000000000000000000000000000000000000000000000
00000000000000000909900009009900090d6d000900d60009099900090909000909090009090900000000000000000000000000000000000000000000000000
000000000000000000990000009990000099d0000099600000999000009090000990900009909000000000000000000000000000000000000000000000000000
00000000000000000009000000090000000900000009000000090000000900000099000000090000000000000000000000000000000000000000000000000000
00000000000000000900900009009000090090000900900009009000090090000909900009099000000000000000000000000000000000000000000000000000
00000000000000009000000090000000900000009000000090000000900000009000000090000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000990000009900000090000000000000000000000000000000000000000000000000000000000
00000000000000000000900000000000000000000000000000009990000090900000990000000000000000000000000000000000000000000000000000000000
00000000000000000009900000000000000000000000000009090900090909000909090000000000000000000000000000000000000000000000000000000000
00000000000000009099000000000000000000000000000009909000009090000990900000000000000000000000000000000000000000000000000000000000
00000000000000000990000000000000000000000000000000990000000900000099000000000000000000000000000000000000000000000000000000000000
00000000000000000009000000000000000000000000000009099000090090000909900000000000000000000000000000000000000000000000000000000000
00000000000000009000000000000000000000000000000090000000900000009000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056666650
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056666665
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056666665
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056666650
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006660606
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000660060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060666600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060666600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009890000098900000989000009890000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009009900900099000900990090009900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009909009909090090990900990909009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000999990099999999099999009999999900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009099909099999990909990909999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000090900000909000009090000090900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000900090009000900090009000900090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099990000000000009999000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000999999000999900099999900998989000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009998989909999990999898990999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999989899999999990999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999999999990999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000999999099999999099999900099990000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000999909000999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099990009999090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000900999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000999999009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000909900009099009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099090000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000090099000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000099990000000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999090009999000999909000999900006660000000000000606000060006000600060000000000000000000000000000000000000000000000000000000000
00999900099990900099990009999090006660000660000006606600000000000000000000000000000000000000000000000000000000000000000000000000
00000050009999500000005000999950000000000000000000000000000600000600060000000000000000000000000000000000000000000000000000000000
09999956099009560999995609900956000000000006600006606600000000000000000000000000000000000000000000000000000000000000000000000000
09099050009090500909905000909050066600000000000000606000060006000600060000000000000000000000000000000000000000000000000000000000
00990900000900000099090000090000066600000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900990000990000090099000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000303030003000300000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000011111111111110f010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000102020b0101000d010101010100000000010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101090101010202020102020101010101010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000111001100010000000900020100000000010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000010000020b010d0f0d0100000100000000090000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000101010d01010101010101090100000000010901010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001111010d0f0d0d0f0d1111000100000001010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

