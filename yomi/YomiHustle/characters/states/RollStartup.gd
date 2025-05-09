extends CharacterState

class_name RollDodge

const GROUND_FRIC = "0.115"
const AIR_FRIC = "0.1"

const speed = "8.5"
const accel_speed = "0.7"
export  var tech = false

var force
var accel
var back = false


func _enter():
	host.on_roll_started()





	back = false
	host.used_air_dodge = true
	force = xy_to_dir(data.x, 0, speed, "1")
	accel = xy_to_dir(data.x, 0, accel_speed, "1")
	if "-" in force.x:
		if host.get_facing() == "Right":
			anim_name = "RollBackward"
			back = true
			force.x = fixed.mul(force.x, "0.3")
		else:
			anim_name = "RollForward"
	else:
		if host.get_facing() == "Left":
			anim_name = "RollBackward"
			back = true
			force.x = fixed.mul(force.x, "0.3")
		else:
			anim_name = "RollForward"
	if back:
		anim_length = 20
		iasa_at = 20
	else:
		anim_length = 19
		iasa_at = 19
	host.apply_force(force.x, str(0))
	host.start_throw_invulnerability()
	host.start_projectile_invulnerability()

func _frame_0():
	if tech:
		if not data.get("no_invuln"):
			host.start_invulnerability()
		host.colliding_with_opponent = false
	if not host.is_grounded():
		host.air_movements_left -= 1
		if host.air_movements_left < 0:
			host.air_movements_left = 0

func _frame_1():
	host.colliding_with_opponent = false

func _frame_2():
	if not data.get("no_invuln"):
		host.start_invulnerability()

func _frame_10():

		host.end_invulnerability()
		host.end_throw_invulnerability()
		host.end_projectile_invulnerability()

func _tick():
	custom_x_fric = GROUND_FRIC
	if not host.is_grounded():
			custom_x_fric = AIR_FRIC
	host.colliding_with_opponent = false
	if accel:
		host.apply_force(accel.x, str(0))




func is_usable():
	if not host.is_grounded():
		return .is_usable() and not host.used_air_dodge
	return .is_usable()
