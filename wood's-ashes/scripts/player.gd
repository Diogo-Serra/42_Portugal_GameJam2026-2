extends CharacterBody2D

signal died
signal health_changed(current_health, max_health)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

@export var speed := 250.0

@export var max_health := 100
@export var attack_damage := 10
@export var attack_size := Vector2(70.0, 35.0)
@export var attack_cooldown := 0.35

# Posição da hitbox em relação ao Player.
# X = lado do ataque.
# Y = mais baixo/mais alto.
# Em Godot 2D, Y positivo é para baixo.
@export var attack_offset := Vector2(45.0, 40.0)

# Frame da animação em que a arma realmente bate.
# A contagem começa em 0.
# Exemplo: frame 0, 1, 2, 3...
@export var attack_impact_frame := 3

var health: int
var last_horizontal_direction := 1
var attack_cooldown_timer := 0.0

var attack_has_hit := false
var hit_enemies_this_attack := []
const DeathScreen = preload("res://scenes/Dead.tscn")

enum PlayerState {
	NORMAL,
	ATTACKING,
	HURT,
	DEAD
}

var state: PlayerState = PlayerState.NORMAL


func _ready():
	add_to_group("player")
	randomize()
	health = max_health
	z_as_relative = false

	update_attack_hitbox_size()
	update_attack_hitbox_position()

	attack_area.monitoring = true

	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

	if not sprite.frame_changed.is_connected(_on_sprite_frame_changed):
		sprite.frame_changed.connect(_on_sprite_frame_changed)

	play_animation("idle")
	health_changed.emit(health, max_health)


func _physics_process(delta):
	z_index = int(global_position.y) + 45

	if state == PlayerState.DEAD:
		velocity = Vector2.ZERO
		return

	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	if Input.is_action_just_pressed("attack") and can_attack():
		attack()
		return

	if state == PlayerState.ATTACKING or state == PlayerState.HURT:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	handle_movement()


func handle_movement():
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_direction * speed

	if input_direction.x > 0:
		last_horizontal_direction = 1
	elif input_direction.x < 0:
		last_horizontal_direction = -1

	update_sprite_direction()
	update_attack_hitbox_position()

	if input_direction.length() > 0:
		play_animation("walk")
	else:
		play_animation("idle")

	move_and_slide()


func can_attack() -> bool:
	return state == PlayerState.NORMAL and attack_cooldown_timer <= 0


func attack():
	state = PlayerState.ATTACKING
	velocity = Vector2.ZERO
	attack_cooldown_timer = attack_cooldown

	attack_has_hit = false
	hit_enemies_this_attack.clear()

	update_sprite_direction()
	update_attack_hitbox_position()

	sprite.play("attack")
	
	print(max_health)
	print(attack_damage)

func _on_sprite_frame_changed():
	if state != PlayerState.ATTACKING:
		return

	if sprite.animation != "attack":
		return

	if attack_has_hit:
		return

	if sprite.frame >= attack_impact_frame:
		attack_has_hit = true
		damage_enemies_in_range()


func damage_enemies_in_range():
	var bodies := attack_area.get_overlapping_bodies()

	for body in bodies:
		try_hit_enemy(body)


func try_hit_enemy(body: Node):
	if body in hit_enemies_this_attack:
		return

	if not body.is_in_group("enemies"):
		return

	if not body.has_method("take_damage"):
		return

	hit_enemies_this_attack.append(body)
	body.call("take_damage", attack_damage, global_position)


func update_attack_hitbox_position():
	var side := 1

	if last_horizontal_direction < 0:
		side = -1

	attack_area.position = Vector2(
		abs(attack_offset.x) * side,
		attack_offset.y
	)


func update_attack_hitbox_size():
	if attack_shape == null:
		print("AttackArea/CollisionShape2D não encontrado")
		return

	if attack_shape.shape == null:
		attack_shape.shape = RectangleShape2D.new()

	if attack_shape.shape is RectangleShape2D:
		var rectangle := attack_shape.shape as RectangleShape2D
		rectangle.size = attack_size
	else:
		print("A shape do ataque não é RectangleShape2D")


func update_sprite_direction():
	# Mantém a correção que fizemos antes.
	sprite.flip_h = last_horizontal_direction > 0


func play_animation(animation_name: String):
	if sprite.sprite_frames == null:
		return

	if not sprite.sprite_frames.has_animation(animation_name):
		return

	if sprite.animation != animation_name:
		sprite.play(animation_name)


func take_damage(amount: int):
	if state == PlayerState.DEAD:
		return

	health -= amount
	health_changed.emit(health, max_health)

	if health <= 0:
		die()
	else:
		get_hit()


func get_hit():
	state = PlayerState.HURT
	velocity = Vector2.ZERO
	update_sprite_direction()
	sprite.play("hurt")


func die():
	state = PlayerState.DEAD
	velocity = Vector2.ZERO

	collision.set_deferred("disabled", true)

	update_sprite_direction()
	sprite.play("die")

	died.emit()
	_on_player_died()

func _on_player_died() -> void:
	get_tree().paused = true
	var death_screen = DeathScreen.instantiate()
	death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(death_screen)

func upgrade_max_health(amount: int):
	max_health += amount
	health += amount
	health_changed.emit(health, max_health)

func upgrade_attack_damage(amount: int):
	attack_damage += amount

func upgrade_attack_range(amount: float):
	attack_size.x += amount
	attack_size.y += amount * 0.5
	update_attack_hitbox_size()


func upgrade_speed(amount: float):
	speed += amount

func _on_animation_finished():
	if state == PlayerState.ATTACKING:
		state = PlayerState.NORMAL
		play_animation("idle")

	elif state == PlayerState.HURT:
		state = PlayerState.NORMAL
		play_animation("idle")

	elif state == PlayerState.DEAD:
		pass
