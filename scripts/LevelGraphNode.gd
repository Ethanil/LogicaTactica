class_name LevelGraphNode

var level: Level
var children: Array[LevelGraphNode]

func _init(p_level: Level, p_children: Array[LevelGraphNode] = []) -> void:
	self.level = p_level
	self.children = p_children
	
func addChild(node: LevelGraphNode):
	self.children.append(node)
