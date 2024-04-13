extends Node2D

@export var money = 0

func _process(delta):
	$Label.text = str(money)


func _on_button_pressed():
	money += 1
	pass # Replace with function body.
