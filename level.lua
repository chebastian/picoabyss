
function upd_tiles()
    tile_borders()
end

function tile_borders()
 cmapsig(function(x,y,sig)
    -- if sig_match(sig, 0b10101111,0b10001001) then
    local sld = chk_solid(p(x,y))
    if sig_match(sig, 0b10101111,0b10001101) and not sld then
        mset(x,y,146) --right
    elseif sig_match(sig, 0b11011111,0b10001111) and sld then
        mset(x,y,144) --left
    elseif sig_match(sig, 0b01011111,0b00010011) and not sld then
        mset(x,y,145) --bottom
    elseif sig_match(sig, 0b11001111,0b11001101) and not sld then
        mset(x,y,161) --top left corner
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