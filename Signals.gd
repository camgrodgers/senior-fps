extends Node

signal level_selected(filename)
signal restart_level()
signal quit()
signal level_completed(end_level)

signal recoil(force)
signal expose_ammo_count(loaded, backup, per_mag)
signal hide_ammo_count()
signal camera_zoom(amount)
signal camera_unzoom()

signal temporary_object_spawned(object)
signal enemy_spawn_triggered(location, enemy_type, patrol_route, has_target)

signal popup_message(text)
signal hide_popup_message()

#signal player_danger_update(red, orange, yellow)
