import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: BasketballGame(),
    ),
  );
}

class BasketballGame extends FlameGame with HasCollisionDetection {
  late Ball ball;

  @override
  Future<void> onLoad() async {
    // ボールを追加
    ball = Ball()
      ..position = size / 2
      ..size = Vector2(50, 50); // ボールのサイズ
    add(ball);
  }
}

class Ball extends SpriteComponent with CollisionCallbacks, TapCallbacks, DragCallbacks {
  Vector2 velocity = Vector2.zero();
  bool beingHeld = false;
  final double gravity = 500;
  final double restitution = 0.5; // 反発係数
  final double damping = 0.99; // 減衰係数

  Ball();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ball.png'); // ボール画像をロード
    add(CircleHitbox()); // 当たり判定
  }

  @override
  void update(double dt) {
    super.update(dt);
    final game = this.findGame() as BasketballGame;
    if (!beingHeld) {
      // 重力を適用
      velocity.y += gravity * dt;
      position += velocity * dt;

      // 減衰効果を適用
      velocity *= damping;

      // 画面端で跳ね返るロジック
      if (position.x < 0 || position.x + size.x > game.size.x) {
        velocity.x = -velocity.x;
        position.x = position.x.clamp(0, game.size.x - size.x);
      }

      if (position.y < 0) {
        velocity.y = -velocity.y * restitution;
        position.y = 0;
      }

      if (position.y + size.y > game.size.y) {
        velocity.y = -velocity.y * restitution; // 反発係数を使用
        position.y = game.size.y - size.y;
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    beingHeld = true;
    velocity = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (beingHeld) {
      position += event.delta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    beingHeld = false;
    velocity = event.velocity;
  }
}