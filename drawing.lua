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
	 pal(5,1)
   pal(6,9) -- mine flash
	 ent.flash -= 1
	end
	if ent.outline then
		drw_spr_8(ent,at,0)
		ini_pal()
	end
	spr(ent.sprid,
				 (at.x*8)-4,
				 (at.y*8)-4,
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
					 (at.x*8+tx)-4,
					 (at.y*8+ty)-4,
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

  if e.anim then
    e.sprid = upd_anim(_pl,e.anim)
  end

	 if _vis_lookup[ptoi(e.pos)] then 
	 	drw_ent(e,e.pos_ren)
	 end
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
 
 blackout()
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
	_los[ptoi(_plyr.pos)] = true
 for dir in all(dirs) do
 	_los[ptoix(_plyr.pos.x+dir.x,
 								_plyr.pos.y+dir.y)] = true
 end

	local losents = get_vis_ents()
	for wt in all(_vis) do
	 local x = wt.po.x
	 local y = wt.po.y
	 if not line_of_sight(_plyr.pos,p(x,y)) then
  else
   _los[ptoix(x,y)]=true
  	for d in all(dir8) do
    local np = p(x+d.x,y+d.y)
    
    --
    -- show walls and doors
    -- and any entities flagged
    --
    if chk_tile(np,_flos_no)
	   or losents[ptoi(np)] then
	    _los[ptoi(np)] = dist(np,_plyr.pos) <= _plyr.srchd
    end
  	end
  end
	end
end

function blackout()
	if noblackout then
	 return
 end
 
 local mw = 17
 local mh = 17
 
 local cp = _cam.pos
 local cpx,cpy = cp.x-9,cp.y-7

  map2d(cpx,cpy,mw,mh,
  function(x,y)
	  local idx = ptoix(x,y)
	  if not _los[idx] then
--   	print("▒",x*8,y*8+1,1)
      drw_rectf((x*8)-4,(y*8)-4,8,8,0)
	  end
  end)
end

-- 7520
function map2d(sx,sy,lenx,leny,fun)
  for x=sx,sx+lenx,1 do
    for y=sy,sy+leny,1 do
      fun(x,y)
    end
  end
end