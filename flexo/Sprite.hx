package flexo;

import sdl.SDL;
import sdl.Surface;
import sdl.Texture;
import sdl.Image;
import haxe.Timer;

class Sprite {
    public var texture:Texture;
    public var textureSize:Point;
    public var position:Point;
    public var scale:FPoint;

    private var animations:Map<String, Array<Int>>;
    private var currentAnimation:String;
    private var currentFrame:Int;
    private var isAnimating:Bool;
    private var loopAnimation:Bool;
    private var animationTimer:Timer;

    private var frameWidth:Int;
    private var frameHeight:Int;

    public function new(frameWidth:Int = 0, frameHeight:Int = 0) {
        position = Point.create(0, 0);
        scale = FPoint.create(1, 1);
        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;

        animations = new Map<String, Array<Int>>();
        currentAnimation = "";
        currentFrame = 0;
        isAnimating = false;
        loopAnimation = false;
        animationTimer = new Timer(Std.int(1000 / 30));
        animationTimer.run = onAnimationFrame;
    }

    public function loadImage(path:String, frameWidth:Int = 0, frameHeight:Int = 0) {
        var surface:Surface = Image.load(path);
        if (surface == null) {
            Sys.println("Failed to load image: " + path);
            return;
        }

        texture = SDL.createTextureFromSurface(Flexo.renderer, surface);
        if (texture == null) {
            Sys.println("Failed to create texture from image: " + path);
            return;
        }

        if (frameWidth == 0 || frameHeight == 0) {
            textureSize = SDL.getTextureSize(texture);
            this.frameWidth = textureSize.x;
            this.frameHeight = textureSize.y;
        } else {
            this.frameWidth = frameWidth;
            this.frameHeight = frameHeight;
            textureSize = Point.create(frameWidth, frameHeight);
        }

        SDL.freeSurface(surface);
    }

    public function render():Void {
        if (isAnimating) {
            var frames:Array<Int> = animations.get(currentAnimation);
            if (frames != null && frames.length > 0 && currentFrame < frames.length) {
                renderFrame(frames[currentFrame]);
            }
        } else {
            var sourceRect:Rectangle = Rectangle.create(0, 0, textureSize.x, textureSize.y);
            var destinationRect:Rectangle = Rectangle.create(
                position.x,
                position.y,
                Std.int(textureSize.x * scale.x),
                Std.int(textureSize.y * scale.y)
            );
            SDL.renderCopy(Flexo.renderer, texture, sourceRect, destinationRect);
        }
    }

    public function addAnimation(name:String, frames:Array<Int>) {
        animations.set(name, frames);
    }

    public function playAnimation(name:String, loop:Bool = false) {
        if (!animations.exists(name)) {
            Sys.println("Animation '" + name + "' not found!");
            return;
        }

        currentAnimation = name;
        currentFrame = 0;
        isAnimating = true;
        loopAnimation = loop;
        animationTimer.stop();
        animationTimer.run();
    }

    private function onAnimationFrame() {
        if (!isAnimating) return;

        var frames:Array<Int> = animations.get(currentAnimation);
        if (frames == null || frames.length == 0) {
            Sys.println("No frames found for animation: " + currentAnimation);
            return;
        }

        if (currentFrame >= frames.length) {
            if (loopAnimation) {
                currentFrame = 0;
            } else {
                isAnimating = false;
                animationTimer.stop();
                return;
            }
        }

        renderFrame(frames[currentFrame]);
        currentFrame++;
    }

    private function renderFrame(frameIndex:Int) {
        var columns:Int = Std.int(textureSize.x / frameWidth);
        var rowIndex:Int = Std.int(frameIndex / columns);
        var columnIndex:Int = frameIndex % columns;
    
        var sourceRect:Rectangle = Rectangle.create(
            columnIndex * frameWidth,
            rowIndex * frameHeight,
            frameWidth,
            frameHeight
        );
    
        var destinationRect:Rectangle = Rectangle.create(
            position.x,
            position.y,
            Std.int(frameWidth * scale.x),
            Std.int(frameHeight * scale.y)
        );
    
        SDL.renderCopy(Flexo.renderer, texture, sourceRect, destinationRect);
    }

    public function setPosition(x:Int, y:Int):Void {
        position.x = x;
        position.y = y;
    }

    public function setScale(scaleX:Float, scaleY:Float):Void {
        scale.x = scaleX;
        scale.y = scaleY;
    }

    public static function cleanup() {
        Image.quit();
    }
}
