--#   ,-.       _,---._ __  / \
--#  /  )    .-'       `./ /   \
--# (  (   ,'            `/    /|
--#  \  `-"             \'\   / |
--#   `.              ,  \ \ /  |
--#    /`.          ,'-`----Y   |
--#   (            ;        |   '
--#   |  ,-.    ,-'         |  /
--#   |  | (   |   Meechie  | /
--#   )  |  \  `.___________|/
--================================================================================
-- SortieAnnouncer LUA - v0.2 Date: 2026-10-25
--================================================================================

_addon.name     = 'SortieAnnouncer'
_addon.author   = 'Soulfly, Meechie'
_addon.version  = '0.2'
_addon.commands = {'sa', 'sra', 'sortieannouncer'}

local config = require('config')
local texts  = require('texts')
local res    = require('resources')

-- ==[ Settings ]==============================================
local line_delay = 1.5
local auto_delay = 3
local debug_on   = false

local defaults = {
	auto    = false,
	compact = false,
	active  = 'dhabcgef',
	routes  = {},
	hud_on  = true,
	hud     = {
		pos     = {x = 100, y = 300},
		bg      = {alpha = 180, red = 0, green = 0, blue = 0},
		text    = {size = 10, font = 'Consolas', red = 255, green = 255, blue = 255},
		padding = 4,
		flags   = {draggable = true},
	},
}

local settings = config.load(defaults)

-- ==[ Colors ]================================================
local c_head  = 207
local c_num   = 220
local c_mob   = 158
local c_zone  = 160
local c_done  = 8
local c_dbg   = 123
local c_text  = 1

-- ==[ Default Messages ]======================================
local default_messages = {
	{
		type = "reminders",
		messages = {
			"  ----------   ----------   ----------",
			"| ◇◆ Don't forget ◆◇",
			"|     Food | Panacea | Remedy | Echo",
			"|     Prism | Oil | Reraise | Ionis",
			"|  >> CHECK YOUR MAIN and SUBJOB!!! <<",
		}
	},
	{
		type = "geo7boss",
		messages = {
			"◆◇◆ DH - ABC GEF ( 7-Boss ) ◆◇◆",
			" Split Order:",
			"  → A: RDM (solo) - (leech) x3-6 Kill w/ Magic",
			"  → B: COR (solo) - (elem.) x3 kill <30 secs. + x5 WS Biune",
			"  → C: GEO + DD   - (undead) x3 Magic Burst",
			"  → D: PLD + BRD  - (fomor) x3 4-step Skillchain",
		}
	},
	{
		type = "aboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ A ★ Boss: Ghadjot",
			"| 【 AVOID : Reverberation / Distortion / Darkness 】",
			"| ◆◇ KITING STRATEGY ◇◆ 【 Fire Threnody + Firestorm 】",
			"|    Savage Blade | Upheaval | Judgment | Black Halo",
			"|    Origin | Insurgency | Shark Bite | Tachi: Kagero/Kasha",
		}
	},
	{
		type = "bboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ B ★ Boss: Leshonn",
			"| 【 THUNDER : MINIMAL DEBUFFS - AVOID LIGHT 】",
			"| 【 WIND : REMOVE BUFF (Protect,Phalanx) - AVOID LIGHT 】",
			"| ◆◇ KITING STRATEGY ◇◆",
			"|    Savage Blade | Judgment | Rudra's Storm",
			"|    Cross Reaper | Tachi: Mumei | Impulse Drive",
		}
	},
	{
		type = "cboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ C ★ Boss: Skmora",
			"| 【 AVOID : Compression / Gravitation / Darkness 】",
			"| 【 3 Minutes to kill !!! 】",
			"| ◆◇ FACE TANK STRATEGY ◇◆",
			"|    Savage Blade | Upheaval | Judgment | Shark Bite",
			"|    Origin | Insurgency | Tachi: Fudo/Kasha",
		}
	},
	{
		type = "dboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ D ★ Boss: Degei",
			"| 【 FIRE | THUNDER - AVOID LIGHT 】",
			"| 【 WATER | ICE | EARTH - AVOID DARKNESS 】",
			"| ◆◇ HYBRID STRATEGY ◇◆ - allow 1 ability to trigger",
			"|    Savage Blade | Upheaval | Judgment | Shark Bite",
			"|    Origin | Insurgency | Tachi: Fudo/Mumei",
		}
	},
	{
		type = "eboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ E ★ Boss: Dhartok ( Blitzer: A → E )",
			"| 【 AVOID : Reverberation / Distortion / Darkness 】",
			"| ◆◇ KITING STRATEGY ◇◆ 【 Fire Threnody + Firestorm 】",
			"|    Savage Blade | Upheaval | Black Halo | Shark Bite",
			"|    Origin | Insurgency | Tachi: Kagero/Kasha",
		}
	},
	{
		type = "fboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ F ★ Boss: Gartell ( Blitzer: B → F )",
			"| 【 THUNDER : MINIMAL DEBUFFS - AVOID LIGHT 】",
			"| 【 WIND : REMOVE BUFF (Protect,Phalanx) - AVOID DARKNESS 】",
			"| ◆◇ KITING STRATEGY ◇◆",
			"|    Impulse Drive | Judgment | Rudra's Storm",
			"|    Savage Blade | Cross Reaper | Tachi: Mumei",
		}
	},
	{
		type = "gboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ G ★ Boss: Triboulex ( Blitzer: C → G )",
			"| 【  】",
			"| ◆◇ FACE TANK STRATEGY ◇◆",
			"|    ",
			"|    ",
		}
	},
	{
		type = "hboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ H ★ Boss: Aita ( Blitzer: D → H )",
			"| 【  】",
			"| ◆◇ HYBRID STRATEGY ◇◆",
			"|    ",
			"|    ",
		}
	},
	{
		type = "aminonboss",
		messages = {
			"  ----------   ----------   ----------",
			"| ★ Aminon ★ Final Boss",
			"| 【  】",
			"|    ",
			"|    ",
		}
	},
}

