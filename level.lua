
function upd_tiles()
    tile_borders()
end

function tile_borders()
 cmapsig(function(x,y,sig)
    local sld = chk_solid(p(x,y))
    if sig_match(sig, 0b11011111,0b11001101) and sld then
        mset(x,y,176) -- L 
    elseif sig_match(sig, 0b11111101,0b11001101) and sld then
        mset(x,y,179) -- L 90
    elseif sig_match(sig, 0b11101111,0b11001101) and sld then
        mset(x,y,178) -- L 180
    elseif sig_match(sig, 0b01111111,0b11001101) and not sld then
        mset(x,y,177) -- L 270
    elseif sig_match(sig, 0b11101111,0b11001101) and not sld then
        mset(x,y,146) --left
    elseif sig_match(sig, 0b11011111,0b11001111) and sld then
        mset(x,y,144) --right
    elseif sig_match(sig, 0b11011111,0b11001101) and not sld then
        mset(x,y,147) --top
    elseif sig_match(sig, 0b11101101,0b11001101) and sld then
        mset(x,y,145) --bottom
    elseif sig_match(sig, 0b11001111,0b11001101) and not sld then
        mset(x,y,161) --top left corner
    -- elseif sig_match(sig, 0b00011101,0b01101101) and not sld then
    elseif sig_match(sig, 0b11011111,0b11001111) and not sld then
        mset(x,y,163) --top right corner (incorrect)
    elseif sig_match(sig, 0b11101101,0b11001101)  and not sld then
        mset(x,y,160) --bottom left corner
    elseif sig_match(sig, 0b11001101,0b11001111) and sld then
        mset(x,y,162) -- bottom right corner
    elseif sig_match(sig, 0b11111111,0b11001111) and sld then
        mset(x,y,132) --solid not (correct?)
    end
 end)
end

function cmapsig(func)
    local sigs = {}
	for y=0,_size do
		for x=0,_size do
            sigs[ptoix(x,y)] = tile_sig(p(x,y))
		end
	end

	for y=0,_size do
		for x=0,_size do
			func(x,y,sigs[ptoix(x,y)])
		end
	end
end