extends Resource
class_name AudioAssetWithMetadata

@export var title: String
@export var artist: String
@export var sound: AudioStream
@export var link: String
@export var license: LicenseType


enum LicenseType{
	CC0 = 0,
	CC_BY2 = 1,
	CC_BY3 = 2,
	CC_BY_SA2 = 3,
	CC_BY_SA3 = 4,
	CC_BY4 = 5,
	CC_BY_SA4 = 6,
}
