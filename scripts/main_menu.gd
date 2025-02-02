extends CenterContainer

@export var network: NetworkManager

@onready var name_node = $VBoxContainer/GridContainer/Name
@onready var key_node = $VBoxContainer/GridContainer/Key
@onready var max_node = $VBoxContainer/GridContainer/Max
@onready var check_node = $VBoxContainer/GridContainer/CheckBox

@onready var key_label_node = $VBoxContainer/GridContainer/KeyLabel

func _ready():
    $"..".current_tab = 0

func _on_create_button_pressed() -> void:
    network.create_server(key_node.text, name_node.text, max_node.value, check_node.button_pressed)


func _on_join_button_pressed() -> void:
    network.join_server(key_node.text, name_node.text, check_node.button_pressed)


func _on_check_box_toggled(toggled_on: bool) -> void:
    key_label_node.text = 'IP:PORT/PORT' if toggled_on else 'Key'


func _on_network_manager_connected(_id: int) -> void:
    $"..".current_tab = 1
