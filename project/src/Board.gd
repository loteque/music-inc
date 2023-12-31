extends VBoxContainer

signal auto_pulse_removed

export (NodePath) var count_node
export (NodePath) var pulse_button_node
export (NodePath) var lane_score_button_node
export (NodePath) var is_auto_node

onready var count: Node =  get_node(count_node)
onready var pulse_button: Node = get_node(pulse_button_node)
onready var lane_score_button: Node = get_node(lane_score_button_node)
onready var is_auto: Node = get_node(is_auto_node)
onready var main_timer: Node = get_node("/root/Main/MainTimer")
onready var audio: Node = get_node("/root/Main/Audio")
onready var lane_manager: Node = get_node("/root/Main/UI/Tracker/LaneManager")
onready var ui: Node = get_node("/root/Main/UI")
onready var score: Node = get_node("/root/Main/UI/ScoreContainer/Score")

var beat_scene = preload("res://src/Beat.tscn")
var sample_data = preload("res://src/SampleData.tscn")
var number_of_beats: int = 4
var lane_score: int = 0
var beat_cost: int = 100
var auto_pulse_cost = 1000000
var c
var a
var b

var count_menu_index: int = 0

func _ready():
	c = count.get_children()
	a = audio.get_children()
	b = get_children()
	main_timer.connect("timeout", self, "_on_main_timer_timeout")
	populate_beats(beat_scene, count, number_of_beats)

func get_beat_audio(beat_index):
	c = count.get_children()
	var sample_name = c[beat_index].selection
	return audio.get_node(sample_name).get_child(0)

func get_beat_data(beat_index):
	var beat_data = count.get_child(beat_index).get_node("SampleData")
	return beat_data

func update_index_by_1(i):
	return i + 1

func reset_index():
	return 0

func populate_beats(beat_menu, beat_count, num_beats):
	var instance_tooltip = "right click to select sample"
	for i in num_beats:
		if !beat_count.get_child(i):
			var instance_name = "Beat" + str(i + 1)
			var default_sample = "Silence"
			var default_sample_value = 1
			#construct beat interface
			var beat_instance = beat_menu.instance()
			beat_instance.name = instance_name
			beat_instance.text = default_sample
			beat_instance.selection = default_sample
			beat_instance.set_tooltip(instance_tooltip)
			beat_instance.connect("about_to_show", self, "_on_Beat_about_to_show")

			#attach sample_data to beat interface
			var sample_data_instance = sample_data.instance()
			sample_data_instance.sample_name = default_sample
			sample_data_instance.sample_value = default_sample_value
			beat_instance.add_child(sample_data_instance)
			
			#attach beat interface
			beat_count.add_child(beat_instance)

func populate_samples(beat_menus, audio_samples):	
	for beat in beat_menus:
		var i: int = 0
		beat.get_popup().clear()
		for sample in audio_samples:
			if int(score.text) >= sample.sample_cost:
				beat.get_popup().add_item(sample.name)
				beat.get_popup().set_item_tooltip( i, sample.name + "\n Cost: " + str(sample.sample_cost) + "\n Value: " + str(sample.sample_value) + "\n Description: " + sample.description)
				i += 1

func reset_lane_score():
	lane_score = 0

func update_lane_score(new_lane_score):
	lane_score += new_lane_score
	lane_manager.emit_signal("lane_score_updated", lane_score)
	lane_score_button.text = "Lane Score: " + str(lane_score)
	pass

func _on_Beat_about_to_show():
	var samples = audio.get_children()
	var beats = count.get_children()
	populate_samples(beats, samples)

func play_beat():
	pulse_button.emit_signal("pressed")

func _on_Pulse_pressed():
	c = count.get_children()
	if count_menu_index == c.size():
		count_menu_index = reset_index()
	var beat_data = get_beat_data(count_menu_index)
	get_beat_audio(count_menu_index).play()
	update_lane_score(beat_data.sample_value)
	count_menu_index = update_index_by_1(count_menu_index)

func _on_pulse_all_pressed():
	pulse_button.emit_signal("pressed")

func _on_AddBeat_pressed():
	number_of_beats += 1
	populate_beats(beat_scene, count, number_of_beats)
	ui.emit_signal("beat_added", beat_cost)

func _on_LaneScore_pressed():
	ui.emit_signal("lane_score_pressed", lane_score)
	reset_lane_score()
	update_lane_score(0)

func _on_IsAuto_toggled(button_pressed:bool):
	if button_pressed:
		ui.emit_signal("auto_pulse_added", auto_pulse_cost)
	else:
		emit_signal("auto_pulse_removed")

func _on_main_timer_timeout():
	if is_auto.pressed:
		play_beat()
