extends DefaultFireball


const MOVE_T = "0.25"
const AIM_INCREASE = "0.01"
const FADE_IN_TIME = 6
const MAX_T = "0.70"
const MOVE_SPEED = 10
const ACCEL = 1

var move_velocity = 0

func _enter():
	host.sprite.modulate.a = 0

func _frame_0():
	host.set_pos(host.get_pos().x, 0)


func _tick():
	if current_tick < FADE_IN_TIME:
		host.sprite.modulate.a = current_tick / float(FADE_IN_TIME)
	else:
		move_velocity = Utils.approach(move_velocity, MOVE_SPEED * host.creator.loic_dir, ACCEL)
		host.sprite.modulate.a = 1.0

		if host.creator:
			host.move_directly(move_velocity, 0)


	var drain_ratio = fixed.sub("1.0", fixed.div(str(current_tick), str(host.aim_ticks)))
	host.creator.loic_meter = fixed.round(fixed.mul(str(Robot.LOIC_METER), drain_ratio))
	if current_tick > host.aim_ticks:
		return "Fire"


	if not host.beep.playing:
		host.play_sound("Beep")

func home():
	if host.creator and host.creator.opponent:
		var target = host.creator if host.self_ else host.creator.opponent
		var dir = host.get_object_dir(target)
		var pos = host.obj_local_center(target)


		var t = fixed.add(MOVE_T, fixed.mul(AIM_INCREASE, str(current_tick)))
		if fixed.gt(t, MAX_T):
			t = MAX_T
		host.t = t

		host.set_pos(fixed.round(fixed.lerp_string(str(host.get_pos().x), str(host.get_pos().x + pos.x), t)), 0)