-- ==[ Bosses ]================================================
local bosses = {
	a      = {label = 'A',      name = 'Ghadjot',   msg = 'aboss'},
	b      = {label = 'B',      name = 'Leshonn',   msg = 'bboss'},
	c      = {label = 'C',      name = 'Skmora',    msg = 'cboss'},
	d      = {label = 'D',      name = 'Degei',     msg = 'dboss'},
	e      = {label = 'E',      name = 'Dhartok',   msg = 'eboss'},
	f      = {label = 'F',      name = 'Gartell',   msg = 'fboss'},
	g      = {label = 'G',      name = 'Triboulex', msg = 'gboss'},
	h      = {label = 'H',      name = 'Aita',      msg = 'hboss'},
	aminon = {label = 'Aminon', name = 'Aminon',    msg = 'aminonboss'},
}

local name_to_key = {}
for key, boss in pairs(bosses) do
	name_to_key[boss.name] = key
end

-- ==[ Defeat Messages ]=======================================
local death_target = {[6] = true, [20] = true, [406] = true, [605] = true, [646] = true}
local death_actor  = {[113] = true}

-- ==[ State ]=================================================
local route     = nil
local done      = {}
local pos       = 0
local last_auto = 0
local last_next = 0
local guard     = 10
local tap_guard = 5
local queue     = {}
local sending   = false
local starts    = {}
local times     = {}
local run_start = 0
local run_end   = nil
local hud       = nil
local last_draw = 0
local update_hud

local function clear_progress()
	done      = {}
	pos       = 0
	starts    = {}
	times     = {}
	run_start = 0
	run_end   = nil
end

local function fmt_time(sec)
	sec = math.max(0, math.floor(sec))
	local h = math.floor(sec / 3600)
	local m = math.floor(sec % 3600 / 60)
	local s = sec % 60
	if h > 0 then
		return ('%d:%02d:%02d'):format(h, m, s)
	end
	return ('%d:%02d'):format(m, s)
end

-- ==[ Local Chat ]============================================
local function col(n, s)
	return string.char(31, n) .. s
end

local function log(msg)
	windower.add_to_chat(c_text, col(c_head, '[SA] ') .. col(c_text, msg))
end

local function dbg(msg)
	if debug_on then
		windower.add_to_chat(c_text, col(c_dbg, '[SA dbg] ') .. col(c_text, msg))
	end
end

-- ==[ Party Chat ]============================================
local function is_blank(line)
	return line == nil or (line:gsub('【%s*】', '')):match('^[|%s]*$') ~= nil
end

local function drain()
	local line = table.remove(queue, 1)
	if not line then
		sending = false
		return
	end
	windower.chat.input('/p ' .. line)
	coroutine.schedule(drain, line_delay)
end

