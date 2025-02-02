extends CenterContainer

@export var container: VBoxContainer
@export var start_game_button: Button
@export var level_manager: LevelManager

func _on_network_manager_players_changed(players: Dictionary) -> void:
    for child in container.get_children():
        child.queue_free()
    
    print(players)
    
    for id in players.keys():
        var label = Label.new()
        label.text = players[id]["name"]
        container.add_child(label)

func _on_visibility_changed() -> void:
    if visible and not multiplayer.is_server():
        start_game_button.hide()


func _on_start_game_pressed() -> void:
    level_manager.load_level("res://scenes/levels/debug.tscn")
    set_menu_visible(false)

func set_menu_visible(visibility: bool):
    _set_menu_visible(visibility)
    rpc("_set_menu_visible", visibility)

@rpc("authority", "reliable")
func _set_menu_visible(visibility: bool):
    $"../..".visible = visibility
