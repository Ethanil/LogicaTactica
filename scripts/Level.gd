class_name Level

enum LevelType {NORMAL, BOSS}

var type: LevelType
var allies: Array[CreatureData]
var enemies: Array[CreatureData]
var completed: bool = false

func _init(p_type: LevelType, p_allies: Array[CreatureData], p_enemies: Array[CreatureData], p_completed: bool = false):
	self.type = p_type
	self.allies = p_allies
	self.enemies = p_enemies
	self.completed = p_completed
