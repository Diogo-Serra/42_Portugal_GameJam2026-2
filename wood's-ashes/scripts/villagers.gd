extends Enemy

enum Behaviour { FIGHTER, COWARD, RANDOM }
enum AIState { WANDER, CHASE, ATTACK }

@export var behaviour := Behaviour.RANDOM
@export var detect_range := 70.0
@export var wander_radius := 100.0

var ai_state := AIState.WANDER
var attack_timer := 0.0
var wander_target := Vector2.ZERO

var player_ref: Node2D = null


func _ready():
	super()
	attack_range = 18.0
	attack_damage = 1
	attack_cooldown = 6.0
	rage_on_death = 0.5
	add_to_group("villagers")

	_pick_new_target()

	if behaviour == Behaviour.RANDOM:
		behaviour = [Behaviour.FIGHTER, Behaviour.COWARD].pick_random()


func get_player() -> Node2D:
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player") as Node2D
	return player_ref


func _physics_process(delta):
	super(delta)

	if state == EnemyState.DEAD:
		return

	var p: Node2D = get_player()
	if p == null:
		return

	attack_timer -= delta

	var dist: float = global_position.distance_to(p.global_position)

	match behaviour:
		Behaviour.FIGHTER:
			_fighter_ai(p, dist)
		Behaviour.COWARD:
			_coward_ai(p)


# ---------------- AI ----------------

func _fighter_ai(p: Node2D, dist: float):
	match ai_state:

		AIState.WANDER:
			if dist < detect_range:
				ai_state = AIState.CHASE
			else:
				_wander()

		AIState.CHASE:
			if dist <= attack_range:
				ai_state = AIState.ATTACK
			else:
				_chase(p)

		AIState.ATTACK:
			if dist > attack_range:
				ai_state = AIState.CHASE
			else:
				_attack(p)


func _coward_ai(p: Node2D):
	var dir: Vector2 = (global_position - p.global_position).normalized()
	velocity = dir * speed
	face_direction(dir)
	play_animation("walk")


func _wander():
	if global_position.distance_to(wander_target) < 10:
		_pick_new_target()

	var dir: Vector2 = (wander_target - global_position).normalized()
	velocity = dir * speed * 0.5
	face_direction(dir)
	play_animation("walk")


func _chase(p: Node2D):
	var dir: Vector2 = (p.global_position - global_position).normalized()
	velocity = dir * speed
	face_direction(dir)
	play_animation("walk")


func _attack(p: Node2D):
	velocity = Vector2.ZERO
	play_animation("attack")

	if attack_timer > 0:
		return

	attack_timer = attack_cooldown

	if global_position.distance_to(p.global_position) <= attack_range:
		p.call_deferred("take_damage", attack_damage, global_position)


func _pick_new_target():
	wander_target = global_position + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
