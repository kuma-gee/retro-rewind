extends GridContainer

signal submitted(text)

@export var label: Label

const a = 97
const z = 122

var typed = ""

func _ready():
	for c in range(a, z + 1):
		var btn = Button.new()
		add_child(btn)
		btn.text = String.chr(c)
		btn.pressed.connect(func(): _type_char(btn.text))
		
	var btn = Button.new()
	add_child(btn)
	btn.text = "<-"
	btn.pressed.connect(func(): _type_char(null))

	visibility_changed.connect(func(): get_child(0).grab_focus())

func _type_char(char):
	if char == null:
		typed = typed.substr(0, typed.length() - 1)
	else:
		typed += char
	label.text = typed

func _unhandled_input(event):
	if event.is_action_pressed("submit") and typed != "":
		submitted.emit(typed)
		typed = ""
		label.text = "ENTER to submit"
