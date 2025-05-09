extends Node

signal nag_window()

var VERSION = "1.9.20-steam"
const RESOLUTION = Vector2(640, 360)

var audio_player
var music_enabled = true
var freeze_ghost_prediction = true
var freeze_ghost_sound = true
var ghost_afterimages = true
var fullscreen = false
var show_hitboxes = false
var show_extra_info = false
var light_mode = false
var frame_advance = false
var show_playback_controls = false
var show_projectile_owners = true
var playback_speed_mod = 1
var default_dojo = 0
var current_game = null
var css_open = false
var has_supporter_pack_file = false
var enable_custom_colors = true
var enable_custom_particles = true
var enable_custom_hit_sparks = true
var enable_emotes = true
var enable_timer_sound = true
var steam_demo_version = false
var show_last_move_indicators = true
var speed_lines_enabled = true
var replay_extra_freeze_frames = true
var seen_custom_character_nag = false
var forfeit_buttons_enabled = false
var auto_fc = true
var ghost_speed = 2

var winws_detected = false

var mods_loaded = false
var loading_character = ""

var mouse_world_position = Vector2()
var rng = BetterRng.new()

var name_paths = {
	"Ninja": "res://characters/stickman/NinjaGuy.tscn", 
	"Cowboy": "res://characters/swordandgun/SwordGuy.tscn", 
	"Wizard": "res://characters/wizard/Wizard.tscn", 
	"Robot": "res://characters/robo/Robot.tscn", 
	"Mutant": "res://characters/mutant/Mutant.tscn", 
	"Katarina": "res://_Katarina/characters/Katarina/Katarina.tscn"
}

var songs = {
	"bg1": preload("res://sound/music/bg1.mp3")
}

var character_select_node = null

var characters_cache = {}

func get_cached_character(name):
	return characters_cache[name]

func full_version():
	return ( not steam_demo_version) and SteamHustle.STARTED

func world_to_screen(x, y) -> Vector2:
	if not is_instance_valid(current_game):
		return Vector2()
	return Vector2()

func screen_to_world(xy: Vector2):
	if not is_instance_valid(current_game):
		return xy
	return xy - RESOLUTION / 2 + current_game.camera.global_position

func screen_to_world_int(xy: Vector2):
	return {
		"x": int(xy.x), 
		"y": int(xy.y)
	}

func winws_check():
	if _is_winws_active():
		winws_active_message()
		winws_detected = true
	return winws_detected

func _enter_tree():
	if _is_winws_active():
		winws_active_message()
		winws_detected = true
	var invalid_characters = []
	for char_name in name_paths:
		var character = load(name_paths[char_name])
		if not character:
			invalid_characters.append(char_name)
			continue
		characters_cache[char_name] = character
	for character in invalid_characters:
		name_paths.erase(character)

	steam_demo_version = "steam" in VERSION and "beta" in VERSION
	audio_player = AudioStreamPlayer.new()
	call_deferred("add_child", audio_player)
	audio_player.bus = "Music"
	
	var data = get_player_data()
	for key in data.options:
		set(key, data.options[key])





	randomize()
	rng.randomize()
	set_music_enabled(music_enabled)
	set_fullscreen(fullscreen)





func get_ghost_speed_modifier():
	if ghost_speed == 1:
		return 0.25
	if ghost_speed > 1:
		return float(ghost_speed - 1)

func _ready():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if randi() % 50 == 0 and not SteamHustle.STARTED:
		emit_signal("nag_window")

func winws_active_message():
		OS.alert(\
\
\
\
\
\
\
\
		"[EN]\nThe \"winws\" process has been detected running on your machine.\nThis process and several pieces of software using it (such as \"zapret\" and its variations) are known to crash Steam lobbies and cause major interruptions in online play.\nUntil a proper fix is found, please refrain from joining multiplayer lobbies with any software using \"winws\" while it is running. Thank you.\n\n[RU]\nНа вашем компьютере обнаружен запущенный процесс \"winws\".\nИзвестно, что этот процесс и несколько программ, использующих его (например, \"zapret\" и его вариации), приводят к сбоям в работе лобби Steam и серьезным перебоям в сетевой игре.\nПока не будет найдено надлежащее исправление, пожалуйста, воздержитесь от присоединения к многопользовательским лобби с любым программным обеспечением, использующим \"winws\", пока оно запущено. Спасибо.", "Winws detected")

func _is_winws_active() -> bool:
	var winws_active = false
	if OS.get_name() == "Windows":
		var output = []
		
		OS.execute("powershell.exe", ["/C", "get-process winws | measure-object -line | select Lines -expandproperty Lines"], true, output)
		var result = output[0].to_int()
		winws_active = result > 0
		print("Number of winws processes: " + str(result))
	return winws_active

