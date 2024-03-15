package flexo;

import sdl.SDL;
import sdl.Window;
import sdl.Renderer;
import sdl.Surface;
import sdl.Image;
import sdl.Event;

class Flexo {
    public var width:Int;
    public var height:Int;
    public var title:String;
    public var icon:String;
    public var isRunning:Bool;

    public static var window:Window;
    public static var renderer:Renderer;
    public static var elapsed:Float = 0.0;
    public static var lastTime:Float = Sys.time();
    public static var keyStates:Map<Int, Bool>;

    private var sprites:Array<Sprite>;

    public function new(width:Int, height:Int, title:String, ?icon:String) {
        this.width = width;
        this.height = height;
        this.title = title;
        this.icon = icon;

        sprites = new Array<Sprite>();

        init();
    }

    public function init() {
		SDL.init(InitFlags.VIDEO | InitFlags.AUDIO | InitFlags.EVENTS);

        if (Image.init(EVERYTHING) == 0) {
            trace("Failed to initialize SDL_image");
            return;
        }

        sdl.ttf.TTF.init();
        keyStates = new Map<Int, Bool>();

        window = SDL.createWindow(title, WindowPos.CENTERED, WindowPos.CENTERED, width, height, WindowInitFlags.RESIZABLE | WindowInitFlags.ALLOW_HIGHDPI);
        if (window == null) {
            Sys.println("Window creation failed");
            return;
        }

        renderer = SDL.createRenderer(window, -1, RenderFlags.ACCELERATED);
        if (renderer == null) {
            Sys.println("Renderer creation failed");
            return;
        }

        if (sys.FileSystem.exists(icon)) {
            var iconSurface:Surface = Image.load(icon);
            SDL.setWindowIcon(window, iconSurface);
            SDL.freeSurface(iconSurface);
        }

        isRunning = true;
        startGameLoop();
    }

    public function handleEvents() {
        var event:Event = SDL.createEventPtr();
        while (SDL.pollEvent(event) != 0) {
            if (event.ref.type == QUIT) {
                isRunning = false;
            } else if (event.ref.type == KEYDOWN) {
                keyStates.set(event.ref.key.keysym.sym, true);
            } else if (event.ref.type == KEYUP) {
                keyStates.set(event.ref.key.keysym.sym, false);
            }
        }
    }

    public static function isKeyDown(keyCode:Int):Bool {
        return keyStates.exists(keyCode) && keyStates.get(keyCode);
    }

    public function update() {
        var currentTime:Float = Sys.time();
        var deltaTime:Float = currentTime - lastTime;
        lastTime = currentTime;
        elapsed = deltaTime;
        for (sprite in sprites) {
            if (sprite.isSpriteSheet) {
                sprite.update();
            }
        }
        SDL.delay(16);
    }

    public function render() {
        SDL.renderClear(renderer);
        for (sprite in sprites) { sprite.render(); }
        SDL.renderPresent(renderer);
    }

    public function addSprite(sprite:Sprite):Void {
        sprites.push(sprite);
    }

    public function removeSprite(sprite:Sprite):Void {
        var index:Int = sprites.indexOf(sprite);
        if (index != -1) {
            sprites.splice(index, 1);
        }
    }

    function startGameLoop() {
        while (isRunning) {
            handleEvents();
            update();
            render();
        }
        cleanup();
    }

    public function cleanup() {
        Sprite.cleanup();

        SDL.destroyRenderer(renderer);
        SDL.destroyWindow(window);

        SDL.quit();
    }
}
