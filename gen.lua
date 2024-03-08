-- gen

function start_rnd_gen()
  gen()
  flag_map()
  merge_areas()
  upd_tiles()
  add_slimes()
end

function start_test()
  init_gen()
  upd_tiles()
  add_mob(_mobmine, p(11, 3))
  add_mob(_mobmine, p(10, 3))
  add_mob(_mobmine, p(12, 3))
  add_mob(_mobmine, p(10, 4))
  add_mob(_mobmine, p(10, 4))
  add_trap(_mobsmok, p(8, 4), trap_noop)

  -- add_mob(_mobsnek, p(10, 3))
  -- add_mob(_mobsnek, p(11, 3))
  add_fmob(_mobgrass, p(8, 3))
end

function go_to_o(lookup, pos, ocp)
  local cp, cd = min_d_on_map(lookup, pos, ocp)
  if not cp then
    return
  end
  local path = { p(pos.x + cp.x, pos.y + cp.y) }
  local nxtp = path[1]
  while cd > 0 do
    cp, cd = min_d_on_map(lookup, nxtp, ocp)
    local np = p(nxtp.x + cp.x, nxtp.y + cp.y)
    add(path, p(np.x, np.y))
    nxtp = np
  end

  return path
end

function min_d_on_map(lookup, pos, ocp)
  -- local lookup = arr_to_tbl(nodes)
  local mini, mind = -1, 999
  local curd = lookup[ptoi(pos)]

  -- if we are on map our min is our current dist
  if curd then
    mind = curd
  end

  for i = 1, #dirs do
    local nx = pos.x + dirs[i].x
    local ny = pos.y + dirs[i].y

    local ndist = 999
    local look_d = lookup[ptoix(nx, ny)]
    -- if lookd_d is on path
    -- and aint occupied
    -- and is new low
    if look_d
        and ocp[ptoix(nx, ny)] == nil
        and look_d < mind
    then
      mini = i
      mind = look_d
    end
  end

  if mini == -1 then
    return
  end

  return dirs[mini], mind
end

-- generate

function add_door(r, hr, existing)
  local ranx = rnd()
  local np = {}
  if hr then
    np = p(r.x + r.w,
      in_rng(r.y + flr(ranx * r.h),
        r.y + 1, r.y + r.h - 1))
  else
    np =
        p(in_rng(r.x + flr(ranx * r.w), r.x + 1, r.x + r.w - 1),
          r.y + r.h)
  end
  existing[ptoi(np)] = np
end

function regen(iter, sz)
  --	 reload(0x1000, 0x1000, 0x2000)
  local w, h, iters = sz, sz, iter
  local rs = {rct(0, 0, w, h)}
  _ps = {}
  while iters > 0 do
    local nxt = {}
    for ir in all(rs) do
      local hr,valid,retry,nl,nr = iters % 2 == 0,false,10,{},{}

      while (not valid) do
        nl, nr = spl_rct(ir, hr)
        if hr then
          local a, b = p(nl.x + nl.w, nl.y),
              p(nl.x + nl.w, nl.y + nl.h)
          valid = _ps[ptoi(a)] == nil and _ps[ptoi(b)] == nil
        else
          local a, b = p(nl.x, nl.y + nl.h),
              p(nl.x + nl.w, nl.y + nl.h)
          valid = _ps[ptoi(a)] == nil and _ps[ptoi(b)] == nil
        end
        retry -= 1
        if retry < 0 then
          break
        end
      end
      add_door(nl, hr, _ps)
      add(nxt, nl)
      add(nxt, nr)
    end

    rs = {}
    for n in all(nxt) do
      add(rs, n)
    end
    iters -= 1
  end

  return rs
end

-- utils

function in_rng(n, _min, _max)
  return min(_max, max(_min, n))
end

-- rect

function rct(x, y, w, h)
  return { x = x, y = y, w = w, h = h }
end

function spl_rct(r, hor)
  local x, y, w, h = r.x, r.y, r.w, r.h

  local sp = in_rng(rnd(), .34, .66)
  local nw, nh = flr(w * sp),
      flr(h * sp)
  if hor then
    return rct(x, y, nw, h),
        rct(x + nw, y, w - nw, h)
  else
    return rct(x, y, w, nh),
        rct(x, y + nh,
          w, h - nh)
  end
end

