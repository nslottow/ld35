package states;

import entities.PlayerController;

class Play extends luxe.States.State {
	var player:PlayerController;

	override function onenter<T>(_:T) {
		player = new PlayerController();

		// Load the default map
		var map_id = 'assets/maps/env_test_00.json';
		trace('Loading tiled map: $map_id');
		Level.load_json(Luxe.resources.text(map_id).asset.text);
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
		Level.destroy();
	}
}

