package states;

import luxe.Text;

class Title extends luxe.States.State {
	override function onenter<T>(_:T) {
		var text = new Text({
			text: '<insert title here>',
		});
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}
}

