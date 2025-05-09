extends "res://ui/SteamLobby/UiSteamLobbyOld.gd"

onready var loading_mods_rect = $"%LoadingModsRect"
onready var loading_lobby_rect = $"%LoadingLobbyRect"

var _Global = Network
var errorMsg = Label.new()

func _ready():
	add_child(errorMsg)
	errorMsg.set_position(Vector2(0, 345))
	errorMsg.text = ""
	_Global.steam_errorMsg = ""

func _process(delta):
	if not is_visible_in_tree():
		return

	errorMsg.text = _Global.steam_errorMsg

	var css = _Global.css_instance
	if css != null:
		for game in $"%MatchList".get_children():
			
			game.get_node("%P1Character").text = css.getCharName(game.p1.character)
			game.get_node("%P2Character").text = css.getCharName(game.p2.character)
			var cNames = css.name_to_index.keys()

			game.get_node("%SpectateButton").disabled = false
			
			if ( not (game.p1.character in cNames) and css.isCustomChar(game.p1.character)) or ( not (game.p2.character in cNames) and css.isCustomChar(game.p2.character)):
				game.get_node("%SpectateButton").disabled = true
	loading_mods_rect.visible = not Global.mods_loaded and not loading_lobby_rect.visible
