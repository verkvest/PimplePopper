extends Node
var yodo1mas
@onready var _animation = $AnimationPlayer
@onready var _finish_popup = $finish_game_popup

var debug_out: Label = Label.new()
# shows what tools can be used with each body part.
@export var tools_per_type: Dictionary

@export var hint_hided: bool = true
@export var _buttons: ButtonGroup
var _hints: Array


# tracks the current gameplay time, while this scene is active it will count up until the levels finished
# this is used for the Quick Popper and Slow Popper GPlay Achievements
var game_time: float
var is_game_running = true



# Called when the node enters the scene tree for the first time.
func _ready():
	yodo1mas = get_node_or_null("Yodo1Mas")
	if yodo1mas == null:
		yodo1mas = get_node_or_null("/root/Yodo")
	var nodes = get_tree().get_nodes_in_group("bodypart")
	for bp in nodes:
		bp.connect("bodypart_cleaned", Callable(self, "_on_bodypart_cleaned"))
	_animation.play("fade_out")
	_hints = get_tree().get_nodes_in_group("hint")
	hide_hints(hint_hided)
	if has_node("UI"):
		Mobile.fit($UI)
		_add_touch_hint()
#	yield(get_tree(), "idle_frame")
	_disable_buttons(true)
	
	for b in _buttons.get_buttons():
		if b.get_parent()!=$UI/scroll/tools:
			continue
		b.visible = tools_per_type[Global.type].has(b.name)
	
	#Yodo.load_interstitial_ads()


func _physics_process(delta):
	if is_game_running:
		game_time += delta


func hide_hints(hided: bool) -> void:
	for h in _hints:
		h.visible = not hided

func _on_bodypart_cleaned() -> void:
	is_game_running = false
	
	# sets the level as COMPLETED or is finished by the player!
	Global.player_data['levels_completion'][Global.type][Global.bodypart] = true
	
	# checks if all bodyparts in this type are completed
	var is_all_completed = true
	
	var names = {
		'pimple': 'CgkI5ILm9-4PEAIQAA',
		'blackhead': 'CgkI5ILm9-4PEAIQAQ',
		'cyst': 'CgkI5ILm9-4PEAIQAg',
		'lipoma': 'CgkI5ILm9-4PEAIQAw',
	}
	
	for body_part in Global.player_data['levels_completion'][Global.type]:
		if Global.player_data['levels_completion'][Global.type][body_part] == false:
			is_all_completed = false
			break
	
	if is_all_completed:
		_unlock('%s' % names[Global.type])
	
	# checks for the time achievements -- !!
	if game_time < 30.0:
		_unlock('CgkI5ILm9-4PEAIQBA')
	if game_time > 180.0:
		_unlock('CgkI5ILm9-4PEAIQBQ')
	
	#####################################################
	
	_submit_score('CgkI5ILm9-4PEAIQCQ', 150)
	
	_finish_popup.start()


func _on_hand_pressed():
	$tools.enable_hand()


func _on_handkerchief_pressed():
	$tools.enable_handkerchief()


func _on_timeout() -> void:
	get_tree().change_scene_to_file("res://menu/new_main_screen.tscn")


func _on_vapor_pressed():
	$tools.enable_vapor()


func _on_comedone_extraction_tool_pressed():
	$tools.enable_comedone_extraction_tool()


func _on_needle_pressed():
	$tools.enable_needle()


func _on_anesthetic_pressed():
	$tools.enable_anesthetic()


func _on_suture_pressed():
	$tools.enable_suture()


func _on_cutter_pressed():
	$tools.enable_cutter()


func _disable_buttons(b: bool) -> void:
	for bt in _buttons.get_buttons():
		bt.disabled = b


func _on_back_pressed():
	_disable_buttons(true)
	_animation.play("fade_in")


func _on_animation_finished(anim: String) -> void:
	if anim == "fade_in":
		var error: int = get_tree().change_scene_to_file("res://menu/new_main_screen.tscn")
		if error != OK:
			print_debug("Error loading main screen. Code: ", error)
	elif anim == "fade_out":
		_disable_buttons(false)


