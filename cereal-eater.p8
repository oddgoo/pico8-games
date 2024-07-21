pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
radius = 32
center = 64
t=0

game_state = "title"
selected_year = 1
years = {
    {bg=0xef, milk=7, flakes={1,2}},
    {bg=0x03, milk=14, flakes={2,3}},
    {bg=0x07, milk=2, flakes={3,4}}
}
function _init()
	 -- Initialize title screen
end

function _update()
	if game_state == "title" then
	 if btnp(❎) then game_state = "year_select" end
	elseif game_state == "year_select" then
	 if btnp(⬅️) then selected_year = max(1, selected_year - 1) end
	 if btnp(➡️) then selected_year = min(#years, selected_year + 1) end
	 if btnp(❎) then start_game() end
	else
	 t=t+1
	 move_spoon()
	end
end

function start_game()
	setup_flakes()
	game_state = "game"
end

function _draw()
	if game_state == "title" then
	 cls()
	 print("Cereal Eater", 44, 32, 7)
	 print("Press X to start", 34, 64, 7)
	elseif game_state == "year_select" then
	 cls()
	 print("Select Year", 44, 32, 7)
	 print("<- Year " .. selected_year .. " ->", 34, 64, 7)
	else
	 local year = years[selected_year]
	 
	 -- Background
	 fillp(0b1100110000110011)
	 rectfill(0,0,128,128,year.bg)
	 fillp()
	 
	 -- Bowl and milk
	 circfill(64,68,42,1)
	 circfill(64,64,40,6)
	 circfill(64,64,20,15)
	 circfill(64,64,radius+4,year.milk)
	 
	 draw_splashes()
	 
	 move_flakes()
	 collide_flakes()
	 bound_flakes()
	 draw_flakes()
	
	 update_spoon()
	end
end

-->8
--spoon---------------
a={0,0}
sp={80,80}
acc = 1.5
size=32
s_state = 0

function move_spoon()
 input()
 sp[1]=sp[1]+a[1]/1.5
 sp[2]=sp[2]+a[2]/1.5
 sp = bound(sp[1],sp[2])
 damp()
end

function damp()
	a[1]=a[1]*0.8
	a[2]=a[2]*0.8
end
sfx(3)
spoon_offset = -4

function update_spoon()
	if(btn(4)) then
	 if (s_state == 0) then
	  sfx(1)
	  add_splash(sp[1],sp[2])
	 end
	 sspr(8,0,32,32,sp[1]+spoon_offset,sp[2]+spoon_offset,
	 size-2,size-2)
	 s_state=1
	else
	 sspr(8,0,32,32,sp[1]+spoon_offset,sp[2]+spoon_offset,
	 size,size)
	 sspr(0,8,7, 15,sp[1]+spoon_offset,sp[2]+spoon_offset,
	 8,16)
	 if(s_state==1) then
	  sfx(2)
	  radius-=1
	  s_state=0
	  eat_flakes_at(sp[1],sp[2])
	  check_dry_flakes()
	 end
	end 
   end

   function check_dry_flakes()
	local threshold = -4
	local radius_threshold = radius - threshold
	for i = #flakes, 1, -1 do
	 local f = flakes[i]
	 local dx = f.x - center
	 local dy = f.y - center
	 local dist_sq = dx*dx + dy*dy
	 if dist_sq > radius_threshold^2 and rnd() < 0.1 then
	  f.a.x, f.a.y = 0, 0
	  add(dry_flakes, f)
	  del(flakes, f)
	 end
	end
   end

function input()
	if(btn(0)) then a[1]=a[1]-acc end
	if(btn(1)) then a[1]=a[1]+acc end
	if(btn(2)) then a[2]=a[2]-acc end
	if(btn(3)) then a[2]=a[2]+acc end
end

-->8
--cereal---------------

function draw_sprite()
end

function draw_particle()
end

-->8
--flakes---------------
flakes = {}
dry_flakes = {}
flake_amount = 90

function setup_flakes()
    flakes = {}
    local year = years[selected_year]
    for i=1,flake_amount do
        add(flakes, {
            id = i,
            x = 64-radius+rnd(radius*2),
            y = 64-radius+rnd(radius*2),
            a = {x=rnd(4)-2, y=rnd(4)-2},
            s = year.flakes[flr(rnd(2))+1], -- Randomly select one of the two sprites
            b = rnd(6)
        })
    end
end

function draw_flakes()
    for f in all(flakes) do
        sspr(
        flake_s[f.s].x,
        flake_s[f.s].y,
        flake_s[f.s].w,
        flake_s[f.s].h-flr(f.b),
        f.x,f.y-flr(f.b))
    end

    for f in all(dry_flakes) do
        sspr(
        flake_s[f.s].x,
        flake_s[f.s].y,
        flake_s[f.s].w,
        flake_s[f.s].h-flr(f.b),
        f.x,f.y-flr(f.b),
        flake_s[f.s].w,
        flake_s[f.s].h-flr(f.b),
        false,false)
    end
end
--flakes[i][1] + flakes[i].a[1],
--flakes[i][2] + flakes[i].a[2],

-- function move_flakes()
-- 	for f in all(flakes) do
-- 		f.x += f.a.x
-- 		f.y += f.a.y
-- 		f.a.x = sin(t/90 + f.id/flake_amount)/2
-- 		f.a.y = cos(t/60 + f.id/flake_amount)/2
-- 		f.b += 0.01
-- 		if f.b > 1.8 then f.b = rnd(4) end
-- 	end
-- end

function move_flakes()
	for i=1,#flakes do
		flakes[i].x = flakes[i].x+flakes[i].a.x/2*i/#flakes
		flakes[i].y = flakes[i].y+flakes[i].a.y/2*i/#flakes
		flakes[i].a = 
		{x= sin(t/90 + i/#flakes)/2  , 
		 y = cos(t/60 + i/#flakes)/2 }
		flakes[i].b += 0.01
		if(flakes[i].b>1.8) flakes[i].b=rnd(4)
	end
end
   
function collide_flakes()
for i = 1, #flakes - 1 do
	local f1 = flakes[i]
	local f2 = flakes[i + 1]
	local dx = f1.x - f2.x
	local dy = f1.y - f2.y
	local dist_sq = dx*dx + dy*dy
	
	if dist_sq < 4 then -- 2^2 = 4
	local angle = atan2(dy, dx)
	f1.x += cos(angle) * 0.5
	f1.y += sin(angle) * 0.5
	f2.x -= cos(angle) * 0.5
	f2.y -= sin(angle) * 0.5
	end
end
end


function bound_flakes()
for f in all(flakes) do
	local dx = f.x - center
	local dy = f.y - center
	local dist_sq = dx*dx + dy*dy
	if dist_sq > (radius+5)^2 then
	local angle = atan2(dy, dx)
	f.x = center + radius * cos(angle)
	f.y = center + radius * sin(angle)
	end
end
end

function eat_flakes_at(x, y)
for i = #flakes, 1, -1 do
	local f = flakes[i]
	local dx = f.x - x
	local dy = f.y - y
	if dx*dx + dy*dy < 64 then -- 8^2 = 64
	del(flakes, f)
	end
end
end

-->8
--utils---------------
function dist(o1,o2)
 local pos_diff= {o1[1] - o2[1], o1[2] - o2[2] }
	return sqrt(pos_diff[1]*pos_diff[1] + pos_diff[2]*pos_diff[2])
end

function bound(cx,cy)
 local pos_diff= {cx - center,cy - center }
 local distance = sqrt(pos_diff[1]*pos_diff[1] + pos_diff[2]*pos_diff[2])
 local bounded = {cx,cy}
 if(distance>radius+5) then
	bounded[1] = radius*pos_diff[1]/distance + center
	bounded[2] = radius*pos_diff[2]/distance + center
 end
 return bounded
end



-->8
--splash-----

splashes = {}

function add_splash(x,y)
--check if it's inside loop first
	
	for i=0,2 do
		add(splashes,
		{x+rnd(100) - 50,
		y+rnd(100) - 50,
		ceil(rnd(12))}) --random splash sprite
	end
end

function draw_splashes()
	for s in all(splashes) do
	 local sp = splash_s[s[3]]
	 sspr(sp.x,sp.y,sp.w,sp.h,s[1],s[2])
	end
end

-->8
--sprite maps--

flake_s = {}
flake_s[1] = {x=45,y=5,w=3,h=3}
flake_s[2] = {x=45,y=0,w=3,h=3}
flake_s[3] = {x=40,y=0,w=3,h=3}
flake_s[4] = {x=40,y=5,w=3,h=3}

splash_s = {}
splash_s[1] = {x=64,y=0,w=2,h=2}
splash_s[2] = {x=70,y=0,w=2,h=2}
splash_s[3] = {x=67,y=0,w=1,h=1}
splash_s[4] = {x=67,y=3,w=5,h=5}
splash_s[5] = {x=64,y=4,w=2,h=2}
splash_s[6] = {x=72,y=0,w=8,h=8}
splash_s[7] = {x=80,y=0,w=8,h=8}
splash_s[8] = {x=88,y=0,w=8,h=8}
splash_s[9] = {x=96,y=0,w=8,h=8}
splash_s[10] = {x=104,y=0,w=10,h=10}
splash_s[11] = {x=64,y=0,w=2,h=2}
splash_s[12] = {x=70,y=0,w=2,h=2}

__gfx__
000000000000000000000000000000000000000009000e0e00000000000000007707000700070000000070000000000070700000070007000070000000000000
0000000000000000d00000000000000000000000499002ee00000000000000000700007007077000000007700700707007700000007777770700000000000000
0070070000000000dd00000000000000000000000400002000000000000000000000000007777777077007000007777007070000077777777770000000000000
00077000000000006dd0000000000000000000000000000000000000000000000000707007777770007000000007700000000700077777777000000000000000
00077000000000006dd0000000000000000000000000000000000000000000007007770077777700000000700077070000007700777777777700000000000000
007007000000000066d0000000000000000000003bb00fa000000000000000000700777700777700000070000070007000000000070777777000000000000000
000000000000000066d00000000000000000000003b009fa00000000000000000000777707070000070000000700700000000070000777777770000000000000
000000000000000066d0000000000000000000000030009f00000000000000000007077000000070000000000000000000000000000777777700000000000000
066ddddd0677666667d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000007077770000000000000000
666666dd00677666d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000
66666666000666666d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666660000000000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67666666000000000000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
676666660000000000000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6776666600000000000000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000d6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000d677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000dd67700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000dd6770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000dd670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000dd60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000167701475015750177501a750157501d7501355015550185501c550017500175001750017500175019750215500175001750017500075000750000000000000000000000000000000000000000000000
010200000f151101511115113151171511a1510215102151001010010100101000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
