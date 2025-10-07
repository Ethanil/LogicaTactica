extends Control

@onready var close_button:Button = $Panel/Button
@onready var label: RichTextLabel = %RichTextLabel

var effects := ["[pulse]%s[/pulse]", "[rainbow]%s[/rainbow]", "[wave]%s[/wave]"]


func _ready() -> void:
	close_button.pressed.connect(queue_free)
	close_button.pressed.connect(MusicPlayer.button_click_sound)
	
	var audios_with_metadata := load_recursively_grouped_by_dir("res://assets/AudioResources/")
	
	label.push_font_size(30)
	label.append_text("Sprites")
	label.pop()
	label.push_list(1, RichTextLabel.LIST_DOTS, false)
	label.push_meta("https://www.patreon.com/elthen/collections")
	label.append_text("Alle von Elthen")
	label.pop()
	label.newline()
	label.pop()
	
	label.push_font_size(30)
	label.append_text("Icons")
	label.pop()
	label.push_list(1, RichTextLabel.LIST_DOTS, false)
	label.push_meta("https://kenney.nl/")
	label.append_text("UI Components von Kenney")
	label.pop()
	label.newline()
	label.push_meta("https://opengameart.org/content/700-rpg-icons")
	label.append_text("Kreaturen Attribut Icons von Lorc")
	label.pop()
	label.newline()
	label.pop()
	
	for directory in audios_with_metadata.keys():
		label.push_font_size(30)
		label.append_text(directory)
		label.pop()
		label.push_list(1, RichTextLabel.LIST_DOTS, false)
		var arr = audios_with_metadata[directory]
		for audio in arr:
			audio = audio as AudioAssetWithMetadata
			label.push_meta(audio.link)
			var text := "%s von %s" % [audio.title, audio.artist]
			label.append_text(text)
			label.pop()
			label.newline()
		label.pop()
	

	var markdown_for_readme = _generate_markdown_string(audios_with_metadata)

	print(markdown_for_readme)




func _generate_markdown_string(data: Dictionary) -> String:
	var s = ""
	s += "## Sprites\n"
	s += "* [Alle von Elthen](https://www.patreon.com/elthen/collections)\n\n"
	
	s += "## Icons\n"
	s += "* [UI Components von Kenney](https://kenney.nl/)\n"
	s += "* [Kreaturen Attribut Icons von Lorc](https://opengameart.org/content/700-rpg-icons)\n\n"

	for directory in data.keys():
		s += "## %s\n" % directory
		var arr = data[directory]
		for audio in arr:
			audio = audio as AudioAssetWithMetadata
			var text := "%s von %s" % [audio.title, audio.artist]
			s += "* [%s](%s)\n" % [text, audio.link]
		s += "\n"
	return s



func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)

func load_recursively_grouped_by_dir(path: String, resources: Dictionary = {}) -> Dictionary:
	var dir = DirAccess.open(path)
	if not dir:
		printerr("An error occurred when trying to access the path: ", path)
		return resources

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = path.path_join(file_name)

		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				load_recursively_grouped_by_dir(full_path, resources)
		else:
			if not file_name.ends_with(".import"):
				var resource = load(full_path)
				if resource:
					var parent_dir_name = full_path.get_base_dir().get_file()
					if not resources.has(parent_dir_name):
						resources[parent_dir_name] = []
					resources[parent_dir_name].append(resource)

		file_name = dir.get_next()

	return resources
