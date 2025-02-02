extends Node
func print(stuff):
    print("Peer " + str(multiplayer.get_unique_id()) + ": " + str(stuff))

@rpc("authority", "reliable")
func set_authority(path: NodePath, id: int, recursive = true):
    if multiplayer.is_server():
        rpc("set_authority", path, id, recursive)
    get_node(path).set_multiplayer_authority(id, recursive)
