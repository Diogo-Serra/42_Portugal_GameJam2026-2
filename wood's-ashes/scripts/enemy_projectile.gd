extends Area2D

@export var speed := 280.0
@export var damage := 10
@export var lifetime := 4.0

var direction := Vector2.ZERO


func _ready():
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	position += direction * speed * delta

	lifetime -= delta
	if lifetime <= 0:
		queue_free()


func setup(new_direction: Vector2, new_damage: int):
	direction = new_direction.normalized()
	damage = new_damage


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
