extends Node2D

var quality = 100;
var isCompleted = false;
var isHeld = false;
@export var temperature = 0;
var recipeName = "DefaultRecipe"; #i.e Could be "Longsword"
var timeLeftHeated = 30.0;



# Called when the node enters the scene tree for the first time.
func _ready():
	print($ColorRect.color)
	#hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var MetalGlow = Color(temperature/1000,0.01,0.1,temperature/1000)
	$ColorRect.set_color(MetalGlow)
	pass
