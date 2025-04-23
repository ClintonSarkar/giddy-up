extends Node2D

@onready var cur_txt = $typing/cur_typed
@onready var target_txt = $typing/target
@onready var status_txt = $typing/status
@onready var level_txt = $typing/level/num
@onready var wrong_marker = $typing/ColorRect
@onready var status_anim = $typing/AnimationPlayer
@onready var timer_sprite = $timer_anim/timer
@onready var timer_anim = $timer_anim/AnimationPlayer
@onready var timer_audio = $timer_anim/time
@onready var reload_audio = $timer_anim/reload
@onready var mp_sprite = $mp/mp
@onready var mp_anim = $mp/AnimationPlayer
@onready var enemy_anim = $enemy/AnimationPlayer
@onready var dead_anim = $dead_anim
@onready var dead_bg = $dead_bg
@onready var quit_button = $dead_bg/quit
@onready var bg_music = $bg_music
@onready var shoot_audio = $shoot
@onready var hurt_audio = $hurt
@onready var end = $end

#input variables
var typing = false
var target = ""
var result_char = ""
var cur_inx = 0
var input_inx = 0
var last_wrong = false
var done = false

#level variables
var levels_path = "res://resources/levels.json"
var levels_dixc = {}
var level_key = "level1"
var cur_level = 1
var is_dead = false
var game_finished = false

#time variables
var timer = 0.0
var retry_timer = 0.0
var marker_timer = 0.0
var start_process = false

#the rule
const ten_seconds = 10.0

#marker colors
const green_color = Color("#00b939")
const red_color = Color("#ff2735")

#progession variables
var hit_timer = 5.0
var hit_counter = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	bg_music.play()
	levels_dixc = read_json_file(levels_path)
	target = levels_dixc[level_key]
	
	mp_sprite.texture = load("res://assets/mp/standard.png")
	cur_txt.position.x = target_txt.position.x
	wrong_marker.color = green_color
	wrong_marker.position.x = cur_txt.position.x - 105 + cur_txt.get_content_width() + 5
	
	target_txt.text = levels_dixc[level_key]
	level_txt.text = String.num_int64(cur_level)
	cur_txt.bbcode_enabled = false
	cur_txt.text = ""
	cur_txt.add_theme_font_size_override("normal_font_size", 42)
	cur_txt.add_theme_color_override("default_color", Color.BLACK)
	status_txt.text = "GET READY TO TYPE!"
	dead_bg.visible = false
	
	await get_tree().create_timer(2).timeout
	typing = true
	start_process = true
	status_txt.text = "TYPE!"
	
	timer_anim.play("playing")
	timer_audio.play()
	
	return

func _input(event):
	if typing && target != "" && event.is_pressed() && !event.is_echo():
		var input_char = event.as_text().to_lower()
#		print(input_char)
		result_char = process_char(input_char)
		if result_char != "":
			cur_txt.text += result_char
			if result_char == target[cur_inx] && input_inx == cur_inx:
#				print("Correct: ", result_char)
				input_inx += 1
				cur_inx += 1
				last_wrong = false
				mp_anim.stop()
				if hit_counter != 0:
					var sprite_name = "hit%s_6" % String.num_int64(hit_counter - 1)
					mp_sprite.texture = load("res://assets/mp/%s.png" % sprite_name)
				else:
					mp_sprite.texture = load("res://assets/mp/standard.png")
				if cur_inx == target.length():
#					print("Success!")
					mp_anim.play("shoot")
					shoot_audio.play()
					hurt_audio.play()
					if cur_level == 40:
						timer_anim.pause()
						timer_audio.stop()
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
						status_anim.play("game_finsihed")
						dead_anim.play("win")
						enemy_anim.play("last_killed")
						game_finished = true
						return
					enemy_anim.play("killed")
					cur_inx = 0
					input_inx = 0
					done = true
			else:
				input_inx += 1
				last_wrong = true
				print("Expected: ", target[cur_inx])
		print(cur_inx, input_inx)
		
	if typing && target != "" && event.is_pressed() && event.is_action("ui_text_backspace"):
		if cur_txt.text.length() > 0:
			cur_txt.text = cur_txt.text.erase(cur_txt.text.length() - 1)
		if input_inx > 0:
			input_inx -= 1
		if !last_wrong || input_inx < cur_inx:
			if cur_inx > 0:
				cur_inx -= 1
					
	return
	
