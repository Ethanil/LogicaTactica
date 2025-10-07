extends Resource
class_name CreatureData

# Enable editing in the Inspector
@export var name: String
@export var attack_value: int
@export var health: int
@export var defense: int
@export var damaged_animations: Array[String] = ["damaged"]
@export var attack_animations: Array[String] = ["attack"]
@export var death_animations: Array[String] = ["death"]

@export var attack_sound: AudioAssetWithMetadata
@export var attack_sound_delay: float = 0
@export var sprite_y_offset: float = 0
# Tags/Attributes like "animal", "flying"
enum Attributes {    
	Empty = -1,
	Animal = 0,
	Flying = 1,
	Magical = 2,
	Insect = 3,
	Mythical = 4,
	Undead = 5,
	Plant = 6,
	Aquatic = 7,
	Mechanical = 8,
	Humanoid = 9,
	Small = 10,
	Medium = 11,
	Large = 12,
	Legendary = 13,
	}

static var attribute_dict:Dictionary[StringName, Attributes] = {
	"Tier": Attributes.Animal,
	"Fliegend": Attributes.Flying,
	"Magisch": Attributes.Magical,
	"Insekt": Attributes.Insect,
	"Mythisch": Attributes.Mythical,
	"Legendär": Attributes.Legendary,
	"Untot": Attributes.Undead,
	"Pflanze": Attributes.Plant,
	"Wasserlebewesen": Attributes.Aquatic,
	"Mechanisch": Attributes.Mechanical,
	"Humanoid": Attributes.Humanoid,
	"Klein": Attributes.Small,
	"Mittel": Attributes.Medium,
	"Groß": Attributes.Large,
}

@export var attributes: Array[Attributes] = []

# Enum for attack patterns
enum AttackPattern { FRONT, BACK, RANDOM, ALL, CUSTOM }
@export var attack_pattern: AttackPattern = AttackPattern.FRONT

@export var sprite_Frames: SpriteFrames
