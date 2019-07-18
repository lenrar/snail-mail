pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--initialize

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
	x0=-sprite_size+snail.width,
	y0=-sprite_size+snail.height,
	x1=screen_width-sprite_size,
	y1=screen_height-sprite_size
}

white=7
light_green=11

// init variables
function _init()
	cls()
	
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
	update_snail()
	update_letters()
	update_skulls()
		
	if btnp(❎) then
		state = states.menu
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
-->8
--main

function _update()
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
	local actor = {
		x = x or 0,
		y = y or 0,
		width = 7,
		height = 7,
		sprt = flr(rnd(2)) + 49
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
	snail.x = min(max(snail.x, bounds.x0), bounds.x1)
	snail.y = min(max(snail.y, bounds.y0), bounds.y1)
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
00000000000007070000000000a10707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000440ff00000070701110ff000a107070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070004944f0000440ff004944f0001110ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700004494f0004944f0004494f0004944f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ffffff0004494f00ffffff0004494f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ffff000ffffff000ffff000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888800000008080000000000a10808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8777778000440ff00000080801110ff000a108080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8577578004944f0000440ff004944f0001110ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8777778004494f0004944f0004494f0004944f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87667800ffffff0004494f00ffffff0004494f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
877778000ffff000ffffff000ffff000ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67777770030000000003000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66777760030000000030300000cc0c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67677670030300000030000000111cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6776677000303000003000000c1c7110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666030300000303030000c1cc1c7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000330000000000000011111cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c1c71110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c1cc1cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffff000444440007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005ff56000544540005775700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffff000444440007557700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000078777000787770007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f77777f04777774077070770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555000111110007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000040004000100010007000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
