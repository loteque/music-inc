extends Node

export (NodePath) var audio_node
export (NodePath) var count_node
export (NodePath) var board_node

onready var count: Node =  get_node(count_node)
onready var audio: Node = get_node(audio_node)
onready var board: Node = get_node(board_node)

var c
var a
var b

var count_menu_index: int = 0
var count_beat_sample: Array

func _ready():
	c = count.get_children()
	a = audio.get_children()
	b = board.get_children()

func _on_Button_pressed():
	if count_menu_index == c.size():
		count_menu_index = reset_index()
	get_beat_audio(count_menu_index).play()
	count_menu_index = update_index_by_1(count_menu_index)

func get_beat_audio(beat_index):
	var sample_name = c[beat_index].selection
	return audio.get_node(sample_name).get_child(0)

func update_index_by_1(i):
	return i + 1

func reset_index():
	return 0

func _on_Main_ready():
	var audio_samples = audio.get_children()
	var beats = board.get_node("Count").get_children()
	
	for beat in beats:
		for sample in audio_samples:
			beat.get_popup().add_item(sample.name)