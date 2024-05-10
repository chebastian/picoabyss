-- ent

-- flags


function ent(id, po)
  return {
    id = id,
    sprid = _anims[id],
    pos = po,
    hflip = false,
    upd_ren = noop,
    ease = ease_lerp,
    on_ent = on_dmg,
    pos_ren = clone_p(po),
    pos_lst = clone_p(po),
    dx = 0,
    dy = 0,
    can_dmg = false,
    can_pickup = false,
    can_walk = false
  }
end

function add_mob(id, p)
  local e, frames, anim_id
  = ent(id, p), {}, _anims[id]

  gen_frames(anim_id, 3, frames)

  e.anim = anim(frames, 3, 1)
  e.hp = _hp[id]
  e.atk = _atk[id]
  e.upd = _mobupd[id]
  e.upd_ren = noop
  e.can_dmg = true
  add_ent(e)
  return e
end


function add_trap(id, p, cbk)
  printh("upd: " .. tostr(_trapupd[id]) .. "at: " .. id)
  cbk = cbk and cbk or on_trap_atk
  local mob = add_mob(id, p)
  mob.upd = _trapupd[id]
  mob.life = _traplife[id]
  mob.can_walk = true
  mob.on_trap = cbk
  _traps[ptoi(p)] = mob
  return mob
end

function add_fmob(id, p, canwalk)
  local e, frames, anim_id
  = ent(id, p), {}, _anims[id]

  e.sprid = _anims[id]
  e.hp = id == _lvlkey and 50 or 1
  e.atk = 0
  e.upd = noop
  e.upd_ren = noop
  e.can_dmg = true  -- meaning can we bump into this thing and hit it
  e.can_walk = canwalk -- when false entities will not walk over this in pathfinding
  e.is_fmob = true

  e.on_ent = on_open
  add_ent(e)
  return e
end

function trap_noop(e)
end

function upd_smok(e)
  if e.life <= 0 then
    del(_ents, e)
    --		updatefow()
  else
    e.life -= 1
    if e.life <= 1 then
      e.flash = 10
    end
  end
end

function on_open(ent, atk, np, d)
  bump_at(atk, d)
  if fget(ent.sprid, _fchest) and is_player(atk) then
    local itm_lookup = ent.has_item and _lo_chst or _lo_clam
    itm_idx = arr_choose(itm_lookup)

    if _keyp.x == ent.pos.x and _keyp.y == ent.pos.y then
      add_itm(_lvlkey,clone_p(ent.pos))
    elseif itm_idx >= 0 then
      add_itm(itm_idx, clone_p(ent.pos))
    end
  end
  ent.sprid += 1
  ent.can_dmg = false
  ent.can_walk = true
  sfx(4)
end

function on_anchor(ent, atk, np, d)
  if not is_player(atk) then
    return
  end

  local choices = _plyr.has_key and {"keep exploring", "go to next level"}
                   or {"keep looking", "return to surface"}
  add_menu(choices, upd_inv, function(idx)
    if idx == 2 then
      if _plyr.has_key then
        nextlevel()
      else
        restart()
      end
    end
  end)
end

function nextlevel()
  cls()
  local slp = 30
  while slp > 0 do
      flip()
      slp -= 1
  end

  _plyr.lvl += 1
  pop_upd()
  _wnd = {}
  push_upd(upd_nextlevel)
  push_upd(noop) -- 433 hack 
  _drw = drw_nextlevel

  _boat = 0
  _ents = {}
  fill_map(0)
	for i=0,18 do
		add_trap(13,p(i,10)) -- add waves to startscreen
	end

  _ship = add_trap(14,p(4,10));
end

function gen_frames(id, len, arr)
  for i = 0, len do
    add(arr, id + i)
  end
end

function add_ent(ent)
  add(_ents, ent)
end

function noop(e)
end

function kill_ent(ent)
 ent.upd = noop
 ent.death = 16
 ent.flash = 10
 ent.can_dmg = false
 if is_player(ent) then
  ent.death = 55
 end
end

function rand_wlk(e)
  if e.d == nil then
    e.d = next_d()
  end
  move_ent(e, e.d)
  e.d = nil
end

function ptoi(po)
  --★ arbitrary w, fix
  return po.x + po.y * 128
end

function ptoix(x, y)
  return x + y * 128
end

function arr_to_tbl(arr)
  local tbl = {}
  for ti in all(arr) do
    tbl[ptoi(ti.po)] = ti.dst
  end
  return tbl
end

function upd_sqid(ent)
  local doup = rnd()
  if doup > .3 then
    wlk_to_plyr(ent)
  else
    -- release squid
    for d in all(dirs) do
      local dx, dy = add_pt(ent.pos, d)
      if not chk_solid(p(dx, dy))
          and not sld_ent_at(p(dx, dy)) then
        add_trap(_mobsmok, p(dx,dy), trap_noop)
      end
    end
    add_trap(_mobsmok, clone_p(ent.pos), trap_noop)
  end
end

function walkable_dirs(po)
  local drs = {}
  for dir in all(dirs) do
    if not sld_ent_at(add_t(po,dir)) then
      add(drs,dir)
    end
  end

  return drs
end

