extends Node

var server_info = {
	name = "Server",      # Holds the name of the server
	max_players = 2,      # Maximum allowed connections
	used_port = 25570         # Listening port
}

var players = {}

signal server_created                          # when server is successfully created
signal join_success                            # When the peer successfully joins a server
signal join_fail                               # Failed to join a server
signal player_list_changed                     # List of players has been changed
signal player_removed(pinfo)                   # A player has been removed from the list
signal server_closed

func _ready():
	var error = null
	error = get_tree().connect("network_peer_connected", self, "_on_player_connected")
	error = get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	error = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	error = get_tree().connect("connection_failed", self, "_on_connection_failed")
	error = get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")
	if error:
		print(error)

func create_server():
	# Initialize the networking system
	var net = NetworkedMultiplayerENet.new()
	
	# Try to create the server
	if (net.create_server(server_info.used_port, server_info.max_players) != OK):
		print("Failed to create server")
		return
		
	# Assign it into the tree
	get_tree().set_network_peer(net)
	# Tell the server has been created successfully
	emit_signal("server_created")
	# Register the server's player in the local player list
	register_player(Gamestate.player_info)


func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new()
	
	if (net.create_client(ip, port) != OK):
		print("Failed to create client")
		emit_signal("join_fail")
		return
		
	get_tree().set_network_peer(net)


remote func register_player(pinfo):
	if (get_tree().is_network_server()):
		# We are on the server, so distribute the player list information throughout the connected players
		for id in players:
			# Send currently iterated player info to the new player
			rpc_id(pinfo.net_id, "register_player", players[id])
			# Send new player info to currently iterated player, skipping the server (which will get the info shortly)
			if (id != 1):
				rpc_id(id, "register_player", pinfo)
	
	# Now to code that will be executed regardless of being on client or server
	print("Registering player ", pinfo.name, " (", pinfo.net_id, ") to internal player table")
	players[pinfo.net_id] = pinfo          # Create the player entry in the dictionary
	emit_signal("player_list_changed")     # And notify that the player list has been changed
	

remote func unregister_player(id):
	print("Removing player ", players[id].name, " from internal table")
	# Cache the player info because it's still necessary for some upkeeping
	var pinfo = players[id]
	# Remove the player from the list
	players.erase(id)
	# And notify the list has been changed
	emit_signal("player_list_changed")
	# Emit the signal that is meant to be intercepted only by the server
	emit_signal("player_removed", pinfo)
	

# Everyone gets notified whenever a new client joins the server
func _on_player_connected(id):
	print('player with ', id, ' connected!')
	emit_signal("player_list_changed")


# Everyone gets notified whenever someone disconnects from the server
func _on_player_disconnected(id):
	print("Player ", players[id].name, " disconnected from server")
	# Update the player tables
	if (get_tree().is_network_server()):
		# Unregister the player from the server's list
		unregister_player(id)
		# Then on all remaining peers
		rpc("unregister_player", id)
		
# Peer trying to connect to server is notified on success
func _on_connected_to_server():
	emit_signal("join_success")
	# Update the player_info dictionary with the obtained unique network ID
	Gamestate.player_info.net_id = get_tree().get_network_unique_id()
	# Request the server to register this new player across all connected players
	rpc_id(1, "register_player", Gamestate.player_info)
	# And register itself on the local list
	register_player(Gamestate.player_info)


# Peer trying to connect to server is notified on failure
func _on_connection_failed():
	print('connection failed!')
	emit_signal("join_fail")
	get_tree().set_network_peer(null)


# Peer is notified when disconnected from server
func _on_disconnected_from_server():
	print("Disconnected from server")
	# Clear the internal player list
	players.clear()
	# Reset the player info network ID
	Gamestate.player_info.net_id = 1
	emit_signal('server_closed')
