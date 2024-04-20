extends Control




func _on_back_to_menu_button_pressed():
	$ThwakToMainMenu.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_mute_check_toggled(toggled_on):
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, not AudioServer.is_bus_mute(!toggled_on))

