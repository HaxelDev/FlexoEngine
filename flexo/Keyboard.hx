package flexo;

import sdl.events.KeyboardEvent;
import sdl.keyboard.KeyCode;

class Keyboard {
    private static var keyStates:Map<KeyCode, Bool> = new Map<KeyCode, Bool>();

    public static function onKeyDown(event:KeyboardEvent):Void {
        keyStates.set(event.keysym.sym, true);
    }

    public static function onKeyUp(event:KeyboardEvent):Void {
        keyStates.set(event.keysym.sym, false);
    }

    public static function isKeyDown(keyCode:KeyCode):Bool {
        return keyStates.exists(keyCode) ? keyStates.get(keyCode) : false;
    }
}
