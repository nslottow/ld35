package states;

import luxe.Text;

class LevelSelect extends luxe.States.State {
	override function onenter<T>(_:T) {
		var text = new Text({
			text: '<insert level select menu here>',
		});
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}
}

