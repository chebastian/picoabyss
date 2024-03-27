-- ui

-- set w to 0 for auto width
function add_win(x,y,w,h,txt)
   local mw = 0
   for choice in all(txt) do
      mw = max(#choice, mw)
   end
   local ww = w == 0 and (mw+1) * 4 or w
 local win = {x=x,y=y,w=ww,h=h,txt=txt} 
 win.upd = win_noop
 add(_wnd,win)
 push_upd(upd_win)
 return win
end

function win_noop(win)
end

function add_menu(choices, upd, on_sel)
   local win = add_win(30,30,0,10*#choices,choices)
   win.upd = upd
   win.on_sel = on_sel
   win.sel = 1
   return win
end

function add_menu_win()
   add_menu({"equip", "items", "close"}, upd_inv,on_menu_sel)
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
 local win = add_menu(str,upd_inv, sel_cbk)
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

function add_air(ent,mp)
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