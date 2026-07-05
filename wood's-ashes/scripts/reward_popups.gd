extends CanvasLayer

signal life_chosen
signal damage_chosen
signal rare_chosen

@onready var description_label: Label = $Panel/DescriptionLabel

func _ready() -> void:
	$Panel/LifeButton.pressed.connect(_on_life_pressed)
	$Panel/DamageButton.pressed.connect(_on_damage_pressed)
	$Panel/RareButton.pressed.connect(_on_rare_button_pressed)
	
	$Panel/LifeButton.mouse_entered.connect(_on_life_hover)
	$Panel/LifeButton.mouse_exited.connect(_on_hover_end)

	$Panel/DamageButton.mouse_entered.connect(_on_damage_hover)
	$Panel/DamageButton.mouse_exited.connect(_on_hover_end)
	
	$Panel/RareButton.mouse_entered.connect(_on_rare_button_hover)
	$Panel/RareButton.mouse_exited.connect(_on_hover_end)
	
	$Panel/RareButton.visible = false
	if randf() < 0.50:
		$Panel/RareButton.visible = true
	
	description_label.text = ""
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_life_hover() -> void:
	description_label.text = "Restores 20 HP instantly."

func _on_damage_hover() -> void:
	description_label.text = "Increases your damage by 5 permanently."

func _on_rare_button_hover() -> void:
	description_label.text = "A once in a lifetime blessing..."

func _on_hover_end() -> void:
	description_label.text = ""

func _on_life_pressed() -> void:
	life_chosen.emit()
	close_popup()

func _on_damage_pressed() -> void:
	damage_chosen.emit()
	close_popup()

func _on_rare_button_pressed() -> void:
	rare_chosen.emit()
	close_popup()

func close_popup() -> void:
	get_tree().paused = false
	queue_free()
