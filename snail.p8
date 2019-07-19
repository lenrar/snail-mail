pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--initialize

points = 100

timer = 0

states = {menu=0, game=1}

state = states.menu

actions = {idle=0, moving=1}

current_lvl = {num=0}

anim_speed = 7

snail = {
	x=0,
	y=0,
	sprt=1,
	width=8,
	tmr=1,
	flp=false,
	action=actions.idle,
	height = 6,
	speed = 0.8,
	demon = false,
	post = false
}

people={}
human_sprites = {5, 21}
letters = {}
skulls = {}
plants={}
fruits={}

actors={
	people,
	letters, 
	skulls, 
	plants, 
	fruits
}

screen_width = 128
screen_height = 128
sprite_size=8

bounds = {
	x0=0,
	y0=0,
	x1=screen_width,
	y1=screen_height
}

white=7
light_green=11

// init variables
function _init()
	cls()
	music(0)
	
	lvl_change(1)
	
	init_actors()

end

function init_actors()
	init_letters()
	init_people()
	init_plants()
	init_fruits()
	init_skulls()
end

function init_letters()
	add_letter(10,screen_height/4)
	add_letter(10,(screen_height*2)/4)
	add_letter(10,(screen_height*3)/4)
end

function init_people()
	local x = screen_width - 10
	add_person(x,screen_height/4)
	add_person(x,(screen_height*2)/4)
	add_person(x,(screen_height*3)/4)
end

function init_plants()
end

function init_fruits()
end

function init_skulls()
	add_skull(screen_width/2,30)
end
-->8
--update

function update_menu()

	if btnp(❎) then
		state = states.game
	end
	
end

function update_game()
	update_points()
	update_snail()
	update_letters()
	update_skulls()
	update_people()
	
	if btnp(❎) then
		state = states.menu
	end

end

function update_points()
	if timer%30 == 0 then
		points -= 1
	end
end

function update_snail()
	if btn(⬆️) or btn(⬇️) or btn(⬅️) or btn(➡️) then
		snail.action = actions.moving
		move_snail()
	else
		snail.action = actions.idle
	end
	
	animate_snail()
end

function update_letters()
	-- technically also updates
	-- snail when necessary
	local i = 1
	local len = #letters
	while i <= len do
		local letter = letters[i]
		if collides(snail, letter) and not snail.post then
		
			del(letters, letter)
			snail.post=true
			i-=1
			len=#letters
			sfx(5)
		
		end
		i+=1
	end

end

function update_skulls()
	-- technically also updates
	-- snail when necessary
	local i = 1
	local len = #skulls
	while i <= len do
		local skull = skulls[i]
		if collides(snail, skull) and not snail.demon then
		
			del(skulls, skull)
			snail.demon=true
			i-=1
			len=#skulls
			sfx(7)
		
		end
		i+=1
	end
end

function update_people()
	-- you guessed it, this
	-- updates all people actors
	local i = 1
	local len = #people
	while i <= len do
		local person = people[i]
		if collides(snail, person) 
		and not person.dead then
			
			if snail.demon then
				points += 1
				--die
				people[i].dead = true
				people[i].sprt = 52
				snail.demon = false
				sfx(4)
			elseif snail.post then
				--disappear, + points!
				del(people, person)
				i-=1
				len=#people
				points += 10
				snail.post = false
				sfx(6)
			else
				-- maybe allow snail to push?
			end
		
		end
		i+=1
	end
	
end
-->8
--draw

function draw_menu()
	cls()
	local title = "snail mail: the game"
	local prompt = "press ❎ to start!"
	cprint(title, 0, -16, white)
	cprint(prompt)
end

function draw_game()
	cls(light_green)
	
	draw_actors()
	draw_snail()
	draw_ui()
	
end

function draw_snail()
	-- draw snail
	spr(snail.sprt, snail.x, snail.y, 1, 1, snail.flp, false)
end

function draw_actors()
	-- loops over tables of actors
	-- and draws each one.
	for i=1,#actors do
		actor_table = actors[i]
		for x=1,#actor_table do
			a = actor_table[x]
			spr(a.sprt, a.x, a.y)
		end
	end
end

function draw_ui()
	score_string = "score: " .. points
	cprint(score_string, 1, -59, 3)
	cprint(score_string, 0, -60, 7)
end
-->8
--main

function _update()
	timer += 1
	-- reset timer once a minute
	if timer >= 1800 then
		timer = 0
	end
	
	if(state == states.menu) then
		update_menu()
	elseif (state == states.game) then
		update_game()
	end
end

function _draw()
	
	if (state == states.menu) then
		draw_menu()
	elseif (state == states.game) then
		draw_game()
	end
	
end
-->8
--util

-- ==============
-- string helpers
-- ==============

function get_mag(v)
	-- get magnitude of a vector
	-- (table with x and y)
	local x = abs(v.x)
	local y = abs(v.y)
	mag = sqrt(x^2 + y^2)
	return mag
end

function set_mag(v, mag)
	-- set magnitude of a vector
	old_mag = get_mag(v)
	scale = mag/old_mag
	v.x *= scale
	v.y *= scale
end

function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end
 
function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end

function cprint(s, xo, yo, col)
	x = xo or 0
	y = yo or 0
	c = col or white
	print(s, hcenter(s) + x, vcenter(s) + y, c)
	
end

-- ============
-- game helpers
-- ============