function map_rct_rnd(r)
  -- ★ hack to never gen rooms of size 1
  local nw,nh,nx,idx,flrid = rnd_rng(r.w / 2, r.w),
                rnd_rng(r.h / 2, r.h),
                r.x,
                1,
                2+_room_idx

  local y = r.y
  for i = 0, nh, 1 do
    mset(nx, y + i, idx)
    mset(nx + nw, y + i, idx)
    if i != 0 and i != nh then
      for mx = 1, nw - 1, 1 do
        mset(nx + mx, y + i, flrid)
      end
    end
  end

  _room_idx += 1
  _room_idx %= 5
end

function map_doors()
  for k, v in pairs(_ps) do
    mset(v.x, v.y, 9)
  end
end

--
-- ● gen maze
--

-- gen and dig
function init_gen()
  sig_dir = {
    0b11111111,
    0b01110110,     -- left
    0b10110011,     -- up
    0b11011001,     -- right
    0b11101100,     -- down
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
  mapsig(function(x, y, sig)
    if chk_solid(p(x, y)) and sig == sig_dig then
      mset(x, y, t_dig)
      add(_digable, { x = x, y = y })
    end
  end)
end

function is_carvable(a)
  for i = 1, #sig_dir do
    if sig_match(a, sig_dir[i], sig_msk[i]) then
      return true
    end
  end
  return false
end

function dig(po)
  local px, py, dx, dy = po.x, po.y, 0, 1
  mset(px, py, 0)
  local nextdig = {}
  for dr in all(dirs) do
    if not chk_solid(po) and is_carvable(tile_sig(add_t(po, dr))) then
      add(nextdig, add_t(po, dr))
    end
  end

  return nextdig
end

function dig_tunnel()
  local start,dug = arr_choose(_digable), {}
  local ndig = dig(start)
  local keepdigging = #ndig > 0

  while keepdigging do
    local pdig = arr_choose(ndig)
    if dug[ptoi(pdig)] then
      printh("backtracking lets break")
      break
    end

    dug[ptoi(pdig)],ndig = true, dig(pdig)
    _curx,_cury,keepdigging = pdig.x * 8, pdig.y * 8, #ndig >0
  end
end

function gen()
  init_gen()
  fill_map(1)
  _gen_rct = regen(_iterations, _size)
  _room_idx = 0
  foreach(_gen_rct, map_rct_rnd)

  -- set tiles digable when
  -- sourounded by walls
  set_digable_start()

  update_digables()
  while #_digable > 1 do
    local st = dig_tunnel()
    update_digables()
  end

  set_digable_start()
end

function set_digable_start()
  mapsig(function(x, y, sig)
    if chk_solid(p(x, y)) then
      if is_digable(sig) then
        mset(x, y, t_dig)
        add(digs, p(x, y))
      else
        mset(x, y, t_ndig)
      end
    end
  end)
end

function is_digable(a)
  if sig_match(a, 255) then
    return true
  end
  return false
end

-- utils for rnd

function rnd_idx(n)
  return flr(rnd() * n) + 1
end

function arr_choose(myarr)
  local mri = rnd_idx(#myarr)
  return myarr[mri]
end

function mapsig(func)
-- token: -2 if map2d
  for y = 0, _size do
    for x = 0, _size do
      func(x, y, tile_sig(p(x, y)))
    end
  end
end

function fill_map(t)
  mapsig(function(x, y, sig)
    mset(x, y, t)
  end)
end

function flag_map()
  _cf = 0
  local mapf = {}
  mapsig(
    function(x, y, sig)
      local idx = ptoix(x, y)
      if mapf[idx] then
      elseif not chk_solid(p(x, y)) then
        flag_section(x, y, _cf, mapf)
        _cf += 1
      end
    end
  )

  _flagmap = {}
  _flagmap = mapf
  _dbg[3] = #_flagmap
  _dbg[4] = _cf
end

function flag_section(x, y, f, res)
  local flooded = flood_fill(p(x, y), {})
  for po in all(flooded) do
    --		add(res,{po=po.po, f=f})
    res[ptoi(po.po)] = { po = po.po, f = f }
  end
  --	stop()
end

-- signature funcs

function tile_sigxy(x,y)
  tile_sig(p(x,y))
end

function tile_sig(po)
  local sig = 0
  for i = 1, 8 do
    local d = dir8[i]
    if chk_solid(add_t(po, d)) then
      sig += 1
    end
    if i < 8 then
      sig = shl(sig, 1)
    end
  end
  return sig
end

function inbound(x, y)
  return x > 0 and x < _size and y > 0 and y < _size
end

function gen_junctions()
  _junctions = {}
  mapsig(
    function(x, y, sig)
      if inbound(x, y - 1)
          and inbound(x, y + 1)
          and sig_match(sig, 0b10100000,
            0b00001111)
          and chk_solid(p(x, y))
      then
        add(_junctions,
          {
            x = x,
            y = y,
            a = _flagmap[ptoix(x, y - 1)].f,
            b = _flagmap[ptoix(x, y + 1)].f
          })
      elseif inbound(x - 1, y)
          and inbound(x + 1, y)
          and sig_match(sig, 0b01010000,
            0b00001111)
          and chk_solid(p(x, y))
      then
        add(_junctions,
          {
            x = x,
            y = y,
            a = _flagmap[ptoix(x - 1, y)].f,
            b = _flagmap[ptoix(x + 1, y)].f
          })
      end
    end
  )
end

function merge_small_areas()
  for i = 0, _cf do
    local cons = {}
    local p = get_passage(_junctions, i)
    if (#p > 0) then
      for co in all(p) do
        if not cons[co.v] then
          cons[co.v] = true
          local minsz = 12
          if section_sz(co.v) <= minsz
              and section_sz(i) <= minsz
          then
            mset(co.x, co.y, 48)
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
  gen_doors();

end

function gen_doors()
  local mdoors = {}
  for i = 0, _cf do
    local cons = {}

    local passage = get_passage(_junctions, i)
    if (#passage > 0) then
      local opn = arr_choose(passage)
      for co in all(passage) do
        if not cons[co.v] then
          cons[co.v] = true
          mset(co.x, co.y, 0)
          mdoors[ptoix(co.x,co.y)] = p(co.x,co.y)
        end
      end
    end
  end

  for k,v in pairs(mdoors) do
    add_fmob(_mobdoor,v)
  end
end

-- noblackout = true

ofset = {}
function upd_door_tiles(x, y)
  offset_tile(x, y, 5)
  offset_tile(x - 1, y, 5)
  offset_tile(x, y - 1, 5)
  offset_tile(x - 1, y - 1, 5)
end

function offset_tile(x, y, of)
  if ofset[ptoix(x, y)] then
    return
  end

  ofset[ptoix(x, y)] = true
  local tk = mget(x, y)
  mset(x, y, tk + of)
end

function section_sz(idx)
  cnt = 0
  for k, v in pairs(_flagmap) do
    cnt = v.f == idx and cnt + 1 or cnt
  end

  return cnt
end

function get_passage(juncs, to)
  local res = {}
  for j in all(juncs) do
    if j.a != j.b and (j.a == to or j.b == to) then
      local other = j.a == to and j.b or j.a
      add(res, { x = j.x, y = j.y, v = other })
    end
  end
  return res
end

function add_slimes()
  mapsig(function(x, y, sig)
    local r1, r2, r3 = rnd(1000),
        rnd(1000),
        rnd(1000)
    if not chk_solid(p(x, y)) and not sld_ent_at(p(x,y)) then
      if gen_traps(x, y, sig, r1) then
      elseif gen_tiles(x, y, sig, r2) then
      elseif gen_mobs(x, y, sig, r3) then
      end
    end
  end)
end

function gen_traps(x, y, sig, r)
  if not chk_solid(p(x, y)) then
    if sig == 0 and r <= 100 then
      add_trap(_mobacid, p(x, y))
      return true
    end
  end
  return false
end

function gen_tiles(x, y, sig, r)
  local po = p(x,y)
  if _genweed.pred(sig)
      and r <= _genweed.r
  then
    add_fmob(_mobgrass, po, true)
    return true
  elseif r < _genclam.r then
    add_fmob(_mobchest, po, false)
    return true
  end

  return false
end

function gen_mobs(x, y, sig, r)
  if r <= _gensqid.r then
    add_mob(_mobmine, p(x, y))
    return true
  elseif r <= _gensnek.r then
    add_mob(_gensnek.id, p(x, y))
    return true
  end

  return true
end