function upd_snek(ent)
  -- if snek has no target
  if not ent.target then
    for dir in all(dirs) do
      local hit = false
      for i = 1, 10 do
        local pnx,pny= ent.pos.x + (dir.x * i),
          ent.pos.y + (dir.y * i)
        if hit or chk_solidx(pnx,pny) then
          hit = true
          break
        elseif _plyr.pos.x == pnx and
            _plyr.pos.y == pny then
          -- set target
          ent.target = _plyr.pos
          ent.targetd = dir
          break
        elseif sld_ent_at(p(pnx,pny)) then
          hit = true
        end
      end

      if ent.target then
        break -- stop looking
      end
    end
  end

  -- player not found
  -- do random walk
  if not ent.target then
    ent.d = arr_choose(walkable_dirs(ent.pos))
    if not ent.d then
      stop("could not find walkable dir")
    end

    move_ent(ent, ent.d)
    return
  end

  -- player fround
  -- move toward target
  local px, py = ent.pos.x, ent.pos.y
  ent.d = ent.targetd
  move_ent(ent, ent.targetd)

  -- target reached, clear
  if (ent.target.x == ent.pos.x
        and ent.target.y == ent.pos.y)
      or (ent.pos.x == px and ent.pos.y == py)
  then
    ent.target = nil
    ent.targetd = nil
  end
end

function upd_mine(ent)
  for dir in all(dir8) do
    -- set a magic number for when to start explode
    if (ent.hp < 5 and not ent.countdown) then
      ent.countdown = 2
    end
  end

  if ent.countdown then
    ent.countdown -= 1
    ent.flash = 10
  end

  if (ent.countdown and ent.countdown == 0) or ent.hp < 4 then
    del(_ents, ent)
    for dir in all(dir8) do
      local np = add_t(ent.pos,dir)
      local tr = add_trap(_mobexpl,np)
      tr.life = 1
      tr.can_dmg = false
    end
    sfx(6)
  end

end

function wlk_to_plyr(ent)
  local lookup = arr_to_tbl(_srch_tiles)
  local mini, mind, curpt, curd, ocp =
      -1, 999
      , ptoi(ent.pos)
      , lookup[curpt]
      , {}
  for e in all(_ents) do
    if not e.can_walk and is_player(e) == false then
      ocp[ptoi(e.pos)] = true
    end
  end

  if curd then
    mind = curd
  end
  for i = 1, #dirs do
    local nx = ent.pos.x + dirs[i].x
    local ny = ent.pos.y + dirs[i].y

    local ndist = 999
    local ptile = lookup[ptoix(nx, ny)]
    if ptile and ocp[ptoix(nx, ny)] == nil then
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

  -- ★ 666 dirs hack
  ent.d = dirs[mini]
  move_ent(ent, dirs[mini])
  ent.d = nil
end

function is_valid_move(ent, d)
  local np = add_t(ent.pos, d)
  local sld, tile = chk_tile(np, _fsolid)

  if sld then
    return false -- we hit a wall
  end
  
  return true
end

function move_ent(ent, d)
  ent.hflip = d.x < 0 or (ent.hflip and d.x == 0)
  ent.dx = ent.d.x
  ent.dy = ent.d.y
  local np = add_t(ent.pos, d)
  local sld, tile = chk_tile(np, _fsolid)

  if sld then
    ent.ease = ease_bump
    on_bump(tile, np, ent, d)
    return -- we hit a wall
  end

  -- step on item
  local stepent = step_ent_at(np)
  if stepent and stepent.on_wlk then
    stepent:on_wlk(ent,np,d)
    move_t(ent.pos, d)
    ent.ease = ease_lerp
    return
  end

  -- pickup item or interact with fmob
  local itm = sld_ent_at(np)
  if itm and itm.can_pickup then
    ent.ease = ease_bump
    itm:on_ent(ent, np, d)
    return -- we hit a item we can pickup
  elseif itm and itm.is_fmob then
    ent.ease = ease_bump
    itm:on_ent(ent, np, d) --★ 223
    return -- we hit a fmob (clam or door)
  end

  -- atk with weapon
  local atk_tiles = atk_ptrn(ent, ent.atkptr)
  for atk in all(atk_tiles) do
    local ent2 = sld_ent_at(atk)
    -- ★ atk self bugfix on use item
    if ent2 and ent2.can_dmg and not ent2.is_fmob and ent2 != ent then
      ent.ease = ease_bump
      ent2:on_ent(ent, np, d) --★ 223
      return -- we hit something with our weapon
    end
  end

  -- we didnt hit anything solid so move
  p_sfx(sfx_wlk, ent)
  move_t(ent.pos, d)
  ent.ease = ease_lerp
end

function on_dmg(ent, atk, at, d)
  bump_at(atk, d)
  ent.hp -= atk.atk
  ent.flash = 10
  add_atk(atk, ent)
  if ent.hp <= 0 then
    kill_ent(ent)
  end

  sfx(4)
end

function on_trap_atk(atk, ent)
  bump_at(atk, p(0, 0))

  ent.hp -= atk.atk
  ent.flash = 10
  add_atk(atk, ent)
  if ent.hp <= 0 then
    kill_ent(ent)
  end

  sfx(4)
end

function on_bump(tile, at, ent, d)
  if fget(tile, _frubble)
      and is_player(ent) then
    mset(at.x, at.y, tile - 1)
  end

  bump_at(ent, d)
  p_sfx(_tile_sfx[tile], ent)
end

-- ★ move code?
function bump_at(ent, d)
  ent.pos_lst.x,
  ent.pos_lst.y = ent.pos.x + d.x * 1.5
  , ent.pos.y + d.y * 1.5
end
