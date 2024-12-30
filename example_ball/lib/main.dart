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
  Vector2 lastDragPosition = Vector2.zero(); // 新たに追加
  final double gravity = 500;
  final double restitution = 0.3; // 反発係数
  final double damping = 0.99; // 減衰係数

  Ball() {
    anchor = Anchor.center; // 画像の中心を回転の軸として設定
  }

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

      // ボールの回転を更新
      updateRotation(dt);

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

  void updateRotation(double dt) {
    const double rotationSpeed = 0.06;
    angle += velocity.x * rotationSpeed * dt;

    if (angle > 2 * 3.14159) {
      angle -= 2 * 3.14159;
    } else if (angle < 0) {
      angle += 2 * 3.14159;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    beingHeld = true;
    velocity = Vector2.zero();
    lastDragPosition = event.localPosition; // タップ開始位置を保存
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (beingHeld) {
      final dragDelta = event.localPosition - lastDragPosition;
      position += dragDelta;
      lastDragPosition = event.localPosition; // 現在の位置を更新
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    beingHeld = false;
    velocity = event.velocity;
  }
}
