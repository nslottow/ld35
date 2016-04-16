import luxe.Input;
import luxe.Vector;
import luxe.States;
import luxe.options.StateOptions;

// In order to use states, touch support hack for web must be routed through a state manager (luxe.States)
// because the state manager listens directly to Luxe.core events.

class StateManager extends States
{
	var touch_supported:Bool = false;

// Disallow touch events on mac native builds.
// NOTE: May want a different solution if we want a native build that has screen touch like windows surface.
#if !desktop
	override function touchdown(e:TouchEvent)
	{
		// NOTE: This assumes that touch events happen before mouse events on touch supported web
		touch_supported = true;
		super.touchdown(e);
	}

	override function touchup(e:TouchEvent)
	{
		touch_supported = true;
		super.touchup(e);
	}

	override function touchmove(e:TouchEvent)
	{
		touch_supported = true;
		super.touchmove(e);
	}
#end // !desktop

#if !mobile
	public override function mousedown(e:MouseEvent)
	{
		if (!touch_supported) {
			super.touchdown(get_touch_event(e));
		}
	}

	override function mouseup(e:MouseEvent)
	{
		if (!touch_supported) {
			super.touchup(get_touch_event(e));
		}
	}

	override function mousemove(e:MouseEvent)
	{
		if (!touch_supported) {
            // HACK: Only send a touch event if the mouse is down (simulating a held touch)
            if (Luxe.input.mousedown(MouseButton.left)) {
                super.touchmove(get_touch_event(e));
            }
			super.mousemove(e);
		}
	}
#end

	function get_touch_event(e:MouseEvent)
	{
		var pos = new Vector(e.x / Luxe.screen.w, e.y / Luxe.screen.h);
		var delta = new Vector(e.xrel / Luxe.screen.w, e.yrel / Luxe.screen.h);

		return {
			state: e.state,
			timestamp: e.timestamp,
			touch_id: -2,
			x: pos.x,
			y: pos.y,
			dx: delta.x,
			dy: delta.y,
			pos: pos
		}
	}
}

