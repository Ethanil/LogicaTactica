@tool
extends Control
class_name Latex

var fallback_label: Label = null
var latex_sprite: TextureRect = null
const latex_scale = 50
var LatexExpression: String = "default"

signal latex_rendered

static var known_textures:Dictionary[String, Texture2D]
static var currently_loading_textures:Dictionary[String, Signal]

func set_latex_expression(value:String):
	LatexExpression = value
	if OS.has_feature("web"):
		if known_textures.has(value):
			_load_texture_from_cache(value)
		elif currently_loading_textures.has(value):
			currently_loading_textures[value].connect(_load_texture_from_cache.bind(value))
			await currently_loading_textures[value]
		else:
			currently_loading_textures[value] = latex_rendered
			latex_rendered.connect(_remove_loading.bind(value))
			await _update_latex_texture()
	else:
		_update_label_text()

func _load_texture_from_cache(expression: String) -> void:
	latex_sprite.texture = known_textures[expression]

func _remove_loading(expression:String) -> void:
	currently_loading_textures.erase(expression)
	latex_rendered.disconnect(_remove_loading.bind(expression))

var img = JavaScriptBridge.create_object("Image")
var document = JavaScriptBridge.get_interface("document")
var URL = JavaScriptBridge.get_interface("URL")
var console = JavaScriptBridge.get_interface("console")
var window = JavaScriptBridge.get_interface("window")
var url

var receiveCallback := JavaScriptBridge.create_callback(_on_svg_received)
func _update_latex_texture() -> void:
	var math_jax = JavaScriptBridge.get_interface("MathJax")
	var promise = math_jax.tex2svgPromise(LatexExpression )
	promise.then(receiveCallback)
	await latex_rendered

func _on_svg_received(args):
	var mjx_container = args[0]
	if mjx_container == null:
		print("MathJax returned null")
		return
	var svg = mjx_container.querySelector("svg")
	if svg == null:
		print("Could not find SVG element inside mjx-container")
		return
	
	var XMLSerializer = JavaScriptBridge.create_object("XMLSerializer")
	var xml_string = XMLSerializer.serializeToString(svg)
	
	var svg_buffer: PackedByteArray = xml_string.to_utf8_buffer()
	var image := Image.new()
	var err = image.load_svg_from_buffer(svg_buffer, latex_scale)
	
	if err != OK:
		printerr("Failed to load SVG image from buffer. Error code: ", err)
	image.generate_mipmaps()
	var texture = ImageTexture.create_from_image(image)
	if latex_sprite and is_instance_valid(latex_sprite):
		latex_sprite.texture = texture
	
	known_textures[LatexExpression] = texture
	latex_rendered.emit()
	return


func _ready():
	if not OS.has_feature("web"):
		create_label()
	else:
		create_texture()

func _update_label_text():
	
	fallback_label.text = LatexExpression.replace("\\\\", "\n")
	var current = 0
	for i in range(30):
		fallback_label.add_theme_font_size_override("font_size", i + 1)
		if fallback_label.size.x > size.x or fallback_label.size.y > size.y:
			break
		current = i
	fallback_label.add_theme_font_size_override("font_size", current)

func create_label():
	fallback_label = Label.new()
	fallback_label.size = size
	fallback_label.text = LatexExpression
	fallback_label.position = Vector2(0, 0)
	
	fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fallback_label.add_theme_font_size_override("font_size", 10)
	fallback_label.add_theme_color_override("font_color", Color.BLACK)
	add_child(fallback_label)
	

func create_texture():
	latex_sprite = TextureRect.new()
	latex_sprite.position = Vector2(0, 0)
	latex_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	latex_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	latex_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	latex_sprite.anchor_left = 0.5
	latex_sprite.anchor_top = 0.5
	latex_sprite.anchor_right = 0.5
	latex_sprite.anchor_bottom = 0.5
	latex_sprite.offset_left = -size.x / 2
	latex_sprite.offset_right = size.x / 2
	latex_sprite.offset_top = - size.y / 2
	latex_sprite.offset_bottom = size.y / 2
	add_child(latex_sprite)
