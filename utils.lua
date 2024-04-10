-- utils

-- types
function p(x,y)
	return {x=x,y=y}
end

function  clone_p(po)
	return p(po.x,po.y)
end

function vec_right(x,y)
 return y*-1,x	
end

-- functions
function dist(a,b)
 local abx,aby = a.x-b.x, a.y-b.y
 return sqrt(abx*abx+aby*aby)
end

function is_player(ent)
 return ent.id == _pid
end

-- projections
function lerp(a,b,d)
	if(d >= 1.0) return b
 return a+(b-a)*d
end

function add_t(po,d)
 return p(po.x+d.x,po.y+d.y)
end

-- take two points and returns their sum as tuple
function add_pt(p1,p2)
	return p1.x+p2.x, p1.y + p2.y
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

-- tokens: big gain here
function pline(x1,y1,x2,y2)
 local dx,dy,signx,signy,px,py = abs(x2-x1), abs(y2 - y1),1,1,x1,y1
 local derr = dx*0.5
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
 local l,vi_ent = pline(a.x,a.y,b.x,b.y), get_vis_ents()
 
 for _p in all(l) do
  if chk_tile(_p,_flos_no)
  or vi_ent[ptoi(_p)] then
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

function flood_fill(po,ocp,maxd,chk)
	chk = chk and chk or chk_solid
 local dpth,queue,visited = 0,{},{}
 visited[ptoi(po)], nxt = true, {}
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
		  if chk(np) == false
					  and not ocp[pi]
					  and not visited[pi]
		  then
		   visited[pi] = true
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
 
 return found
end

function csv_to_arr(str, notnum)
	local num = ""
	local arr = {}
	for c in all(str) do
		local cpy = num
		num = c == "," and "" or num .. c
		if c == "," then
			add(arr,notnum and cpy or tonum(cpy))
		end
	end
	add(arr,notnum and num or tonum(num)) -- add last
	return arr
end

function csv_to_val(str)
	return unpack(csv_to_arr(str))
end