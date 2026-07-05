extends Node

## Handles collision shape swapping and z-sort depth for the Player's two forms.
## Attach as a child of the Player node. player.gd calls apply_form() on toggle.

# ---- Demon form collision (tweak in Inspector with collision debug on) ----
@export var demon_capsule_radius: float = 10.0
@export var demon_capsule_height: float = 50.0
@export var demon_capsule_offset: Vector2 = Vector2(4, 20)

@export var demon_circle_radius: float = 5.0
@export var demon_circle_offset: Vector2 = Vector2(-4, 14)

@export var demon_rect_size: Vector2 = Vector2(28, 8)
@export var demon_rect_offset: Vector2 = Vector2(4, 45)

# ---- Z-sort: distance from node origin down to the character feet ----
@export var basic_sort_offset: float = 28.0
@export var demon_sort_offset: float = 65.0

# ---- Internal ----
var _player: CharacterBody2D
var _collision: CollisionShape2D
var _collision_circle: CollisionShape2D
var _collision_rect: CollisionShape2D

var _current_sort_offset: float

var _basic_capsule_radius: float
var _basic_capsule_height: float
var _basic_capsule_offset: Vector2
var _basic_circle_radius: float
var _basic_circle_offset: Vector2
var _basic_rect_size: Vector2
var _basic_rect_offset: Vector2


func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	_collision        = _player.get_node_or_null("CollisionShape2D")
	_collision_circle = _player.get_node_or_null("CollisionShape2D3")
	_collision_rect   = _player.get_node_or_null("CollisionShape2D2")

	_player.z_as_relative = false
	_current_sort_offset = basic_sort_offset

	_save_basic_values()


func _physics_process(_delta: float) -> void:
	_player.z_index = int(_player.global_position.y + _current_sort_offset)


func apply_form(is_basic: bool) -> void:
	_apply_capsule(is_basic)
	_apply_circle(is_basic)
	_apply_rect(is_basic)
	_current_sort_offset = basic_sort_offset if is_basic else demon_sort_offset


# ---- Private ----

func _save_basic_values() -> void:
	if _collision and _collision.shape is CapsuleShape2D:
		var cap := _collision.shape as CapsuleShape2D
		_basic_capsule_radius = cap.radius
		_basic_capsule_height = cap.height
	_basic_capsule_offset = _collision.position if _collision else Vector2.ZERO

	if _collision_circle and _collision_circle.shape is CircleShape2D:
		_basic_circle_radius = (_collision_circle.shape as CircleShape2D).radius
	_basic_circle_offset = _collision_circle.position if _collision_circle else Vector2.ZERO

	if _collision_rect and _collision_rect.shape is RectangleShape2D:
		_basic_rect_size = (_collision_rect.shape as RectangleShape2D).size
	_basic_rect_offset = _collision_rect.position if _collision_rect else Vector2.ZERO


func _apply_capsule(is_basic: bool) -> void:
	if not (_collision and _collision.shape is CapsuleShape2D):
		return
	var cap := _collision.shape as CapsuleShape2D
	if is_basic:
		cap.radius = _basic_capsule_radius
		cap.height = _basic_capsule_height
		_collision.position = _basic_capsule_offset
	else:
		cap.radius = demon_capsule_radius
		cap.height = demon_capsule_height
		_collision.position = demon_capsule_offset


func _apply_circle(is_basic: bool) -> void:
	if not (_collision_circle and _collision_circle.shape is CircleShape2D):
		return
	var cir := _collision_circle.shape as CircleShape2D
	if is_basic:
		cir.radius = _basic_circle_radius
		_collision_circle.position = _basic_circle_offset
	else:
		cir.radius = demon_circle_radius
		_collision_circle.position = demon_circle_offset


func _apply_rect(is_basic: bool) -> void:
	if not (_collision_rect and _collision_rect.shape is RectangleShape2D):
		return
	var rec := _collision_rect.shape as RectangleShape2D
	if is_basic:
		rec.size = _basic_rect_size
		_collision_rect.position = _basic_rect_offset
	else:
		rec.size = demon_rect_size
		_collision_rect.position = demon_rect_offset