func set_music_enabled(on):
	music_enabled = on
	if on:
		play_random_song()
	else:
		audio_player.stop()

func play_random_song():
	play_song(rng.choose(songs.keys()))

func has_supporter_pack():
	return true

func set_playback_controls(on):
	show_playback_controls = on
	save_options()
	
func set_fullscreen(on):
	fullscreen = on
	if fullscreen:
		OS.window_fullscreen = true
		OS.window_borderless = true
	else:
		OS.window_fullscreen = false
		OS.window_borderless = false
	save_options()

func set_hitboxes(on):
	show_hitboxes = on
	save_options()

func play_song(song_name):
	audio_player.stream = songs[song_name]
	audio_player.play()

func add_dir_contents(dir: Directory, files: Array, directories: Array, recursive: bool = true, extension: String = "", full_path = true):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir().plus_file(file_name) if full_path else file_name
		
		if dir.current_is_dir():
			if recursive:

				var subDir = Directory.new()
				subDir.open(path)
				subDir.list_dir_begin(true, false)
				directories.append(path)
				add_dir_contents(subDir, files, directories)
		else:

			if extension == "" or path.ends_with(extension):
				files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()

func save_username(username: String):
	save_player_data({"username": username})

func save_option(value, option):
	set(option, value)
	save_options()

func set_light_mode(on):
	light_mode = on
	save_options()

func save_options():
	save_player_data({
		"options": {
			"music_enabled": music_enabled, 
			"freeze_ghost_prediction": freeze_ghost_prediction, 
			"freeze_ghost_sound": freeze_ghost_sound, 
			"ghost_afterimages": ghost_afterimages, 
			"ghost_speed": ghost_speed, 
			"fullscreen": fullscreen, 
			"show_hitboxes": show_hitboxes, 
			"show_last_move_indicators": show_last_move_indicators, 
			"show_playback_controls": show_playback_controls, 
			"show_projectile_owners": show_projectile_owners, 
			"enable_timer_sound": enable_timer_sound, 
			"default_dojo": 0, 
			"show_extra_info": show_extra_info, 

			"enable_emotes": enable_emotes, 
			"enable_custom_colors": enable_custom_colors, 
			"enable_custom_particles": enable_custom_particles, 
			"enable_custom_hit_sparks": enable_custom_hit_sparks, 
			"speed_lines_enabled": speed_lines_enabled, 
			"auto_fc": auto_fc, 
			"replay_extra_freeze_frames": replay_extra_freeze_frames, 
			"seen_custom_character_nag": seen_custom_character_nag, 

		}
	})

func get_default_player_data():
	return {
		"username": "", 
		"last_style": "", 
		"options": {
			"music_enabled": true, 
			"freeze_ghost_prediction": true, 
			"freeze_ghost_sound": true, 
			"ghost_afterimages": true, 
			"fullscreen": false, 
			"ghost_speed": 2, 
			"show_hitboxes": false, 
			"show_last_move_indicators": true, 
			"show_playback_controls": false, 
			"default_dojo": 0, 
			"enable_timer_sound": true, 
			"enable_emotes": true, 
			"enable_custom_colors": true, 
			"enable_custom_particles": true, 
			"enable_custom_hit_sparks": true, 
			"show_projectile_owners": true, 
			"speed_lines_enabled": true, 
			"auto_fc": true, 
			"show_extra_info": false, 
			"replay_extra_freeze_frames": true, 
			"seen_custom_character_nag": false, 

		}
	}

func get_player_data():
	var file = File.new()
	var data
	if not file.file_exists("user://playerdata.json"):
		data = get_default_player_data()
		save_player_data(data)
	file.open("user://playerdata.json", File.READ)
	data = parse_json(file.get_as_text())
	var default_data = get_default_player_data()
	if not (data is Dictionary):
		save_player_data(get_default_player_data())
		file.close()
		return get_default_player_data()
	for key in default_data:
		if not (key in data):
			data[key] = default_data[key]
	file.close()
	return data

func save_player_data(data: Dictionary):
	var file = File.new()
	var existing_data
	if not file.file_exists("user://playerdata.json"):
		existing_data = get_default_player_data()
	else:
		file.open("user://playerdata.json", File.READ)
		var string = file.get_as_text()
		existing_data = parse_json(string)
		if not (existing_data is Dictionary):
			var dir = Directory.new()
			dir.open("user://")
			dir.remove("user://playerdata.json")
			existing_data = get_default_player_data()

	for key in data:
		existing_data[key] = data[key]
	file.open("user://playerdata.json", File.WRITE)
	file.store_string(JSON.print(existing_data, "  "))
	file.close()
	return

func reload():
	if character_select_node:
		character_select_node.get_parent().remove_child(character_select_node)
	get_tree().reload_current_scene()
