extends Node

@export var node_size: Vector2
@export var node_distances: Vector2

var level_select_sound_asset: AudioAssetWithMetadata = preload("res://assets/AudioResources/SFX/spell_levelselect.tres")

func _ready() -> void:
	var lt = Global.levelTree
	var level_depths = _compute_depths({}, lt, 1)
	var nodes = _collect_nodes(lt)
	var nodes_by_depth = _compute_nodes_by_depth(level_depths, nodes)
	var depths = nodes_by_depth.keys()
	var disabled_nodes = _compute_disabled_nodes(nodes)
	if not lt.level.completed:
		disabled_nodes.set(lt.get_instance_id(), false)
	
	depths.sort()
	
	var node_positions: Dictionary[int, Vector2] = {}
	
	var xPos = 100
	var yCenter = get_viewport().size.y / 2
	for d in depths:
		var levels: Array[LevelGraphNode]
		levels.assign(nodes_by_depth[d]) # Godot doesn't support nested typed collections so the array from the dict is currently untyped...
		
		var yPos = yCenter - (levels.size() * node_size.y + (levels.size() - 1) * node_distances.y) / 2
		
		for l in levels:
			var levelNode = _create_node_for_level(l.level, disabled_nodes.get(l.get_instance_id()))
			levelNode.position = Vector2(xPos, yPos)
			node_positions.set(l.get_instance_id(), Vector2(xPos, yPos))
			add_child(levelNode)
			
			yPos += node_size.y + node_distances.y
		
		xPos += node_distances.x + node_size.x
	
	for graph_node in nodes:
		for c in graph_node.children:
			var start_point = node_positions.get(graph_node.get_instance_id()) + Vector2(node_size.x, node_size.y / 2)
			var end_point = node_positions.get(c.get_instance_id()) + Vector2(0, node_size.y / 2)
			
			var arrow = CustomArrow2D.new(start_point, end_point, 5, Color(0.6,0.2,0.1))
			add_child(arrow)
	
func _compute_nodes_by_depth(levelDepths: Dictionary[int, int], levels: Array[LevelGraphNode]) -> Dictionary[int, Array]:
	var nodes_by_depth: Dictionary[int, Array] = {}

	for node in levels:
		var depth = levelDepths.get(node.get_instance_id(), -1)
		if depth == -1:
			assert(false, "Unreachable")

		if not nodes_by_depth.has(depth):
			nodes_by_depth[depth] = []
		
		nodes_by_depth[depth].append(node)
	
	return nodes_by_depth
	
# Graph is not allowed to be cyclic!
func _compute_depths(levelDepths: Dictionary[int, int], node: LevelGraphNode, depth: int) -> Dictionary[int, int]:
	var k = node.get_instance_id()
	var d = levelDepths.get(k, -1)
	if d < depth:
		# We might see a node multiple times, we only store its largest depth
		levelDepths.set(k, depth)
		
	for c in node.children:
		_compute_depths(levelDepths, c, depth + 1)
	
	return levelDepths
	
func _compute_disabled_nodes(nodes: Array[LevelGraphNode]) -> Dictionary[int, bool]:
	var disabled_nodes: Dictionary[int, bool] = {}
	for node in nodes:
		disabled_nodes.set(node.get_instance_id(), true)
	
	# Find all completed nodes of which no children are completed and enable all children recursively from there
	for node in nodes:
		if not node.level.completed:
			continue
		
		var child_completed = false
		for c in node.children:
			if c.level.completed:
				child_completed = true
				break
		
		if not child_completed:
			for c in node.children:
				disabled_nodes.set(c.get_instance_id(), false)

	return disabled_nodes
	
	
func _collect_nodes(graph: LevelGraphNode, known: Dictionary[LevelGraphNode, bool] = {}) -> Array[LevelGraphNode]:
	known.set(graph, true)
	
	for c in graph.children:
		_collect_nodes(c, known)
	return known.keys()
	
var button_tex_boss: Texture2D = load("res://assets/UI/kenney_ui-pack-adventure/PNG/Double/progress_red_small.png")
var button_tex_boss_border: Texture2D = load("res://assets/UI/kenney_ui-pack-adventure/PNG/Double/progress_red_small_border.png")
var button_tex_normal: Texture2D = load("res://assets/UI/kenney_ui-pack-adventure/PNG/Double/progress_white_small.png")
var button_tex_normal_border: Texture2D = load("res://assets/UI/kenney_ui-pack-adventure/PNG/Double/progress_white_small_border.png")
var button_tex_completed: Texture2D = load("res://assets/UI/kenney_ui-pack-adventure/PNG/Double/progress_transparent_small.png")
func _create_node_for_level(level: Level, disabled: bool) -> Control:
	var b = TextureButton.new()
	b.size = node_size
	b.stretch_mode = TextureButton.STRETCH_SCALE
	
	if !disabled:
		b.connect("pressed", _on_level_pressed.bind(level))
	else:
		b.mouse_default_cursor_shape = TextureButton.CursorShape.CURSOR_FORBIDDEN
	
	if level.completed:
		b.texture_normal = button_tex_completed
	elif level.type == Level.LevelType.NORMAL:
		b.texture_normal = button_tex_normal_border
		if not disabled:
			b.texture_hover = button_tex_normal
	else:
		b.texture_normal = button_tex_boss_border
		if not disabled:
			b.texture_hover = button_tex_boss

	return b
	
func _on_level_pressed(level: Level):
	Global.currentLevel = level
	get_tree().change_scene_to_file("res://mainScene.tscn")
	MusicPlayer.play_sfx(level_select_sound_asset.sound)