local function party(lines)
	if lines == nil then return end

	for _, line in ipairs(lines) do
		if not is_blank(line) then
			queue[#queue + 1] = windower.to_shift_jis(line) or line
		end
	end

	if not sending and #queue > 0 then
		sending = true
		coroutine.schedule(drain, 0.1)
	end
end

-- ==[ Message Files ]=========================================
local msg_dir  = windower.addon_path .. 'messages/'
local messages = {}

local function read_lines(path)
	local f = io.open(path, 'r')
	if not f then
		return nil
	end
	local lines = {}
	for line in f:lines() do
		line = line:gsub('\r$', '')
		if #lines == 0 then
			line = line:gsub('^\239\187\191', '')
		end
		lines[#lines + 1] = line
	end
	f:close()
	return lines
end

local function write_lines(path, lines)
	local f = io.open(path, 'w')
	if not f then
		return false
	end
	f:write(table.concat(lines, '\n') .. '\n')
	f:close()
	return true
end

local function load_messages()
	if not windower.dir_exists(msg_dir) then
		windower.create_dir(msg_dir)
	end

	for _, entry in ipairs(default_messages) do
		local path = msg_dir .. entry.type .. '.txt'
		if not windower.file_exists(path) then
			write_lines(path, entry.messages)
		end
	end

	messages = {}
	local count = 0
	for _, file in ipairs(windower.get_dir(msg_dir) or {}) do
		local name = file:match('^(.+)%.[Tt][Xx][Tt]$')
		if name then
			messages[name:lower()] = read_lines(msg_dir .. file)
			count = count + 1
		end
	end
	return count
end

local function get_message(name)
	return name and messages[name:lower()]
end

-- ==[ Presets ]===============================================
local presets = {
	{name = 'dhabcgef', note = 'D H, then A B C, then G E F'},
	{name = 'dhcbagef', note = 'D H, then C B A, then G E F'},
	{name = 'dhabcgfe', note = 'D H, then A B C, then G F E'},
	{name = 'dabcgefh', note = 'BG-Wiki default, Soul Voice saved for H'},
	{name = 'hdcbaefg', note = 'H access farmed on the last run'},
	{name = 'dhcbaefg', note = 'Magic burst group, ordered by skillchain'},
	{name = 'abcdefgh', note = 'All 8 in letter order'},
	{name = 'ace',      note = 'Intermediate: A, C, then E'},
	{name = 'ac',       note = 'Beginner: A and C'},
}

-- ==[ Routes ]================================================
local builtin = {}
for _, p in ipairs(presets) do
	builtin[p.name] = p.route or p.name
end

local function get_route(name)
	return settings.routes[name] or builtin[name]
end

local function ensure_routes()
	if type(settings.routes) ~= 'table' then
		settings.routes = {}
	end
	if not get_route(settings.active) then
		settings.active = 'dhabcgef'
	end
end

local function parse_route(str)
	local steps, seen = {}, {}
	local text = (tostring(str):lower():gsub('aminon', '*'))
	local join = false

	for ch in text:gmatch('.') do
		if ch == '+' then
			join = true
		elseif not ch:match('[%s,%-]') then
			local key = ch == '*' and 'aminon' or ch
			if not bosses[key] then
				return nil, 'unknown boss "' .. ch .. '"'
			end
			if seen[key] then
				return nil, bosses[key].label .. ' is listed twice'
			end
			seen[key] = true
			if join and #steps > 0 then
				table.insert(steps[#steps], key)
			else
				steps[#steps + 1] = {key}
			end
			join = false
		end
	end

	if #steps == 0 then
		return nil, 'route is empty'
	end
	return steps
end

local function step_label(step)
	local parts = {}
	for _, key in ipairs(step) do
		parts[#parts + 1] = bosses[key].label
	end
	return table.concat(parts, '+')
end

local function route_string(steps)
	local parts = {}
	for _, step in ipairs(steps) do
		local keys = {}
		for _, key in ipairs(step) do
			keys[#keys + 1] = key == 'aminon' and ' aminon ' or key
		end
		parts[#parts + 1] = table.concat(keys, '+')
	end
	return (table.concat(parts, ''):gsub('%s+', ' '):gsub('^%s', ''):gsub('%s$', ''))
end

local function route_text(steps, arrow)
	local parts = {}
	for _, step in ipairs(steps) do
		parts[#parts + 1] = step_label(step)
	end
	return table.concat(parts, arrow or ' > ')
end

local function load_active()
	route = nil
	clear_progress()
	local str = get_route(settings.active)
	if str then
		route = parse_route(str)
	end
	if update_hud then
		update_hud()
	end
	return route ~= nil
end

-- ==[ Progress ]==============================================
local function step_done(step)
	for _, key in ipairs(step) do
		if not done[key] then
			return false
		end
	end
	return true
end

local function step_of(key)
	for i, step in ipairs(route) do
		for _, k in ipairs(step) do
			if k == key then
				return i
			end
		end
	end
end

local function next_after(i)
	for j = i + 1, #route do
		if not step_done(route[j]) then
			return j
		end
	end
end

local function finish_step(i)
	if route[i] and starts[i] and not times[i] then
		times[i] = os.time() - starts[i]
	end
end

local function step_names(step)
	local parts = {}
	for _, key in ipairs(step) do
		parts[#parts + 1] = bosses[key].name
	end
	return table.concat(parts, '/')
end

-- ==[ HUD ]===================================================
local function hud_col(r, g, b, s)
	return ('\\cs(%d,%d,%d)%s\\cr'):format(r, g, b, s)
end

update_hud = function()
	if not hud then
		return
	end
	if not settings.hud_on then
		hud:hide()
		return
	end

	local now = os.time()
	local lines = {}
	lines[#lines + 1] = hud_col(255, 200, 80, 'Sortie Announcer') ..
		('  [%s%s]'):format(settings.auto and 'auto' or 'macro', settings.compact and ', compact' or '')

	if not route then
		lines[#lines + 1] = 'No route  //sa preset'
	else
		lines[#lines + 1] = 'Route  ' .. settings.active

		local marks = {}
		for i, step in ipairs(route) do
			local label = step_label(step)
			if i == pos then
				marks[#marks + 1] = hud_col(100, 255, 100, label)
			elseif step_done(step) then
				marks[#marks + 1] = hud_col(110, 110, 110, label)
			else
				marks[#marks + 1] = label
			end
		end
		lines[#lines + 1] = table.concat(marks, ' ')

		if route[pos] then
			local boss_t = starts[pos] and ('  ' .. fmt_time(now - starts[pos])) or ''
			lines[#lines + 1] = 'Now    ' .. hud_col(100, 255, 100, step_label(route[pos]) .. '  ' .. step_names(route[pos])) .. boss_t
			local n = next_after(pos)
			lines[#lines + 1] = 'Next   ' .. (n and (step_label(route[n]) .. '  ' .. step_names(route[n])) or 'last boss')
		elseif pos > #route then
			lines[#lines + 1] = hud_col(255, 200, 80, 'Route complete')
		else
			lines[#lines + 1] = 'Not started  /console sa next'
		end

		if run_start > 0 then
			lines[#lines + 1] = 'Run    ' .. fmt_time((run_end or now) - run_start)
		end
	end

	hud:text(table.concat(lines, '\n'))
	hud:show()
end

local function build_hud()
	if hud then
		hud:destroy()
	end
	hud = texts.new('', settings.hud, settings)
	update_hud()
end

-- ==[ Party Layouts ]=========================================
local function compact_lines(boss)
	local short = get_message(boss.msg .. '_short')
	if short then
		return short
	end
	local parts = {}
	for _, line in ipairs(get_message(boss.msg) or {}) do
		if not is_blank(line) and line:find('%w') then
			parts[#parts + 1] = (line:gsub('^[|%s]+', ''))
			if #parts == 2 then
				break
			end
		end
	end
	if #parts == 0 then
		return {('★ %s ★ Boss: %s'):format(boss.label, boss.name)}
	end
	return {table.concat(parts, '  ')}
end

local function summary_lines()
	if not route then
		return nil
	end
	local parts = {}
	for i, step in ipairs(route) do
		if times[i] then
			parts[#parts + 1] = step_label(step) .. ' ' .. fmt_time(times[i])
		end
	end
	if #parts == 0 then
		return nil
	end
	local lines = {}
	for i = 1, #parts, 4 do
		lines[#lines + 1] = table.concat(parts, ' | ', i, math.min(i + 3, #parts))
	end
	lines[1] = 'Times: ' .. lines[1]
	if run_start > 0 then
		lines[#lines] = lines[#lines] .. ' | Total ' .. fmt_time((run_end or os.time()) - run_start)
	end
	return lines
end

local function post_step(i)
	local step = route[i]

	if #step == 1 then
		local boss = bosses[step[1]]
		if settings.compact then
			party(compact_lines(boss))
		else
			party(get_message(boss.msg) or {('★ %s ★ Boss: %s'):format(boss.label, boss.name)})
		end
		return
	end

	local parts = {}
	for _, key in ipairs(step) do
		parts[#parts + 1] = ('★ %s %s'):format(bosses[key].label, bosses[key].name)
	end
	party({
		('◆◇◆ Next Up: Split %s ◆◇◆'):format(step_label(step)),
		table.concat(parts, ' | '),
	})
end

local function post_route()
	party({('◆◇◆ Sortie Route: %s ◆◇◆'):format(route_text(route, ' → '))})
	party(get_message(settings.active))
end

local function post_complete()
	party({'◆◇◆ Sortie route complete! ◆◇◆'})
	party(summary_lines())
end

local function advance()
	local now = os.time()
	local n = next_after(pos)
	if n then
		pos = n
		starts[n] = starts[n] or now
		if run_start == 0 then
			run_start = now
		end
		post_step(n)
	else
		pos = #route + 1
		run_end = now
		post_complete()
	end
	update_hud()
end

-- ==[ Kill Tracking ]=========================================
local function on_kill(key, source)
	if not route or done[key] then
		return
	end

	local boss = bosses[key]
	local i = step_of(key)
	if not i then
		dbg(boss.name .. ' down, not in route')
		return
	end

	if not settings.auto and source ~= 'manual' then
		log(col(c_mob, boss.name) .. col(c_text, ' down  (macro mode: /console sa next)'))
		return
	end

	done[key] = true
	dbg(boss.name .. ' detected via ' .. source)

	if not step_done(route[i]) then
		local left = {}
		for _, k in ipairs(route[i]) do
			if not done[k] then
				left[#left + 1] = bosses[k].label
			end
		end
		log(col(c_mob, boss.name) .. col(c_text, ' down, waiting on ' .. table.concat(left, ' ')))
		update_hud()
		return
	end

	finish_step(i)

	if i < pos then
		log(col(c_mob, boss.name) .. col(c_text, ' down'))
		update_hud()
		return
	end
	pos = i

	if not settings.auto then
		log(col(c_mob, boss.name) .. col(c_text, ' marked done  (macro mode: /console sa next)'))
		update_hud()
		return
	end

	local n = next_after(pos)
	if n then
		log(col(c_mob, boss.name) .. col(c_text, (' down, posting %s in %ds'):format(step_label(route[n]), auto_delay)))
	else
		log(col(c_mob, boss.name) .. col(c_text, ' down, route complete'))
	end
	last_auto = os.time()
	coroutine.schedule(advance, auto_delay)
end

-- ==[ Commands ]==============================================
local function status()
	local name = settings.active ~= '' and settings.active or 'none'
	log('Mode: ' .. (settings.auto and 'auto' or 'macro') .. '  |  Calls: ' .. (settings.compact and 'compact' or 'full') ..
		'  |  HUD: ' .. (settings.hud_on and 'on' or 'off') .. '  |  Route: ' .. col(c_mob, name) ..
		col(c_text, route and ('  ' .. route_text(route)) or ''))

	if route then
		local list = {}
		for _, step in ipairs(route) do
			for _, key in ipairs(step) do
				list[#list + 1] = done[key] and col(c_done, bosses[key].label) or col(c_num, bosses[key].label)
			end
		end
		log('Progress: ' .. table.concat(list, col(c_text, ' ')))
		if route[pos] then
			log('Current: ' .. col(c_mob, step_label(route[pos])))
		end
	end
end

local function show_routes()
	local names = {}
	for name in pairs(settings.routes) do
		names[#names + 1] = name
	end
	if #names == 0 then
		log('No saved routes. //sa route add <name> <order>  |  //sa preset for presets')
		return
	end
	table.sort(names)
	log('Your routes  (* = active)')
	for _, name in ipairs(names) do
		local steps = parse_route(settings.routes[name])
		local mark = name == settings.active and col(c_num, '  * ') or '    '
		windower.add_to_chat(c_text, mark .. col(c_mob, name) .. col(c_zone, '  ' .. (steps and route_text(steps) or 'invalid')))
	end
end

local function route_add(name, args)
	if not name:match('^%a[%w_]*$') then
		log('Route name must start with a letter (letters, numbers, _ only)')
		return
	end

	local steps, err = parse_route(table.concat(args, ' '))
	if not steps then
		log('Bad route: ' .. err)
		return
	end

	settings.routes[name] = route_string(steps)
	config.save(settings)
	log('Saved route ' .. col(c_mob, name) .. col(c_text, ': ' .. route_text(steps)))

	if name == settings.active then
		load_active()
	end
end

local function route_del(name)
	if not settings.routes[name] then
		log(builtin[name] and (name .. ' is a preset and can\'t be deleted') or ('No route named ' .. name))
		return
	end
	settings.routes[name] = nil
	ensure_routes()
	config.save(settings)
	load_active()
	log('Deleted route ' .. name .. '  |  Active: ' .. settings.active)
end

local function route_use(name)
	if not get_route(name) then
		log('No route named ' .. name .. '. //sa route to list')
		return
	end
	settings.active = name
	config.save(settings)
	if load_active() then
		log('Active route: ' .. col(c_mob, name) .. col(c_text, '  ' .. route_text(route)))
	else
		log('Route ' .. name .. ' is invalid')
	end
end

local function show_presets()
	log('Presets  (* = active)  //sa preset <#|name>')
	for i, p in ipairs(presets) do
		local steps = parse_route(builtin[p.name])
		local mark = p.name == settings.active and col(c_num, ' *') or '  '
		windower.add_to_chat(c_text, mark .. col(c_num, ('%2d. '):format(i)) .. col(c_mob, ('%-9s'):format(p.name)) ..
			col(c_zone, ' ' .. route_text(steps)) .. col(c_done, '  ' .. p.note))
	end
end

local function use_preset(arg)
	local n = tonumber(arg)
	local p = n and presets[n]
	if not p then
		for _, q in ipairs(presets) do
			if q.name == arg then
				p = q
			end
		end
	end
	if not p then
		log('No preset ' .. arg .. '. //sa preset to list')
		return
	end
	route_use(p.name)
end

local function start()
	if not route then
		log('No active route. //sa route use <name>')
		return
	end
	clear_progress()
	post_route()
	advance()
end

local function post_next()
	if not route then
		log('No active route. //sa route use <name>')
		return
	end
	local now = os.time()
	if settings.auto and now - last_auto < guard then
		log('Already moved on after the kill. //sa now to repost')
		return
	end
	if now - last_next < tap_guard then
		log('Double press ignored. //sa back if you meant to skip')
		return
	end
	last_next = now
	if pos > #route then
		log('Route complete. //sa reset to start over')
		return
	end
	if pos == 0 then
		post_route()
	end
	if route[pos] then
		for _, key in ipairs(route[pos]) do
			done[key] = true
		end
		finish_step(pos)
	end
	advance()
end

local function post_now()
	if not route or not route[pos] then
		log('Nothing current. //sa start or //sa next')
		return
	end
	post_step(pos)
end

local function post_back()
	if not route or pos <= 1 then
		log('Already at the first boss')
		return
	end
	starts[pos] = nil
	run_end = nil
	pos = math.min(pos, #route + 1) - 1
	for _, key in ipairs(route[pos]) do
		done[key] = nil
	end
	times[pos] = nil
	post_step(pos)
	update_hud()
end

local function mark_done(args)
	if not route then
		log('No active route. //sa route use <name>')
		return
	end
	local steps, err = parse_route(table.concat(args, ' '))
	if not steps then
		log('Bad boss list: ' .. (err or ''))
		return
	end
	for _, step in ipairs(steps) do
		for _, key in ipairs(step) do
			on_kill(key, 'manual')
		end
	end
end

local function reset()
	clear_progress()
	update_hud()
	log('Progress cleared')
end

local function show_times(to_party)
	local lines = summary_lines()
	if not lines then
		log('No boss times yet')
		return
	end
	if to_party then
		party(lines)
		return
	end
	for _, line in ipairs(lines) do
		log(line)
	end
end

local function set_compact(on)
	settings.compact = on
	config.save(settings)
	log('Calls: ' .. (on and 'compact  (one line per boss, saved)' or 'full  (whole message block, saved)'))
	update_hud()
end

local function toggle_hud()
	settings.hud_on = not settings.hud_on
	config.save(settings)
	log('HUD: ' .. (settings.hud_on and 'on' or 'off') .. ' (saved, drag it to move)')
	update_hud()
end

local function stop()
	queue = {}
	log('Party queue cleared')
end

local function set_mode(auto)
	settings.auto = auto
	config.save(settings)
	if auto then
		log('Mode: auto  (posts the next boss on each kill, saved)')
	else
		log('Mode: macro  (only /console sa next posts, saved)')
	end
	update_hud()
end

local function reload_messages()
	log(('Loaded %d message files'):format(load_messages()))
end

local function show_messages()
	local boss_for = {}
	for _, boss in pairs(bosses) do
		boss_for[boss.msg] = boss.label
	end
	local names = {}
	for name in pairs(messages) do
		names[#names + 1] = name
	end
	table.sort(names)
	log('Messages  (Windower/addons/SortieAnnouncer/messages/)')
	for _, name in ipairs(names) do
		local tag = ''
		local base = name:match('^(.+)_short$')
		if boss_for[name] then
			tag = '  boss ' .. boss_for[name]
		elseif base and boss_for[base] then
			tag = '  compact call for boss ' .. boss_for[base]
		elseif get_route(name) then
			tag = '  posts when route ' .. name .. ' starts'
		end
		windower.add_to_chat(c_text, '    ' .. col(c_mob, name) .. col(c_done, tag))
	end
end

local function preview(name)
	local lines = get_message(name)
	if not lines then
		log('No message ' .. (name or '') .. '. //sa messages to list')
		return
	end
	log('Preview: ' .. name)
	for _, line in ipairs(lines) do
		if not is_blank(line) then
			windower.add_to_chat(c_text, windower.to_shift_jis(line) or line)
		end
	end
end

local function toggle_debug()
	debug_on = not debug_on
	log('Debug: ' .. (debug_on and 'on' or 'off'))
end

local function help()
	log(col(c_num, '//sa start')                  .. col(c_text, '            party: route + first boss'))
	log(col(c_num, '//sa next')                   .. col(c_text, '             current boss dead, post next (macro: /console sa next)'))
	log(col(c_num, '//sa now')                    .. col(c_text, '              repost current boss'))
	log(col(c_num, '//sa back')                   .. col(c_text, '             go back one boss and repost'))
	log(col(c_num, '//sa <a-h|aminon>')           .. col(c_text, '     party: that boss'))
	log(col(c_num, '//sa <message>')              .. col(c_text, '        party: any file in messages/ (reminders, geo7boss...)'))
	log(col(c_num, '//sa messages')               .. col(c_text, '         list message files'))
	log(col(c_num, '//sa preview <message>')      .. col(c_text, ' show a message in your log only'))
	log(col(c_num, '//sa reload')                 .. col(c_text, '           reload message files after editing'))
	log(col(c_num, '//sa done <bosses>')          .. col(c_text, '    mark killed by hand (ex: done a)'))
	log(col(c_num, '//sa preset')                 .. col(c_text, '           list presets'))
	log(col(c_num, '//sa preset <#|name>')        .. col(c_text, '  use preset (macro: /console sa preset 1)'))
	log(col(c_num, '//sa route')                  .. col(c_text, '            list your routes'))
	log(col(c_num, '//sa route add <name> <...>') .. col(c_text, ' ex: route add mine dhabcgef  (a+b = split)'))
	log(col(c_num, '//sa route use <name>')       .. col(c_text, ' set active route'))
	log(col(c_num, '//sa route del <name>')       .. col(c_text, ' delete route'))
	log(col(c_num, '//sa auto')                   .. col(c_text, '             mode: post next boss on each kill'))
	log(col(c_num, '//sa macro')                  .. col(c_text, '            mode: only your macro posts (default)'))
	log(col(c_num, '//sa compact')                .. col(c_text, '          one line per boss call'))
	log(col(c_num, '//sa full')                   .. col(c_text, '             full message block per boss call (default)'))
	log(col(c_num, '//sa hud')                    .. col(c_text, '              show / hide the on-screen box'))
	log(col(c_num, '//sa times')                  .. col(c_text, '            boss times in your log'))
	log(col(c_num, '//sa times party')            .. col(c_text, '      boss times to party'))
	log(col(c_num, '//sa status')                 .. col(c_text, '           mode, route, progress'))
	log(col(c_num, '//sa reset')                  .. col(c_text, '            clear progress and times'))
	log(col(c_num, '//sa stop')                   .. col(c_text, '             clear queued party lines'))
	log(col(c_num, '//sa debug')                  .. col(c_text, '            toggle detection output'))
end

-- ==[ Detection ]=============================================
local function clean(s)
	return (s:gsub('[\30\31\127].', ''):gsub('[^\32-\126]', ''))
end

local function is_chat(s)
	return s:find('^[%(%[<>]') ~= nil or s:find('^%S+ : ') ~= nil or s:find('^%S+%[.-%]: ') ~= nil
end

windower.register_event('incoming text', function(original)
	if not route then return end

	local s = clean(original)
	if is_chat(s) then return end

	for key, boss in pairs(bosses) do
		if s:find('defeats ' .. boss.name, 1, true)
		or s:find('defeats the ' .. boss.name, 1, true)
		or s:find(boss.name .. ' falls to the ground', 1, true) then
			on_kill(key, 'text')
		end
	end
end)

windower.register_event('action message', function(actor_id, target_id, actor_index, target_index, message_id)
	if not route then return end

	local id = (death_target[message_id] and target_id) or (death_actor[message_id] and actor_id)
	if not id then return end

	local mob = windower.ffxi.get_mob_by_id(id)
	local key = mob and name_to_key[mob.name]
	if key then
		on_kill(key, 'packet ' .. message_id)
	end
end)

-- ==[ Zone Reset ]============================================
local function is_sortie(id)
	local zone = id and res.zones[id]
	local name = zone and (zone.name or zone.en) or ''
	return name:find("^Outer Ra'Kaznar [%[%(]U") ~= nil, name
end

windower.register_event('zone change', function(new_id, old_id)
	local entering, name = is_sortie(new_id)
	dbg('Zone: ' .. name)
	if entering and not is_sortie(old_id) then
		clear_progress()
		update_hud()
		log('Entered Sortie, progress and times reset')
	end
end)

-- ==[ Load ]==================================================
windower.register_event('load', function()
	load_messages()
	ensure_routes()
	load_active()
	if windower.ffxi.get_info().logged_in then
		build_hud()
		status()
	end
end)

windower.register_event('login', function()
	settings = config.load(defaults)
	ensure_routes()
	load_active()
	build_hud()
	coroutine.schedule(status, 5)
end)

windower.register_event('logout', function()
	if hud then
		hud:hide()
	end
end)

windower.register_event('unload', function()
	config.save(settings)
end)

windower.register_event('prerender', function()
	if hud and settings.hud_on and run_start > 0 and not run_end then
		local now = os.time()
		if now ~= last_draw then
			last_draw = now
			update_hud()
		end
	end
end)

-- ==[ Command Router ]========================================
windower.register_event('addon command', function(cmd, ...)
	local args = {...}
	cmd = (cmd or 'help'):lower()
	dbg(col(c_num, '//sa ') .. col(c_text, cmd .. ' ' .. table.concat(args, ' ')))

	if cmd == 'route' then
		local sub  = (table.remove(args, 1) or ''):lower()
		local name = (table.remove(args, 1) or ''):lower()
		if sub == 'add' then
			route_add(name, args)
		elseif sub == 'del' then
			route_del(name)
		elseif sub == 'use' then
			route_use(name)
		else
			show_routes()
		end
	elseif cmd == 'preset' or cmd == 'presets' then
		if args[1] then
			use_preset(args[1]:lower())
		else
			show_presets()
		end
	elseif cmd == 'start' then
		start()
	elseif cmd == 'next' then
		post_next()
	elseif cmd == 'now' then
		post_now()
	elseif cmd == 'back' then
		post_back()
	elseif cmd == 'done' then
		mark_done(args)
	elseif cmd == 'auto' then
		set_mode(true)
	elseif cmd == 'macro' then
		set_mode(false)
	elseif cmd == 'status' then
		status()
	elseif cmd == 'reset' then
		reset()
	elseif cmd == 'stop' then
		stop()
	elseif cmd == 'debug' then
		toggle_debug()
	elseif cmd == 'help' then
		help()
	elseif cmd == 'compact' then
		set_compact(true)
	elseif cmd == 'full' then
		set_compact(false)
	elseif cmd == 'hud' then
		toggle_hud()
	elseif cmd == 'times' then
		show_times((args[1] or ''):lower() == 'party')
	elseif cmd == 'reload' then
		reload_messages()
	elseif cmd == 'messages' then
		show_messages()
	elseif cmd == 'preview' then
		preview(args[1] and args[1]:lower())
	elseif bosses[cmd] then
		party(get_message(bosses[cmd].msg) or {('★ %s ★ Boss: %s'):format(bosses[cmd].label, bosses[cmd].name)})
	else
		local lines = get_message(cmd)
		if lines then
			party(lines)
		else
			log(col(c_num, '//sa ') .. col(c_text, cmd) .. col(c_num, ' command not found!'))
		end
	end
end)
