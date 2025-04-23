extends Node

const green_color = Color("#00b939")
const red_color = Color("#ff2735")

var typing = false
var typed = ""
var target = ""
var result_char = ""
var cur_inx = 0
var input_inx = 0
var last_wrong = false
var done = false
var is_backspace = false
var is_typed = false
var same_index = false

func _input(event):
	if typing && target != "" && event.is_pressed() && !event.is_echo():
		var input_char = event.as_text().to_lower()
#		print(input_char)
		result_char = process_char(input_char)
		if result_char != "":
			if result_char == "backspace":
				is_backspace = true
				if input_inx > 0:
					input_inx -= 1
				if !last_wrong || input_inx < cur_inx:
					if cur_inx > 0:
						cur_inx -= 1
			elif result_char != "backspace":
				is_backspace = false
				is_typed = true
				typed = typed + result_char #Test
				if result_char == target[cur_inx] && input_inx == cur_inx:
#					print("Correct: ", result_char)
					input_inx += 1
					cur_inx += 1
					last_wrong = false
					if cur_inx == target.length():
#						print("Success!")
						cur_inx = 0
						input_inx = 0
						done = true
				else:
					input_inx += 1
					last_wrong = true
					print("Expected: ", target[cur_inx])
		if input_inx == cur_inx:
			same_index = true
		else :
			same_index = false
		print(cur_inx, input_inx)
	return
	
func process_char(i_char:String)->String:
	var r_char:String
	r_char = i_char
	if i_char.length() > 1:
		r_char = ""
	if i_char.contains("shift+"):
		r_char = i_char.replace("shift+","")
		r_char = r_char.to_upper()
	if i_char.contains("space") && !i_char.contains("back"):
		r_char = " "
	if i_char.contains("period"):
		r_char = "."
	if i_char.contains("comma"):
		r_char = ","
	if i_char.contains("backspace"):
		r_char = "backspace"
#	print("Input:", r_char)
	return r_char

func reset():
	typed = ""
	result_char = ""
	cur_inx = 0
	input_inx = 0
	last_wrong = false
	done = false
	typing = true
