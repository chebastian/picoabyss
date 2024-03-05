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
    pos_ren = p(po.x, po.y),
    pos_lst = p(po.x, po.y),
    dx = 0,
    dy = 0,
    can_dmg = false,
    can_pickup = false,
    can_walk = false
  }
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

function add_trap(id, p, cbk)
  printh("upd: " .. tostr(_trapupd[id]) .. "at: " .. id)
  cbk = cbk and cbk or on_atk
  local mob = add_mob(id, p)
  mob.upd = _trapupd[id]
  mob.life = _traplife[id]
  mob.can_dmg = false
  mob.can_pickup = false
  mob.can_walk = true
  mob.on_trap = cbk
  _traps[ptoi(p)] = mob
  return mob
end

function add_fmob(id, p, canwalk)
  local e, frames, anim_id
  = ent(id, p), {}, _anims[id]

  e.sprid = _anims[id]
  e.hp = 1
  e.atk = 0
  e.upd = noop
  e.upd_ren = noop
  e.can_dmg = true  -- meaning can we bump into this thing and hit it
  e.can_walk = canwalk -- when false entities will not walk over this in pathfinding
  e.can_pickup = false -- can be picked up?
  e.is_fmob = true

  e.on_ent = on_open
  add_ent(e)
  return e
end

function on_open(ent, atk, np, d)
  bump_at(atk, d)
  if fget(ent.sprid, _fchest) and is_player(atk) then
    local lo_idx = flr(max(1, rnd(#_lo_chst)))
    local itm_idx = _lo_chst[lo_idx]
    if itm_idx >= 0 then
      add_itm(itm_idx, p(ent.pos.x, ent.pos.y))
    else
      show_msg("the chest is empty")
    end
  end
  ent.sprid += 1
  ent.can_dmg = false
  ent.can_walk = true
  sfx(4)
end

function gen_frames(id, len, arr)
  for i = 0, len do
    add(arr, id + i)
  end
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
  e.can_walk = false
  e.can_pickup = false
  add_ent(e)
  return e
end

function add_ent(ent)
  add(_ents, ent)
end

function noop(e)
end

function rand_wlk(e)
  if e.d == nil then
    e.d = next_d()
  end
  move_ent(e, e.d)
  e.d = nil
end

function wlk_in_d(enta)
  local mini, mind = 0, 999
  for i = 1, #dirs do
    local nx, ny, ndist = enta.pos.x + dirs[i].x
    , enta.pos.y + dirs[i].y
    , dist(p(nx, ny), entb.pos)
    if ndist < mind then
      mini = i
      mind = ndist
    end
  end

  enta.d = dirs[mini]
  move_ent(enta, dirs[mini])
  enta.d = nil
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
    _dbg[1] = #dirs
    for d in all(dirs) do
      local dx, dy = ent.pos.x + d.x, ent.pos.y + d.y
      if not chk_solid(p(dx, dy))
          and not sld_ent_at(p(dx, dy)) then
        add_trap(_mobsmok, p(ent.pos.x + d.x, ent.pos.y + d.y), trap_noop)
      end
    end
    add_trap(_mobsmok, p(ent.pos.x, ent.pos.y), trap_noop)

    --		_dbg[1] = "ents: " .. #_ents
  end
end

function upd_snek(ent)
  -- if snek has no target
  if not ent.target then
    for dir in all(dirs) do
      for i = 1, 10 do
        local pn = p(ent.pos.x + (dir.x * i),
          ent.pos.y + (dir.y * i))
        if _plyr.pos.x == pn.x and
            _plyr.pos.y == pn.y then
          -- set target
          ent.target = _plyr.pos
          ent.targetd = dir
          break
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
    ent.d = arr_choose(dirs)
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

function move_ent(ent, d)
  ent.hflip = d.x < 0 or (ent.hflip and d.x == 0)
  ent.dx = ent.d.x
  ent.dy = ent.d.y
  local np = add_t(ent.pos, d)
  local sld, tile = chk_tile(np, _fsolid)

  if sld then
    ent.ease = ease_bump
    on_bump(tile, np, ent, d)
    return
    -- flag set for visually obsructing
    -- tiles, e.g grass
  elseif chk_tile(np, _fgrass) then
    mset(np.x, np.y, tile - 1)
  end
  -- pickup item
  local itm = sld_ent_at(np)
  if itm and itm.can_pickup then
    ent.ease = ease_bump
    itm:on_ent(ent, np, d)
    return
  elseif itm and itm.is_fmob then
    ent.ease = ease_bump
    itm:on_ent(ent, np, d) --★ 223
    return
  end

  -- atk with weapon
  local atk_tiles = atk_ptrn(ent, ent.atkptr)
  for atk in all(atk_tiles) do
    local ent2 = sld_ent_at(atk)
    -- ★ atk self bugfix on use item
    if ent2 and ent2.can_dmg and not ent2.is_fmob and ent2 != ent then
      ent.ease = ease_bump
      ent2:on_ent(ent, np, d) --★ 223
      return
    end
  end

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
    del(_ents, ent)
  end

  sfx(4)
end

function on_atk(atk, ent)
  bump_at(atk, p(0, 0))

  ent.hp -= atk.atk
  ent.flash = 10
  add_atk(atk, ent)
  if ent.hp <= 0 then
    del(_ents, ent)
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
