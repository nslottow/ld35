package states;

class Play extends luxe.States.State {
	override function onenter<T>(_:T) {
		// Load the default map
		var map_id = 'assets/maps/test_00.json';
		trace('Loading tiled map: $map_id');
		Level.load_json(Luxe.resources.text(map_id).asset.text);
	}

	override function onleave<T>(_:T) {
		Level.destroy();
	}
}

