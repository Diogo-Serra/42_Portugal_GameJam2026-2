extends CharacterBody2D

# Animated Sprite child node
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Properties
@export var speed := 250.0
var face_direction := "Right"
var is_attacking := false


func _ready():
	add_to_group("player")
	sprite.stop()
	sprite.flip_h = false
	sprite.play("idle_right")

	# Connect signal in code
	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(_delta):

	# Attack input
	if Input.is_action_just_pressed("attack") and !is_attacking:
		attack()

	# Prevent movement while attacking
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Movement input
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = raw_input * speed

	# Update facing direction (based on strongest axis)
	if raw_input.length() > 0:
		if abs(raw_input.x) > abs(raw_input.y):
			face_direction = "Left" if raw_input.x < 0 else "Right"
		else:
			face_direction = "Up" if raw_input.y < 0 else "Down"

	# Movement animations
	if velocity.length() > 0:
		match face_direction:
			"Right":
				sprite.flip_h = false
				sprite.play("walk_right")

			"Left":
				sprite.flip_h = true
				sprite.play("walk_right")

			"Up":
				sprite.flip_h = false
				sprite.play("walk_up")

			"Down":
				sprite.flip_h = false
				sprite.play("walk_down")

	else:
		match face_direction:
			"Right":
				sprite.flip_h = false
				sprite.play("idle_right")

			"Left":
				sprite.flip_h = true
				sprite.play("idle_right")

			"Up":
				sprite.flip_h = false
				sprite.play("idle_up")

			"Down":
				sprite.flip_h = false
				sprite.play("idle_down")


	move_and_slide()


func attack():
	is_attacking = true

	match face_direction:
		"Right":
			sprite.flip_h = false
			sprite.play("attack_right")

		"Left":
			sprite.flip_h = true
			sprite.play("attack_right")

		"Up":
			sprite.flip_h = false
			sprite.play("attack_up")

		"Down":
			sprite.flip_h = false
			sprite.play("attack_down")


func _on_animation_finished():
	if sprite.animation.begins_with("attack"):
		is_attacking = false
