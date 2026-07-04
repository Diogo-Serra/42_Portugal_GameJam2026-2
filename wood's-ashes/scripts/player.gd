extends CharacterBody2D

const SPEED = 120.0

func _physics_process(delta: float) -> void:
	# Get input as a 2D vector (left/right and up/down combined)
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction != Vector2.ZERO:
		velocity = input_direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
