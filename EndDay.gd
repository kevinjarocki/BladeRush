extends Node2D

signal nextDayPressed

func endDay(day, money):
	visible = true
	$Control/Info.text = "Finished day: " + str(day) + "\n"

func _on_next_day_pressed():
	visible = false
	nextDayPressed.emit()
