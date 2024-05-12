function upd_visual_tiles()
    _tile_sigs = csv_to_arr("223,205,1,176,253,205,1,179,239,205,1,178,127,205,0,177,239,205,0,146,223,207,1,144,23,205,0,147,237,205,1,145,207,205,0,161,223,207,0,163,237,205,0,160,205,207,1,162,255,207,1,132")

    mapsig(function(x,y,sig)
        map_to_visual_tile(x,y,sig,chk_solidx(x,y) and 1 or 0)
    end)
end

function map_to_visual_tile(x,y,sig,sld)
    for i=1,#_tile_sigs,4 do
        if sig_match(sig,_tile_sigs[i],_tile_sigs[i+1])
          and _tile_sigs[i+2] == sld then
            mset(x,y,_tile_sigs[i+3])
            return
          end
    end
end

--
-- commented out kept for ease of revert and update
-- since the replacing code is minimized for token use and would be horrible to edit
--

-- function sig_verify(sig,a,msk,sld,res)
--     printh(a..","..msk..","..sld..","..res,"tile_checks.txt",false,true)
--     return sig_match(sig,a,msk)
-- end

-- function remap_tile(x,y,sig, sld)
--     if sig_verify(sig, 0b11011111,0b11001101,1,176) and sld then
--         mset(x,y,176) -- L 
--     elseif sig_verify(sig, 0b11111101,0b11001101,1,179) and sld then
--         mset(x,y,179) -- L 90
--     elseif sig_verify(sig, 0b11101111,0b11001101,1,178) and sld then
--         mset(x,y,178) -- L 180
--     elseif sig_verify(sig, 0b01111111,0b11001101,0,177) and not sld then
--         mset(x,y,177) -- L 270
--     elseif sig_verify(sig, 0b11101111,0b11001101,0,146) and not sld then
--         mset(x,y,146) --left
--     elseif sig_verify(sig, 0b11011111,0b11001111,1,144) and sld then
--         mset(x,y,144) --right
--     elseif sig_verify(sig, 0b11011111,0b11001101,0,147) and not sld then
--         mset(x,y,147) --top
--     elseif sig_verify(sig, 0b11101101,0b11001101,1,145) and sld then
--         mset(x,y,145) --bottom
--     elseif sig_verify(sig, 0b11001111,0b11001101,0,161) and not sld then
--         mset(x,y,161) --top left corner
--     elseif sig_verify(sig, 0b11011111,0b11001111,0,163) and not sld then
--         mset(x,y,163) --top right corner (incorrect)
--     elseif sig_verify(sig, 0b11101101,0b11001101,0,160)  and not sld then
--         mset(x,y,160) --bottom left corner
--     elseif sig_verify(sig, 0b11001101,0b11001111,1,162) and sld then
--         mset(x,y,162) -- bottom right corner
--     elseif sig_verify(sig, 0b11111111,0b11001111,1,132) and sld then
--         mset(x,y,132) --solid not (correct?)
--     else
--         mset(x,y,0) --empty
--     end

-- noblackout = true
-- end