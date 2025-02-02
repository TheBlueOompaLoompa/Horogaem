extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var remote_ready = false

@rpc("any_peer", "reliable")
func _remote_ready():
    if not(remote_ready) and multiplayer.get_remote_sender_id() <= 1:
        remote_ready = true
        g.print(get_multiplayer_authority())
        g.print(name)
        if is_multiplayer_authority():
            $Camera3D.make_current()

func _physics_process(delta: float) -> void:
    if not is_multiplayer_authority(): return
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir := Input.get_vector("left", "right", "forward", "backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
