extends Control

class_name ButtonCategoryContainer

signal prediction_selected()

const BOX_SIZE = 52
const DEFAULT_HEIGHT = 60

onready var action_data_container = $"%ActionDataContainer"
onready var action_data_panel_container = $"%ActionDataPanelContainer"
onready var button_container = $"%ButtonContainer"
onready var initiative_label = $"%InitiativeLabel"
onready var guard_break_label = $"%GuardBreakLabel"

var label_text = ""
var selected_button_text = ""
var active_button = null

var mouse_over = false
var can_update = true

var game = null
var player_id = null

var category_int = - 1
var shown_label_index = 0
var shown_labels = []

var prediction_type = null
var visibility_update = false
var fighter: Fighter = null

func init(name):
	label_text = name
	$"%Label".text = label_text







func _ready():
	connect("visibility_changed", self, "_on_visibility_changed")

func _on_visibility_changed():
	if visible and not visibility_update:
		$"%ScrollContainer".rect_clip_content = true
		visibility_update = true
		pass

func any_buttons_visible():
	for button in $"%ButtonContainer".get_children():
		if button.visible:
			return true
	return false

func get_num_available_moves():
	var count = 0
	for button in $"%ButtonContainer".get_children():
		if button.visible:
			count += 1
	return count

func update_mouse_over():
		$"%ScrollContainer".rect_clip_content = true
		$"%ScrollContainer".rect_min_size.y = BOX_SIZE
		rect_size.y = DEFAULT_HEIGHT
		call_deferred("set_pos_y", 0)
		mouse_over = false
		can_update = false

		shown_labels = []
		$UpdateTimer.start()
		guard_break_label.hide()
		initiative_label.hide()
		

func update_mouse_elsewhere():
		$"%ScrollContainer".rect_clip_content = false
		$"%ScrollContainer".rect_min_size.y = $"%ButtonContainer".rect_size.y

		rect_size.y = 1000
		mouse_over = true
		can_update = false
		$UpdateTimer.start()

		call_deferred("set_pos_y", - $"%ScrollContainer".rect_min_size.y + BOX_SIZE)
			
func _process(_delta):







	if not mouse_over and can_update and Utils.is_mouse_in_control(self):
		update_mouse_elsewhere()
		
	elif mouse_over and can_update and not Utils.is_mouse_in_control(self):
		update_mouse_over()

	call_deferred("set_pos_y", - $"%ScrollContainer".rect_min_size.y + BOX_SIZE)
	$"%TooManyMoves".visible = get_num_available_moves() > 9
	if mouse_over:
		$"%TooManyMoves".visible = false
	set_deferred("visibility_update", false)
	
	guard_break_label.hide()
	initiative_label.hide()
	if shown_labels and (mouse_over):
		shown_labels[shown_label_index % len(shown_labels)].show()

func set_pos_y(y):
	rect_position.y = y









func enable_predict_button():
	$"%PredictButton".show()


func disable_predict_button():

	$"%PredictButton".hide()

func add_button(button):
	$"%ButtonContainer".add_child(button)
	button.connect("mouse_entered", self, "on_button_mouse_entered", [button])
	button.connect("mouse_exited", self, "on_button_mouse_exited")


func get_prediction():
	return $"%PredictButton".pressed and $"%PredictButton".visible

func reset_prediction():
	$"%PredictButton".set_pressed_no_signal(false)

func refresh():
	if get_prediction():
		$"%Label".text = label_text
		$"%Label".modulate = Color.white
		$"%Label".modulate.a = 1.0
		return
	guard_break_label.hide()
	initiative_label.hide()
	var initiative = fighter.check_initiative()
	for button in $"%ButtonContainer".get_children():
		if button.is_pressed():
			on_button_mouse_entered(button)
			$"%Label".modulate = Color.cyan
			active_button = button
			selected_button_text = button.action_title
			update_frame_display(button)
			update_mouse_elsewhere()
			return
	$"%Label".text = label_text
	$"%Label".modulate = Color.white
	$"%Label".modulate.a = 0.25
	$"%FrameLabel".text = ""
	
func update_labels(button):
	guard_break_label.hide()
	initiative_label.hide()
	shown_labels = []
	if button:
		if button.get("is_guard_break"):
			shown_labels.append(guard_break_label)
		if button.get("has_initiative_effect"):
			shown_labels.append(initiative_label)
	

func update_frame_display(button):
	$"%FrameLabel".text = ""
	guard_break_label.hide()
	if button and button.get("earliest_hitbox") and button.earliest_hitbox > 0:
		$"%FrameLabel".text = "[~%sf]" % button.earliest_hitbox


	update_labels(button)
	pass

func on_button_mouse_entered(button):
	if get_prediction():
		return
	_on_ButtonContainer_mouse_entered()
	$"%Label".text = button.action_title


	update_frame_display(button)
	$"%Label".modulate = Color.green

func on_button_mouse_exited():
	shown_labels = []
	refresh()


func show_data_container():
	$"%ActionDataPanelContainer".show()



	
func hide_data_container():
	$"%ActionDataPanelContainer".hide()
















func _on_ButtonContainer_mouse_entered():
	


	pass

func _on_ButtonContainer_mouse_exited():


	pass


func _on_PredictButton_mouse_entered():
	$"%PredictLabel".show()
	$"%PredictLabel".text = "P" + str((player_id % 2) + 1) + " Prediction"
	pass


func _on_PredictButton_mouse_exited():
	$"%PredictLabel".hide()
	pass


func _on_PredictButton_pressed():
	refresh()
	emit_signal("prediction_selected")
	pass


func _on_UpdateTimer_timeout():
	can_update = true
	pass

func _on_CycleTimer_timeout():
	shown_label_index += 1

