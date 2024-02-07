package flexo;

import sdl.SDL;
import sdl.Surface;
import sdl.Texture;
import sdl.Image;

class Sprite {
    public var texture:Texture;
    public var textureSize:Point;
    public var position:Point;
    public var scale:FPoint;
    public var animations:Map<String, Array<Int>>;
    public var currentAnimation:String;
    public var currentAnimationFrame:Int;
    public var isAnimationPlaying:Bool;
    public var loopAnimation:Bool;
    public var frameWidth:Int;
    public var frameHeight:Int;
    public var isSpriteSheet:Bool;
    public var animationSpeed:Float;
    public var animationAccumulator:Float;

    public function new() {
        position = Point.create(0, 0);
        scale = FPoint.create(1, 1);
        animations = new Map<String, Array<Int>>();
        currentAnimation = "";
        currentAnimationFrame = 0;
        isAnimationPlaying = false;
        loopAnimation = false;
        isSpriteSheet = false;
        animationSpeed = 1.0;
        animationAccumulator = 0.0;
    }

    public function loadImage(path:String, frameWidth:Int = 0, frameHeight:Int = 0, isSpriteSheet:Bool = false):Void {
        this.isSpriteSheet = isSpriteSheet;
        if (isSpriteSheet) {
            loadSpriteSheet(path, frameWidth, frameHeight);
        } else {
            loadSingleImage(path);
        }
    }

    private function loadSingleImage(path:String):Void {
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

        textureSize = SDL.getTextureSize(texture);
        SDL.freeSurface(surface);

        this.frameWidth = textureSize.x;
        this.frameHeight = textureSize.y;
    }

    private function loadSpriteSheet(path:String, frameWidth:Int, frameHeight:Int):Void {
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

        textureSize = SDL.getTextureSize(texture);
        SDL.freeSurface(surface);

        this.frameWidth = frameWidth;
        this.frameHeight = frameHeight;

        var framesPerRow:Int = Std.int(textureSize.x / frameWidth);
        var framesPerColumn:Int = Std.int(textureSize.y / frameHeight);
        for (i in 0...framesPerRow) {
            for (j in 0...framesPerColumn) {
                var frameIndex:Int = j * framesPerRow + i;
                var frameName:String = "Frame_" + frameIndex;
                animations.set(frameName, [frameIndex]);
            }
        }
    }

    public function addAnimation(name:String, frames:Array<Int>):Void {
        animations.set(name, frames);
    }

    public function playAnimation(name:String, loop:Bool = true):Void {
        currentAnimation = name;
        currentAnimationFrame = 0;
        isAnimationPlaying = true;
        loopAnimation = loop;
    }

    public function stopAnimation():Void {
        isAnimationPlaying = false;
    }

    public function setAnimationSpeed(speed:Float):Void {
        animationSpeed = speed;
    }

    public function update(dt:Float):Void {
        if (isAnimationPlaying) {
            animationAccumulator += dt * animationSpeed;
            while (animationAccumulator >= 1.0) {
                animationAccumulator -= 1.0;
                advanceAnimationFrame();
            }
        }
    }

    private function advanceAnimationFrame():Void {
        var frames:Array<Int> = animations.get(currentAnimation);
        if (currentAnimationFrame < frames.length - 1) {
            currentAnimationFrame++;
        } else if (loopAnimation) {
            currentAnimationFrame = 0;
        } else {
            stopAnimation();
        }
    }

    public function render(?targetX:Int = null, ?targetY:Int = null, ?targetWidth:Int = null, ?targetHeight:Int = null) {
        var srcRect:Rectangle;

        if (isSpriteSheet) {
            var frameIndex:Int = animations.get(currentAnimation)[currentAnimationFrame];
            var frameColumn:Int = Std.int(frameIndex % (textureSize.x / frameWidth));
            var frameRow:Int = Std.int(frameIndex / (textureSize.y / frameWidth));
            srcRect = Rectangle.create(frameWidth * frameColumn, frameHeight * frameRow, frameWidth, frameHeight);
        } else {
            srcRect = Rectangle.create(0, 0, textureSize.x, textureSize.y);
        }

        SDL.renderCopy(Flexo.renderer, texture,
            srcRect,
            Rectangle.create(
                targetX != null ? targetX : position.x,
                targetY != null ? targetY : position.y,
                targetWidth != null ? targetWidth : Std.int(frameWidth * scale.x),
                targetHeight != null ? targetHeight : Std.int(frameHeight * scale.y)
            )
        );
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
