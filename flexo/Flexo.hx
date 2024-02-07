package flexo;

import sdl.SDL;
import sdl.Window;
import sdl.Renderer;
import sdl.Image;
import sdl.Event;

class Flexo {
    public var width:Int;
    public var height:Int;
    public var title:String;
    public var isRunning:Bool;

    public static var window:Window;
    public static var renderer:Renderer;

    private var sprites:Array<flexo.Sprite>;
    private var lastFrameTime:Float;
    private var fpsCounter:Int;
    private var fpsDisplayTimer:Float;
    private var targetFPS:Float;
    private var frameDelay:Float;

    public function new(width:Int, height:Int, title:String, targetFPS:Float = 60.0) {
        this.width = width;
        this.height = height;
        this.title = title;
        this.targetFPS = Math.max(60.0, Math.min(targetFPS, 120.0));
        this.frameDelay = 1000.0 / this.targetFPS;

        sprites = new Array<flexo.Sprite>();
        lastFrameTime = 0;
        fpsCounter = 0;
        fpsDisplayTimer = 0;

        init();
    }

    public function init() {
		SDL.init(InitFlags.VIDEO | InitFlags.AUDIO | InitFlags.EVENTS);

        if (Image.init(EVERYTHING) == 0) {
            trace("Failed to initialize SDL_image");
            return;
        }

        sdl.ttf.TTF.init();

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

        isRunning = true;
        lastFrameTime = SDL.getTicks();
        startGameLoop();
    }

    public function handleEvents() {
        var event:Event = SDL.createEventPtr();
        while (SDL.pollEvent(event) != 0) {
            if (event.ref.type == QUIT) {
                isRunning = false;
            }
        }
    }

    public function update() {
        var currentTime:Float = SDL.getTicks();
        var elapsedTime:Float = currentTime - lastFrameTime;

        if (elapsedTime < frameDelay) {
            SDL.delay(Std.int(frameDelay - elapsedTime));
            return;
        }

        var deltaTime:Float = elapsedTime / 1000.0;

        fpsCounter++;
        fpsDisplayTimer += deltaTime;

        for (sprite in sprites) { sprite.update(deltaTime); }

        if (fpsDisplayTimer >= 1.0) {
            fpsCounter = 0;
            fpsDisplayTimer = 0;
        }

        lastFrameTime = currentTime;
    }

    public function render() {
        SDL.renderClear(renderer);
        for (sprite in sprites) { sprite.render(); }
        SDL.renderPresent(renderer);
    }

    public function addSprite(sprite:flexo.Sprite):Void {
        sprites.push(sprite);
    }

    public function removeSprite(sprite:flexo.Sprite):Void {
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
        flexo.Sprite.cleanup();

        SDL.destroyRenderer(renderer);
        SDL.destroyWindow(window);

        SDL.quit();
    }
}
