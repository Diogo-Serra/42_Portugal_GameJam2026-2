extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var story_label: Label = $StoryLabel
@onready var skip_button: Button = $SkipButton

var slides := [
	{"image": preload("res://assets/Backgrounds/frame0000.png"), "text": "Five hundred years the forest drank the demon's wrath. \nThe gods called it peace. Ars called it waiting.", "auto_advance": 4.0},
	{"image": preload("res://assets/Backgrounds/frame0000.png"), "text": "The sacred chains have withered, the ancient seal has fallen. \nFrom the silent woods, Ars rises once more...\nand heaven shall remember fear.", "auto_advance": 4.0},
	{"image": preload("res://assets/Backgrounds/frame0000.png"), "text": "Those who buried darkness beneath holy roots believed time could erase hatred. \nThey were wrong. Vengeance has awakened.", "auto_advance": 0.0},
	]

var current_slide := 0
var is_typing := false
var typing_tween: Tween
var advance_timer: Timer

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)

	advance_timer = Timer.new()
	advance_timer.one_shot = true
	add_child(advance_timer)
	advance_timer.timeout.connect(next_slide)

	show_slide(0)

func show_slide(index: int) -> void:
	if index >= slides.size():
		end_cutscene()
		return

	current_slide = index
	advance_timer.stop()

	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		texture_rect.texture = slides[index]["image"]
		start_typewriter(slides[index]["text"])
	)
	tween.tween_property(texture_rect, "modulate:a", 1.0, 0.3)

func start_typewriter(full_text: String) -> void:
	story_label.text = ""
	is_typing = true

	if typing_tween:
		typing_tween.kill()

	typing_tween = create_tween()
	for i in range(full_text.length() + 1):
		typing_tween.tween_callback(func(): story_label.text = full_text.substr(0, i))
		typing_tween.tween_interval(0.03)

	typing_tween.tween_callback(_on_typing_finished)

func _on_typing_finished() -> void:
	is_typing = false
	var auto_delay = slides[current_slide]["auto_advance"]
	if auto_delay > 0.0:
		advance_timer.start(auto_delay)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_advance_input()
	elif event.is_action_pressed("ui_accept") and not event.is_echo():
		handle_advance_input()

func handle_advance_input() -> void:
	if is_typing:
		typing_tween.kill()
		story_label.text = slides[current_slide]["text"]
		_on_typing_finished()
	else:
		next_slide()

func next_slide() -> void:
	show_slide(current_slide + 1)

func _on_skip_pressed() -> void:
	end_cutscene()

func end_cutscene() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
