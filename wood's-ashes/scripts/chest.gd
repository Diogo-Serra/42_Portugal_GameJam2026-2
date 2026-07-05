extends StaticBody2D

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const RewardPopup = preload("res://scenes/reward_popups.tscn")

var player_in_range: bool = false
var is_open: bool = false

func _ready() -> void:
	prompt_label.visible = false
	sprite.frame = 0
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_open:
		player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_open and event.is_action_pressed("interact"):
		open_chest()

func open_chest() -> void:
	is_open = true
	prompt_label.visible = false
	sprite.stop()
	sprite.frame = 1
	var popup = RewardPopup.instantiate()
	get_tree().root.add_child(popup)
	popup.life_chosen.connect(_on_life_chosen)
	popup.damage_chosen.connect(_on_damage_chosen)

func _on_life_chosen() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.upgrade_max_health(20)  # heals + increases max HP by 20
	print("Player chose Life!")

func _on_damage_chosen() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.upgrade_attack_damage(5)  # increases attack damage by 5
	print("Player chose Damage!")
