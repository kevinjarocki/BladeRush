extends Node2D

var temperature = 0;
var quality = 100;
var isCompleted = false;
var recipeName = "dagger"; #i.e Could be "Longsword"
var timeLeftHeated = 30.0;
var isForge = false
var recipe = []
var stage = 0
var materialProperties = {
	"name" : "tin",
	"maxTemp" : 15000, 
	"coolRate" : 10, 
	"heatRate" : 25, 
	"idealTemp": 1000, 
	"idealTempRange": 500
	}
# Called when the node enters the scene tree for the first time.
func _ready():
	print($ColorRect.color)
	var stage = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var WhiteHot = Color(0.229,0.202,0.002,0.250)
	var ColdMetal = Color(0.0150,0,0,0.198)
	var MetalGlow = ColdMetal + Color(.146/500 * temperature, .202/2000*temperature, .002/1000*temperature, .100/1000*temperature)
	$ColorRect.set_color(MetalGlow)
	
	if isForge:
		if temperature < materialProperties["maxTemp"]:
			temperature += materialProperties["heatRate"]
	else:
		if temperature > 0:
			temperature -= materialProperties["coolRate"]




