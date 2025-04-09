extends Node

@onready var canvas_layer : CanvasLayer = $CanvasLayer
@onready var score_label : Label = $CanvasLayer/ScoreLabel

var word_label_container : Control  # Now properly defined (no @onready)
var word_label : Label

func _ready():
	# Setup Score Label
	score_label.text = "Puntaje: 0"

	# Create the WordLabelContainer (simple Control node for now)
	word_label_container = Control.new()
	word_label_container.set_size(Vector2(200, 50))
	word_label_container.position = Vector2(400, 300)
	canvas_layer.add_child(word_label_container)

	# Create and add the WordLabel inside the container
	word_label = Label.new()
	word_label.text = "..."
	word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	word_label_container.add_child(word_label)

	# Create Stop button
	var stop_button = Button.new()
	stop_button.text = "Parar"
	stop_button.position = Vector2(50, 150)
	canvas_layer.add_child(stop_button)
	stop_button.pressed.connect(_on_stop_button_pressed)

	# Create Restart button
	var restart_button = Button.new()
	restart_button.text = "Reiniciar"
	restart_button.position = Vector2(200, 150)
	canvas_layer.add_child(restart_button)
	restart_button.pressed.connect(_on_restart_button_pressed)

	# Create OK button
	var ok_button = Button.new()
	ok_button.text = "OK"
	ok_button.position = Vector2(350, 150)
	canvas_layer.add_child(ok_button)
	ok_button.pressed.connect(_on_ok_button_pressed)

	# Create Cancel button
	var cancel_button = Button.new()
	cancel_button.text = "Cancelar"
	cancel_button.position = Vector2(500, 150)
	canvas_layer.add_child(cancel_button)
	cancel_button.pressed.connect(_on_cancel_button_pressed)

func _on_stop_button_pressed():
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_ok_button_pressed():
	pass  # Optional future code

func _on_cancel_button_pressed():
	pass  # Optional future code