func _on_hint_pressed():
	hint_hided = not hint_hided
	yodo1mas.show_interstitial_ad()
	hide_hints(hint_hided)


func _on_anim_finished(finish_type):
	if finish_type == _finish_popup.finish_type.WIN:
		if yodo1mas and yodo1mas.has_method("is_interstitial_ad_loaded") and yodo1mas.is_interstitial_ad_loaded():
			yodo1mas.show_interstitial_ad()
			await yodo1mas.interstitial_ad_closed
		get_tree().change_scene_to_file("res://menu/new_main_screen.tscn")


func _add_touch_hint() -> void:
	var label := Label.new()
	label.name = "TouchHint"
	label.text = "Pinch with two fingers, or press and hold with one finger."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 6)
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_left = 16
	label.offset_top = 8
	label.offset_right = -16
	label.offset_bottom = 52
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UI.add_child(label)


func _unlock(achievement_id: String) -> void:
	if ManagerPlayGames.playgames:
		ManagerPlayGames.playgames.achievementsUnlock(achievement_id, true)


func _submit_score(board_id: String, score: int) -> void:
	if ManagerPlayGames.playgames:
		ManagerPlayGames.playgames.leaderboardsSubmitScore(board_id, score)

func _input(event):
	if event is InputEventScreenTouch:
		print ("_input game")

func _on_scroll_gui_input(event):
	if event is InputEventScreenTouch:
		print ("_gui_event scroll...")
	pass # Replace with function body.
# callbacks	from signals

func _on_Yodo1Mas_banner_ad_loaded():
	debug_out.text = debug_out.text + "Banner loaded\n"
	
func _on_Yodo1Mas_banner_failed_ad_loaded():
	debug_out.text = debug_out.text + "Banner not loaded\n"
func _on_Yodo1Mas_banner_ad_opened():
	#add_coins(5)
	debug_out.text = debug_out.text + "Banner opened\n"

func _on_Yodo1Mas_banner_ad_failed_opened():
	#add_coins(5)
	debug_out.text = debug_out.text + "Banner not opened\n"

func _on_Yodo1Mas_banner_ad_closed():
	debug_out.text = debug_out.text + "Banner closed\n"




func _on_Yodo1Mas_interstitial_ad_loaded():
	debug_out.text = debug_out.text + "Interstitial  loaded\n"
	
func _on_Yodo1Mas_interstitial_ad_not_loaded():
	yodo1mas.load_interstitial_ads()
	debug_out.text = debug_out.text + "Interstitial not loaded\n"

func _on_Yodo1Mas_interstitial_ad_opened():
	debug_out.text = debug_out.text + "Interstitial opened\n"
	
func _on_Yodo1Mas_interstitial_ad_failed_to_opened():
	yodo1mas.load_interstitial_ads()
	debug_out.text = debug_out.text + "Interstitial not opened\n"

func _on_Yodo1Mas_interstitial_ad_closed():
	yodo1mas.load_interstitial_ads()
	#add_coins(10)
	debug_out.text = debug_out.text + "Interstitial closed\n"



func _on_Yodo1Mas_rewarded_ad_loaded():
	debug_out.text = debug_out.text + "Rewarded video  loaded\n"
	
func _on_Yodo1Mas_rewarded_ad_not_loaded():
	yodo1mas.load_rewarded_ad()
	debug_out.text = debug_out.text + "Rewarded video not loaded\n"
	
func _on_Yodo1Mas_rewarded_ad_opened():
	debug_out.text = debug_out.text + "Rewarded video opened\n"
	
func _on_Yodo1Mas_rewarded_ad_failed_opened():
	yodo1mas.load_rewarded_ad()
	debug_out.text = debug_out.text + "Rewarded video not opened\n"
func _on_Yodo1Mas_rewarded_ad_closed():
	yodo1mas.load_rewarded_ad()
	debug_out.text = debug_out.text + "Rewarded video closed\n"

func _on_Yodo1Mas_rewarded_ad_earned():
	#add_coins(15)
	debug_out.text = debug_out.text + "Rewarded video earned\n"
