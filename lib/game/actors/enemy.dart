import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:platformer/game/actors/player.dart';
import 'package:platformer/game/game.dart';

class Enemy extends SpriteComponent with CollisionCallbacks, HasGameRef<SimplePlatformer> {
  static final Vector2 _up = Vector2(0, -1);
  
  Enemy(
    Image image, {
    Vector2? targetPosition,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super.fromImage(
          image,
          srcPosition: Vector2(1 * 32, 0),
          srcSize: Vector2.all(32),
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {

          final effect = SequenceEffect(
            [
              MoveToEffect(
                targetPosition!, 
                EffectController(
                  speed: 100,
                ),
                onComplete: () => flipHorizontallyAroundCenter()
              ),
              MoveToEffect(
                position! + Vector2(32, 0),
                EffectController(
                  speed: 100,
                ),
                onComplete: () => flipHorizontallyAroundCenter()
              ),
            ],
            infinite: true,
          );
          add(effect);
        }
  
  @override
  Future<void>? onLoad() {
    add(CircleHitbox()..collisionType = CollisionType.passive);
    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      final playerDir = (other.absoluteCenter - absoluteCenter).normalized();
      
      if (playerDir.dot(_up) > 0.85) {
        add(
          OpacityEffect.fadeOut(
            LinearEffectController(0.2),
            onComplete: () => removeFromParent(),
          )
        );
        other.jump();
      } else {
        other.hit();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

