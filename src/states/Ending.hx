package states;

import luxe.Text;

class Ending extends luxe.States.State {
	override function onenter<T>(_:T) {
		var text = new Text({
			text: '<insert ending here>',
		});
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}
}

