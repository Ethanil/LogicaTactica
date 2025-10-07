extends AudioStreamPlayer
class_name MusicPlayer

var all_music:Array[AudioAssetWithMetadata] = [
	preload("res://assets/AudioResources/music/arcade_acadia.tres"),
	preload("res://assets/AudioResources/music/a_better_world.tres"),
	preload("res://assets/AudioResources/music/boss_battle.tres"),
	preload("res://assets/AudioResources/music/bullfrogdungeon.tres"),
	preload("res://assets/AudioResources/music/calmer_tides.tres"),
	preload("res://assets/AudioResources/music/dancing_necromancer.tres"),
	preload("res://assets/AudioResources/music/destiny_calls.tres"),
	preload("res://assets/AudioResources/music/do_not_run.tres"),
	preload("res://assets/AudioResources/music/escape_the_dungeon.tres"),
	preload("res://assets/AudioResources/music/into_the_portal.tres"),
	preload("res://assets/AudioResources/music/into_the_ruins.tres"),
	preload("res://assets/AudioResources/music/kirill_r.tres"),
	preload("res://assets/AudioResources/music/mountain_climb.tres"),
	preload("res://assets/AudioResources/music/night_sky.tres"),
	preload("res://assets/AudioResources/music/perseverance.tres"),
	preload("res://assets/AudioResources/music/respite.tres"),
	preload("res://assets/AudioResources/music/serpent.tres"),
	preload("res://assets/AudioResources/music/some_adventure.tres"),
	preload("res://assets/AudioResources/music/sorcerers_curse.tres"),
	preload("res://assets/AudioResources/music/spiders_web.tres"),
	preload("res://assets/AudioResources/music/sunshine_skirmish.tres"),
	preload("res://assets/AudioResources/music/suprise_attack.tres"),
	preload("res://assets/AudioResources/music/swinging_tavern.tres"),
	preload("res://assets/AudioResources/music/temple_doors.tres"),
	preload("res://assets/AudioResources/music/tempus_ex_deus.tres"),
	preload("res://assets/AudioResources/music/warriors_courage.tres"),
]
var playlist:Array[int] = []

@onready var music_information : RichTextLabel = %MusicInformation
@onready var sfx: AudioStreamPlayer = %SFX
static var  button_click_sound_asset:AudioAssetWithMetadata = preload("res://assets/AudioResources/SFX/stones4.tres")
signal sfx_finished
static var instance: MusicPlayer
const MUSIC_DIR = "res://assets/AudioResources/"

static func play_sfx(sound:AudioStream) -> void:
	if instance == null:
		return
	instance.sfx.stream = sound
	instance.sfx.play()

static func button_click_sound() -> void:
	play_sfx(button_click_sound_asset.sound)

func _ready() -> void:
	instance = self
	if all_music.is_empty():
		push_error("No music files found in '%s'. Music player will be disabled." % MUSIC_DIR)
		music_information.modulate.a = 0.0
		return

	_on_volume_changed(Global.music_volume)
	Global.music_volume_changed.connect(_on_volume_changed)
	_on_sfx_volume_changed(Global.sfx_volume)
	Global.sfx_volume_changed.connect(_on_sfx_volume_changed)
	pick_next_song()
	self.finished.connect(pick_next_song)
	instance.sfx.finished.connect(instance.sfx_finished.emit)

func _on_sfx_volume_changed(volume: float) -> void:
	self.sfx.volume_linear = volume

func _on_volume_changed(volume: float) -> void:
	self.volume_linear = volume

func fill_playlist() -> void:
	playlist.clear()
	for i in len(all_music):
		playlist.append(i)
	playlist.shuffle()

var current_tween : Tween = null

func pick_next_song() -> void:
	if playlist.is_empty():
		fill_playlist()
	
	if all_music.is_empty():
		return
	
	if current_tween != null:
		current_tween.kill()
		current_tween = null
	var next_song_index = playlist.pop_front()
	var next_song = all_music[next_song_index]
	
	self.stream = next_song.sound
	self.play()
	
	music_information.text = "[font_size=40]%s[/font_size]
[i][font_size=10]von %s[/font_size][/i]" % [next_song.title, next_song.artist]
	music_information.update_minimum_size()
	#var on_screen_position := music_information.position
	#var off_screen_right_position = Vector2(on_screen_position.x + music_information.size.x * 1.1, on_screen_position.y)
	music_information.offset_right = music_information.size.x
	current_tween = create_tween()

	current_tween.tween_property(music_information, "offset_right", -20, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	current_tween.tween_interval(4.0)
	current_tween.tween_property(music_information, "offset_right", music_information.size.x, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