function enforce_bounds(a, b)
	-- a: actor (has x, y, width, height)
	-- b: bounds (has x0,x1,y0,y1)
	bnds = b or bounds
	-- actor specific bounds
	-- assume all sprites are
	-- aligned upper-left
	local a_bnds = {
		x0=bnds.x0,
		x1=bnds.x1 - a.width,
		y0=bnds.y0,
		y1=bnds.y1 - a.height
	}
	
	a.x = min(max(a.x, a_bnds.x0), a_bnds.x1)
	a.y = min(max(a.y, a_bnds.y0), a_bnds.y1)
end

function collides(a1, a2)
	-- true if actors are colliding
	-- a1 - actor 1
	-- a2 - actor 2
	return (a1.x < a2.x + a2.width 
	and a1.x + a1.width > a2.x 
	and a1.y < a2.y + a2.height 
	and a1.y + a1.height > a2.y)

end

function add_letter(x, y)
	-- adds a letter at x & y 
	-- specified
	local actor = {
		x = x or 0,
		y = y or 0,
		width = 7,
		height = 5,
		sprt = 32
	}
	t = letters
	
	add(t, actor)
end

function add_skull(x, y)
	-- adds a skull at x & y 
	-- specified
		local actor = {
		x = x or 0,
		y = y or 0,
		width = 7,
		height = 7,
		sprt = 16
	}
	t = skulls
	
	add(t, actor)
end

function add_person(x, y)
	local sprite = human_sprites[flr(rnd(#human_sprites)) + 1]

	local actor = {
		x = x or 0,
		y = y or 0,
		width = 7,
		height = 7,
		base_sprt = sprite,
		sprt = sprite,
		dead=false,
		speed=0.8
	}
	t = people
	
	add(t, actor)
end

function lvl_change(lvl_num)

	current_lvl.num = lvl_num
	if current_lvl.num == 1 then
		snail.x = ((bounds.x0 + bounds.x1) / 2) - 8
		snail.y = ((bounds.y0 + bounds.y1) / 2) - 8
	end

end


-- =============
-- snail helpers
-- =============

function move_snail()
	local s = snail.speed
	local move = {x=0,y=0}
	
	if btn(⬆️) then move.y-=1 end
	if btn(⬇️) then move.y+=1 end
	if btn(➡️) then 
		move.x+=s
		snail.flp=false
	end
	if btn(⬅️) then
		move.x-=s
		snail.flp=true
	end
	
	set_mag(move, s)
	
	snail.x += move.x
	snail.y += move.y
	enforce_bounds(snail)
end

function animate_snail()
	-- currently there is only
	-- a move animation, so we
	-- can just inc/dec sprite
	local base = 1
	if snail.demon then
		base += 16
	end
	if snail.post then
		base += 2
	end
	
	if snail.action == actions.idle then
		snail.tmr = 0
		snail.sprt = base
	elseif snail.action == actions.moving then
		snail.tmr += snail.speed
		if(snail.tmr >= anim_speed) then 
			snail.sprt = base + 1
		end
		if (snail.tmr >= 2 * anim_speed) then
			snail.sprt = base
			snail.tmr = 0 -- reset timer, loop
		end
	end
end
__gfx__
00000000000007070000000000a10707000000000444440004444400044444000000000000000000000000000000000000000000000000000000000000000000
0000000000440ff00000070701110ff000a107070544540005445400054454000000000000000000000000000000000000000000000000000000000000000000
0070070004944f0000440ff004944f0001110ff00444440004444400044444000000000000000000000000000000000000000000000000000000000000000000
0007700004494f0004944f0004494f0004944f000787770007877700078777000000000000000000000000000000000000000000000000000000000000000000
00077000ffffff0004494f00ffffff0004494f004777774047777740477777400000000000000000000000000000000000000000000000000000000000000000
007007000ffff000ffffff000ffff000ffffff000111110001111110111111000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000100010001000000000001000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888800000008080000000000a10808000000000fffff000fffff000fffff000000000000000000000000000000000000000000000000000000000000000000
8777778000440ff00000080801110ff000a1080805ff560005ff560005ff56000000000000000000000000000000000000000000000000000000000000000000
8577578004944f0000440ff004944f0001110ff00fffff000fffff000fffff000000000000000000000000000000000000000000000000000000000000000000
8777778004494f0004944f0004494f0004944f000787770007877700078777000000000000000000000000000000000000000000000000000000000000000000
87667800ffffff0004494f00ffffff0004494f00f77777f0f77777f0f77777f00000000000000000000000000000000000000000000000000000000000000000
877778000ffff000ffffff000ffff000ffffff000555550005555540455555000000000000000000000000000000000000000000000000000000000000000000
08888000000000000000000000000000000000000400040004000000000004000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67777770030000000003000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66777760030000000030300000cc0c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67677670030300000030000000111cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6776677000303000003000000c1c7110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666030300000303030000c1cc1c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000330000000000000011111cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c1c71110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c1cc1cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffff000444440007777700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005ff56000544540005775700777775700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffff000444440007557700070757700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000078777000787770007777700077757700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f77777f04777774077070770070775700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555000111110007777700777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000040004000100010007000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110000018564185550c5440c53500524005150050300503005000050000500005000050000500005000050018564185550c5440c535005240051500503005030000000000000000000000000000000000000000
011000000403104031040310403105031050310503105031070310703107031070310503105031050310503110031100311003110031110311103111031110311303113031130311303111031110311103111031
011000002375224752217520000523752247522175200005267521c7522475200005267521c75224752000052375224752217521800523752247522175200002267521c7522475200002267521c7522475200005
011000000c6330c63300000000000c633000000c6330000000000000001063310633000001063300000106330c6330c63300000000000c633000000c633000000000000000106331063300000106330000010633
010a00000347600000014760000000476000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000185741a5741c5740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001c5741a574185740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000467404671046710467104671046750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00414243
00 00024344
03 00010203
00 00010203

