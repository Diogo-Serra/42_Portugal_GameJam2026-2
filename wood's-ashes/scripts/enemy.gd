extends CharacterBody2D
class_name Enemy

@export var speed := 80.0
@export var max_health := 30
@export var knockback_force := 180.0
@export var hurt_time := 0.15

@export var attack_damage := 10
@export var attack_range := 40.0
@export var attack_cooldown := 4.0
@export var attack_impact_frame := 2

var health := 30
var player: Node2D
var hurt_timer := 0.0
var knockback_velocity := Vector2.ZERO

var attack_cooldown_timer := 0.0
var attack_has_hit := false
var rage_on_death := 5.0

enum EnemyState {
	NORMAL,
	ATTACKING,
	HURT,
	DEAD
}
var state: EnemyState = EnemyState.NORMAL

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")


func _ready():
	health = max_health
	add_to_group("enemies")
	z_as_relative = false
	if sprite != null:
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)
		if not sprite.frame_changed.is_connected(_on_sprite_frame_changed):
			sprite.frame_changed.connect(_on_sprite_frame_changed)
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")


func _physics_process(delta):
	z_index = int(global_position.y) + 45

	if state == EnemyState.DEAD:
		velocity = Vector2.ZERO
		return

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta

	if state == EnemyState.HURT:
		hurt_timer -= delta
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		move_and_slide()
		if hurt_timer <= 0:
			state = EnemyState.NORMAL
			play_animation("walk")
		return

	if state == EnemyState.ATTACKING:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	if distance_to_player <= attack_range:
		update_sprite_direction()
		if attack_cooldown_timer <= 0:
			attack()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
		return

	var direction := (player.global_position - global_position).normalized()
	velocity = direction * speed
	update_sprite_direction()
	play_animation("walk")
	move_and_slide()


func attack():
	state = EnemyState.ATTACKING
	velocity = Vector2.ZERO
	attack_cooldown_timer = attack_cooldown
	attack_has_hit = false

	if sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation("attack"):
		play_animation("attack")
	else:
		# No "attack" animation set up yet - still land the hit and recover shortly after
		try_hit_player()
		attack_has_hit = true
		await get_tree().create_timer(0.3).timeout
		if state == EnemyState.ATTACKING:
			state = EnemyState.NORMAL
			play_animation("walk")


func _on_sprite_frame_changed():
	if state != EnemyState.ATTACKING:
		return
	if sprite.animation != "attack":
		return
	if attack_has_hit:
		return
	if sprite.frame >= attack_impact_frame:
		attack_has_hit = true
		try_hit_player()


func try_hit_player():
	if player == null or not is_instance_valid(player):
		return
	if not player.has_method("take_damage"):
		return
	var distance_to_player := global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range:
		player.call("take_damage", attack_damage)


func take_damage(amount: int, attacker_position: Vector2):
	if state == EnemyState.DEAD:
		return
	health -= amount
	if health <= 0:
		die(attacker_position)
	else:
		get_hit(attacker_position)


func get_hit(attacker_position: Vector2):
	state = EnemyState.HURT
	hurt_timer = hurt_time
	var direction := (global_position - attacker_position).normalized()
	knockback_velocity = direction * knockback_force
	play_animation("hurt")


func die(attacker_position: Vector2):
	state = EnemyState.DEAD
	velocity = Vector2.ZERO
	var direction := (global_position - attacker_position).normalized()
	knockback_velocity = direction * knockback_force
	if collision != null:
		collision.set_deferred("disabled", true)
	if sprite != null and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
	else:
		queue_free()


func update_sprite_direction():
	if sprite == null or player == null:
		return
	if player.global_position.x > global_position.x:
		sprite.flip_h = false
	elif player.global_position.x < global_position.x:
		sprite.flip_h = true


func face_direction(dir: Vector2):
	if sprite == null:
		return
	if dir.x > 0:
		sprite.flip_h = false
	elif dir.x < 0:
		sprite.flip_h = true


func play_animation(animation_name: String):
	if sprite == null:
		return
	if sprite.sprite_frames == null:
		return
	if not sprite.sprite_frames.has_animation(animation_name):
		return
	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_animation_finished():
	if sprite == null:
		return
	if sprite.animation == "death":
		queue_free()
	elif sprite.animation == "attack":
		state = EnemyState.NORMAL
		play_animation("walk")
