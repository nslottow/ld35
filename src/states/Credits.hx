package states;

import luxe.Text;

class Credits extends luxe.States.State {
	override function onenter<T>(_:T) {
		var text = new Text({
			text: '<insert credits here>',
		});
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}
}

