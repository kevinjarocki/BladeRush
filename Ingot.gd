extends Node2D

var temperature = 0;
var quality = 100;
var isCompleted = false;
var recipeName = "axe"; #i.e Could be "Longsword"
var timeLeftHeated = 30.0;
var isForge = false
var recipe = []
var stage = 0
var materialProperties = {
	"name" : "tin",
	"coolRate" : 10, 
	"heatRate" : 25, 
	"idealTemp": 1000, 
	"idealTempRange": 500,
	"valueMod": 6,
	"cost": 1
	}
# Called when the node enters the scene tree for the first time.
func _ready():
	#print($ColorRect.color)
	var stage = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var WhiteHot = Color(0.229,0.202,0.002,0.250)
	var ColdMetal = Color(0.0150,0,0,0.198)
	var MetalGlow = ColdMetal + Color(.25/1000 * 1.1 *temperature, .25/1000*0.1*pow(temperature,1.2) - 0.25/1000*0.2*temperature, 0 , .202/1000*0.5*temperature)
	#self_modulate.r = 1
	#self_modulate.g = .202/2000*temperature
	#self_modulate.b = 0
	#self_modulate.a = 1
	#self_modulate = MetalGlow
	#print(self_modulate)
	$AnimatedSprite2D.self_modulate = Color(1,1,1,1)

	$Filter.self_modulate = MetalGlow
	#$ColorRect.set_color(MetalGlow)
	if isForge:
		if temperature < 8000:
			temperature += materialProperties["heatRate"]
	else:
		if temperature >= materialProperties["coolRate"]:
			temperature -= materialProperties["coolRate"]
		else:
			temperature = 0




