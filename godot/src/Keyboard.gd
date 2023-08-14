extends VBoxContainer

signal submitted(text)

@export var label: Label
@export var grid: GridContainer

@export var submit_btn: Button
@export var confirm_no_submit: Control

const a = 97
const z = 122

var typed = "" : set = _set_typed

func _set_typed(v):
	typed = v
	label.text = typed

func _ready():
	confirm_no_submit.hide()
	
	for c in range(a, z + 1):
		var btn = Button.new()
		grid.add_child(btn)
		btn.text = String.chr(c)
		btn.pressed.connect(func(): 
			_type_char(btn.text)
			_show_submit()
		)
		
	var btn = Button.new()
	grid.add_child(btn)
	btn.text = "<-"
	btn.pressed.connect(func(): _type_char(null))

	visibility_changed.connect(func(): grid.get_child(0).grab_focus())

func _type_char(char):
	if char == null:
		self.typed = typed.substr(0, typed.length() - 1)
	elif typed.length() < 15:
		self.typed += char

func _show_submit():
	confirm_no_submit.hide()
	submit_btn.show()

func _on_cancel_pressed():
	_show_submit()
	submit_btn.grab_focus()


func _on_no_submit_pressed():
	_submit()

func _submit():
	submitted.emit(typed)
	self.typed = ""
	_show_submit()
	

func _on_submit_pressed():
	if typed != "":
		_submit()
	else:
		submit_btn.hide()
		confirm_no_submit.show()
		confirm_no_submit.get_child(0).grab_focus()
