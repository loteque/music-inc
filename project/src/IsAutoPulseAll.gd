extends CheckBox

onready var main_timer: Node = get_node("/root/Main/MainTimer")
onready var score: Node = get_node("/root/Main/UI/ScoreContainer/Score")
onready var ui: Node = get_node("/root/Main/UI")

var cost: int = 5

func _ready():
	main_timer.connect("timeout", self, "_on_main_timer_timeout")

func _on_main_timer_timeout():
	if int(score.text) < cost:
		disabled = true
	else:
		disabled = false

func _on_IsAutoPulseAll_toggled(button_pressed:bool):
	if button_pressed:
		ui.emit_signal("auto_pulse_all_added", cost)
