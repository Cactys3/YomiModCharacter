extends PanelContainer

signal selected()

onready var lobby_name = $"%LobbyName"
onready var player_count = $"%PlayerCount"
onready var select_rect = $SelectRect
onready var hover_rect = $HoverRect
onready var game_version = $"%GameVersion"
onready var custom_characters_enabled = $"%CustomCharactersEnabled"

var lobby_id
var lobby_data

var mouse_entered = false
var mouse_clicked = false
var selected = false

func set_data(lobby_data):
	lobby_name.text = ProfanityFilter.filter(lobby_data.name)
	game_version.text = lobby_data.version
	custom_characters_enabled.text = lobby_data.charloader_enabled_text
	custom_characters_enabled.modulate = Color.green if lobby_data.charloader_enabled else Color.white
	player_count.text = str(lobby_data.player_count) + "/" + str(lobby_data.max_players)
	lobby_id = lobby_data.id
	self.lobby_data = lobby_data

func _ready():
	yield(get_tree(), "idle_frame")
	var rect = get_global_rect()
	var mouse_position = get_global_mouse_position()
	if rect.has_point(mouse_position):
		_on_LobbyEntry_mouse_entered()
		











func select():
	selected = true
	select_rect.show()
	emit_signal("selected")

func deselect():
	select_rect.hide()
	selected = false

func _on_LobbyEntry_mouse_entered():
	mouse_entered = true
	hover_rect.show()
	pass


func _on_LobbyEntry_mouse_exited():
	mouse_entered = false
	hover_rect.hide()
	pass


func _on_Button_pressed():
	select()
	pass
