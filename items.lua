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
 ent.can_pickup = true
 ent.outline = true
 ent.on_ent = on_pickup
 ent.on_use = _lo_itms[id].on_use --on_use_potion
 add(_ents,ent)
end

function on_pickup(itm,ent,po,d)
 bump_at(ent,d)
 del(_ents,itm)
 
 local hk = _plyr.has_key
 local itid = itm.id
 _plyr.has_key = hk and hk or itid == _lvlkey

 if itid >= 0 and itid < 0x10 or itid == _lvlkey then
	 add(_bpack,itm)
 elseif itid >= 0x10 and itid < 0x20 then
  add(_eqp,itm)
 end
 p_sfx(5,ent)
end

function on_use_potion()
 _plyr.hp+=1
 add_hp(_plyr,1)
 p_sfx(5,_plyr)
end

function on_use_air()
 add_air(_plyr,25)
 p_sfx(5,_plyr)
 _plyr.air += 25
end

function on_use_key()
	show_msg("return it to surface")
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
 local eqp,itm = _eqp[idx]
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

 if item.id == _lvlkey then -- dont remove the key
	return
 end

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
 	drx,dry,
	dlx,dly,
	0,0,
	dux,duy
 }
 
 local res = {}
 for i=1,#lr-1,2 do
 	add(res,p(ent.pos.x+ent.dx+lr[i], ent.pos.y+ent.dy+lr[i+1]))
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