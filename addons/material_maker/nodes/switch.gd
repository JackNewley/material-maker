tool
extends MMGraphNodeGeneric

var fixed_lines : int = 0

func _ready():
	update_node()

func update_preview_buttons(index : int):
	for i in range(generator.parameters.outputs):
		if i != index:
			var line = get_child(i)
			line.get_child(2).pressed = false

func update_node():
	print("update_node")
	if generator == null or !generator.parameters.has("outputs") or !generator.parameters.has("choices"):
		return
	save_preview_widget()
	var new_fixed_lines = 3 if generator.editable else 1
	if new_fixed_lines != fixed_lines:
		fixed_lines = new_fixed_lines
		# Remove all lines
		while get_child_count() > 0:
			var remove = get_child(0)
			remove_child(remove)
			remove.free()
		var lines_list = []
		if generator.editable:
			lines_list.push_back( { name="outputs", min=1, max=5 } )
			lines_list.push_back( { name="choices", min=2, max=5 } )
		lines_list.push_back( { name="source", min=0, max=generator.parameters.choices-1 } )
		for l in lines_list:
			var sizer = HBoxContainer.new()
			var input_label = Label.new()
			sizer.add_child(input_label)
			var control : HSlider = HSlider.new()
			control.name = l.name
			control.value = generator.parameters[l.name]
			control.min_value = l.min
			control.max_value = l.max
			control.step = 1
			control.rect_min_size.x = 75
			sizer.add_child(control)
			control.connect("value_changed", self, "_on_value_changed", [ l.name ])
			controls[l.name] = control
			sizer.add_child(preload("res://addons/material_maker/widgets/preview_button.tscn").instance())
			add_child(sizer)
	else:
		# Keep lines with controls
		while get_child_count() > output_count and get_child_count() > fixed_lines:
			var remove = get_child(get_child_count()-1)
			remove_child(remove)
			remove.free()
	# Populate the GraphNode
	var output_count : int = generator.parameters.outputs
	var input_count : int = output_count * generator.parameters.choices
	controls["source"].max_value = generator.parameters.choices-1
	while get_child_count() < input_count:
		var sizer = HBoxContainer.new()
		var input_label = Label.new()
		sizer.add_child(input_label)
		if get_child_count() < 5:
			var space = Control.new()
			space.size_flags_horizontal = SIZE_EXPAND | SIZE_FILL
			sizer.add_child(space)
			sizer.add_child(preload("res://addons/material_maker/widgets/preview_button.tscn").instance())
		add_child(sizer)
	rect_size = Vector2(0, 0)
	for i in range(get_child_count()):
		var sizer = get_child(i)
		var has_input = true
		var has_output = false
		if i < 5:
			has_output = i < output_count
			sizer.get_child(2).visible = has_output
			sizer.get_child(2).connect("toggled", self, "on_preview_button", [ i ])
		if i >= input_count:
			sizer.get_child(0).text = ""
			has_input = false
		else:
			sizer.get_child(0).text = PoolByteArray([65+i%int(output_count)]).get_string_from_ascii()+str(1+i/int(output_count))
			sizer.get_child(0).add_color_override("font_color", Color(1.0, 1.0, 1.0) if i/int(output_count) == generator.parameters.source else Color(0.5, 0.5, 0.5))
		set_slot(i, has_input, 0, Color(0.0, 0.5, 0.0, 0.5), has_output, 0, Color(0.0, 0.5, 0.0, 0.5))
	# Preview
	restore_preview_widget()
	print("update_node end")
