extends HolePunch
class_name NetworkManager

signal connected(id: int)
signal player_connected(id: int, name: String)
signal players_changed(players: Dictionary)

const PLAYER_PREFAB = preload("res://scenes/prefabs/player.tscn")
@onready var net_spawn = $"../NetworkSpawn"
@onready var menu = $"../PanelContainer"
@export var tabs: TabContainer
@export var network_config: NetworkConfig

var players = {}
var player = {"name": "Waiting for name..."}

func _ready() -> void:
    # Console Commands
    LimboConsole.register_command(create_server, 'create_server', 'key: String, username: String, max_players: int = 20, direct: bool = false')
    LimboConsole.register_command(join_server, 'join_server', 'key: String, username: String, direct: bool')
    
    LimboConsole.add_alias('host', 'dev_server')
    LimboConsole.add_alias('client', 'dev_client')
    LimboConsole.add_alias('dev_host', 'dev_server')
    LimboConsole.register_command(dev_server, "dev_server", 'port: int = 12346, name: String = "dev_host"')
    LimboConsole.register_command(dev_client, "dev_client", 'port: int = 12346, name: String = "dev_client"')
    
    rendevouz_address = network_config.rendevouz_address
    rendevouz_port = network_config.rendevouz_port
    
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_player_connected(id: int):
    connected.emit(id)
    g.print("Player " + str(id) + " Connected")

func _on_connected_to_server():
    update_player_info(player)

func update_player_info(new_player_info):
    if multiplayer.is_server():
        _update_player_info(new_player_info)
    else:
        rpc("_update_player_info", new_player_info)

@rpc("any_peer", "reliable")
func _update_player_info(new_player_info: Dictionary):
    g.print(multiplayer.get_remote_sender_id())
    var new_player_id = multiplayer.get_remote_sender_id() if multiplayer.get_remote_sender_id() != 0 else 1
    players[new_player_id] = new_player_info
    player_connected.emit(new_player_id, new_player_info)
    if multiplayer.is_server():
        _update_players(players)
        g.print(players)
        rpc("_update_players", players)

@rpc("authority", "reliable")
func _update_players(new_players):
    g.print(players)
    g.print(new_players)
    players = new_players
    players_changed.emit(players)

func dev_server(port: int = 12346, name: String = 'dev_host'):
    LimboConsole.hide()
    create_server(str(port), name, 20, true)
    $"../PanelContainer/TabContainer".current_tab = 1


func dev_client(port: int = 12346, name: String = 'dev_client'):
    LimboConsole.hide()
    join_server('127.0.0.1:' + str(port), name, true)


func create_server(_key: String, _name: String, max_players: int = 20, direct = false):
    if direct:
        var peer = ENetMultiplayerPeer.new()
        var error = peer.create_server(int(_key), max_players)
        if error:
            return error
        multiplayer.multiplayer_peer = peer
    else:
        start_traversal(_key, true, _name)
    player["name"] = _name
    players[1] = player
    tabs.current_tab = 1
    players_changed.emit(players)


func join_server(_key: String, _name: String, direct = false):
    player["name"] = _name
    if direct:
        var peer = ENetMultiplayerPeer.new()
        var addr = _key.split(":")
        if len(addr) < 2:
            return
        var error = peer.create_client(addr[0], int(addr[1]))
        if error:
            return error
        multiplayer.multiplayer_peer = peer
    else:
        start_traversal(_key, false, _name)


func _on_hole_punched(my_port: Variant, hosts_port: Variant, hosts_address: Variant) -> void:
    g.print(hosts_port)
    g.print(hosts_address)


func _on_session_registered() -> void:
    if is_host:
        multiplayer.multiplayer_peer = server_udp
    else:
        multiplayer.multiplayer_peer = peer_udp
