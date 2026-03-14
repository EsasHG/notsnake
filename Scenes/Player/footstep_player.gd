extends AudioStreamPlayer2D

@export var start_delay : float = 0.0
@export var repeat_delay : float = 0.5
var pitch_min = 0.9
var pitch_max = 1.1
var streams = [preload("uid://dp7ytkqy51m8w")]
#var streams = [preload("uid://xu521t2l1myd"), preload("uid://qj7b74fnqm1x"), preload("uid://drtkv62yvpcq6"), preload("uid://dsi7eekei4pr4"), preload("uid://bbys53itpmjdk"), preload("uid://j3cw2rv3b8bw"), preload("uid://cxom0m44fmnhw"), preload("uid://brxpma41j12st"), preload("uid://b2sd3434vqjok"), preload("uid://cowh3atelpeaq"), preload("uid://0by1mgc3p41p"), preload("uid://bqxcgc77n61qn"), preload("uid://c06gikgupppga"), preload("uid://dr02kdwoktwmm"), preload("uid://eth7vu7th2ms"), preload("uid://c2vpwj6bvesy0"), preload("uid://cdmxqs7q22k65"), preload("uid://bbvobmnty8ygm"), preload("uid://dxhfacx63tpfd"), preload("uid://bhxnonu173khf"), preload("uid://dlnbxaejtq73k"), preload("uid://bdxjrrib4nx8k"), preload("uid://db8kx41gqlfv6"), preload("uid://ud4sik88waeq")]

var countdown : Timer


func _ready() -> void:
	var randomStreams : AudioStreamRandomizer = stream as AudioStreamRandomizer
	var i = 0
	for s in streams:
		randomStreams.add_stream(i,s)
		i+=1
	
	randomStreams.random_pitch_semitones = 1
	randomStreams.random_volume_offset_db = 3
	countdown = Timer.new()
	countdown.autostart = false
	countdown.one_shot = true
	countdown.timeout.connect(play_bird_sfx)
	GameSettings.on_gameOver.connect(countdown.stop)
	add_child.call_deferred(countdown)
	countdown.start.call_deferred(start_delay)


func play_bird_sfx() -> void:
	pitch_scale = randf_range(pitch_min, pitch_max)
	play()
	countdown.start(repeat_delay)
	

		
