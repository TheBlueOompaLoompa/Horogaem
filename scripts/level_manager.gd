extends Node3D
class_name LevelManager

@export var player: PackedScene
@export var net_spawn: Node3D

func list_levels():
    var levels = DirAccess.get_files_at("res://scenes/levels/")
    var user_levels = DirAccess.get_files_at("user://levels/")
    
    for i in len(levels):
        levels[i] = "res://scenes/levels/" + levels[i]
    for i in len(user_levels):
        user_levels[i] = "user://levels/" + user_levels[i]
    
    levels.append_array(user_levels)
    
    return levels

func load_level(path: String):
    if multiplayer.is_server():
        _load_level(path)
        rpc("_load_level", path)
        
        spawn_player(1)
        
        # Spawn Players
        for peer in multiplayer.get_peers():
            spawn_player(peer)
            
func spawn_player(owner: int):
    var player = player.instantiate()
    net_spawn.add_child(player, true)
    g.set_authority(player.get_path(), owner)
    player.rpc("_remote_ready")

@rpc("authority", "reliable")
func _load_level(path: String):
    var level = load(path)
    add_child(level.instantiate())
    return level