func process_char(i_char:String)->String:
	var r_char:String
	r_char = i_char
	if i_char.length() > 1:
		r_char = ""
	if i_char.contains("shift+") && !i_char.contains("backspace"):
		r_char = i_char.replace("shift+","")
		r_char = r_char.to_upper()
	if i_char.contains("space") && !i_char.contains("back"):
		r_char = " "
	if i_char.contains("period"):
		r_char = "."
	if i_char.contains("comma"):
		r_char = ","
	if i_char.contains("shift+slash"):
		r_char = "?"
	if r_char.length() > 1:
		r_char = ""
	print("Input:", r_char)
	return r_char

func reset():
	result_char = ""
	cur_inx = 0
	input_inx = 0
	last_wrong = false
	done = false
	typing = true
	cur_txt.text = ""
	return

func progress_level():
	if done:
		cur_level += 1
		if cur_level % 5 == 0 && cur_level < 21:
			hit_timer -= 1
		level_key = "level" + String.num_int64(cur_level) 
		target = levels_dixc[level_key]
		target_txt.text = levels_dixc[level_key]
		status_txt.text = "TYPE!"
		timer_anim.play("playing")
		timer_audio.play()
		level_txt.text = String.num_int64(cur_level)
		reset()
	return
	
func read_json_file(path)->Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var txt_data = file.get_as_text()
	var dict = JSON.parse_string(txt_data)
	return dict

func fast_blink(maker_time:float)->float:
	wrong_marker.color = red_color
	if marker_timer > 0.2:
		wrong_marker.visible = true
		marker_timer = 0.0
	else:
		wrong_marker.visible = false
	return marker_timer
	
func slow_blink(maker_time:float)->float:
	wrong_marker.color = green_color
	if marker_timer > 0.5:
		wrong_marker.visible = true
		if marker_timer > 1.0:
			wrong_marker.visible = false
			marker_timer = 0.0
	return marker_timer

func _on_animation_player_animation_finished(anim_name):
	progress_level()
	return

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if status_anim.is_playing() || !start_process || !typing || is_dead || game_finished:
		return
	timer += delta
	marker_timer += delta
	wrong_marker.position.x = 145 + cur_txt.get_content_width() + 5
	
	if last_wrong:
		retry_timer += delta
		if !mp_anim.is_playing():
			var anim_name = "hit%s_%ssec" % [String.num_int64(hit_counter), String.num(hit_timer, 1)]
			mp_anim.play(anim_name)
		if retry_timer > hit_timer:
			print("HIT")
			enemy_anim.play("shoot")
			shoot_audio.play()
			hurt_audio.play()
			if hit_counter < 4 && typing:
				hit_counter += 1
			retry_timer = 0.0
		if last_wrong && (cur_inx == input_inx):
			marker_timer = slow_blink(marker_timer)
		else:
			marker_timer = fast_blink(marker_timer)
	else:
		marker_timer = slow_blink(marker_timer)
		retry_timer = 0.0
	
	if timer > ten_seconds && !is_dead:
		mp_anim.stop()
		timer_audio.stop()
#		bg_music.stop()
		typing = false
		status_txt.text = "YOU GOT SHOT!"
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var hit_string = String.num_int64(hit_counter)
		dead_anim.play("dead_%s" % hit_string)
		enemy_anim.play("shoot_final_%s" % hit_string)
		is_dead = true
		
	if done:
		typing = false
		timer = 0.0
		timer_anim.play("reload")
		timer_audio.stop()
		reload_audio.play()
		status_anim.play("next_level")
	
	if hit_counter == 4 && !is_dead:
#		bg_music.stop()
		typing = false
		status_txt.text = "YOU GOT SHOT!"
		timer_anim.pause()
		timer_audio.stop()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dead_anim.play("dead_%s" % String.num_int64(hit_counter))
		is_dead = true
	return

func _on_quit_pressed():
	get_tree().quit()
	return

func _on_bg_music_finished():
	bg_music.play()
	return
