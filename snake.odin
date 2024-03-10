package main

import "core:fmt"
import "vendor:raylib"

SNAKE_LENGTH :: 256
SQUARE_SIZE :: 31

Snake :: struct {
	position: raylib.Vector2,
	size:     raylib.Vector2,
	speed:    raylib.Vector2,
	color:    raylib.Color,
}

Food :: struct {
	position: raylib.Vector2,
	size:     raylib.Vector2,
	active:   bool,
	color:    raylib.Color,
}
//--------------
//Globals
//--------------
screenWidth: int = 800
screenHeight: int = 450

framesCounter: int = 0
gameOver: bool = false
pause: bool = false

fruit: Food = {0, 0, false, raylib.BLUE}
snake: [SNAKE_LENGTH]Snake = {
	0 ..< 256 = {0, 0, 0, raylib.GREEN},
}
snakePos: [SNAKE_LENGTH]raylib.Vector2 = {
	0 ..< 256 = 0,
}
allowMove: bool = false
offset: raylib.Vector2 = {0, 0}
counterTail: int = 0
//--------------
// Module functions
//--------------
InitGame :: proc() {
	framesCounter = 0
	gameOver = false
	pause = false

	counterTail = 1
	allowMove = false

	offset.x = f32(screenWidth % SQUARE_SIZE)
	offset.y = f32(screenHeight % SQUARE_SIZE)

	for i := 0; i < SNAKE_LENGTH; i += 1 {
		snake[i].position = {offset.x / 2, offset.y / 2}
		snake[i].size = raylib.Vector2{SQUARE_SIZE, SQUARE_SIZE}
		snake[i].speed = raylib.Vector2{SQUARE_SIZE, 0}

		if i == 0 {
			snake[i].color = raylib.DARKBLUE
		} else {snake[i].color = raylib.BLUE}
	}

	for i := 0; i < SNAKE_LENGTH; i += 1 {
		snakePos[i] = raylib.Vector2{0.0, 0.0}
	}
	fruit.size = raylib.Vector2{SQUARE_SIZE, SQUARE_SIZE}
	fruit.color = raylib.PURPLE
	fruit.active = false
}

KeyboardControls :: proc() {
	if raylib.IsKeyPressed(raylib.KeyboardKey.RIGHT) &&
	   snake[0].speed.x == 0 &&
	   allowMove {
		snake[0].speed = raylib.Vector2{SQUARE_SIZE, 0}
		allowMove = false
	}
	if raylib.IsKeyPressed(raylib.KeyboardKey.LEFT) &&
	   snake[0].speed.x == 0 &&
	   allowMove {
		snake[0].speed = raylib.Vector2{-SQUARE_SIZE, 0}
		allowMove = false
	}
	if raylib.IsKeyPressed(raylib.KeyboardKey.UP) &&
	   snake[0].speed.y == 0 &&
	   allowMove {
		snake[0].speed = raylib.Vector2{0, -SQUARE_SIZE}
		allowMove = false
	}
	if raylib.IsKeyPressed(raylib.KeyboardKey.DOWN) &&
	   snake[0].speed.y == 0 &&
	   allowMove {
		snake[0].speed = raylib.Vector2{0, SQUARE_SIZE}
		allowMove = false
	}
}

SnakeMovement :: proc() {
	for i := 0; i < counterTail; i += 1 {
		snakePos[i] = snake[i].position
	}
	if framesCounter % 5 == 0 {
		for i := 0; i < counterTail; i += 1 {
			if i == 0 {
				snake[0].position.x += snake[0].speed.x
				snake[0].position.y += snake[0].speed.y
				allowMove = true
			} else {
				snake[i].position = snakePos[i - 1]
			}
		}
	}
}

GenerateFruitPosition :: proc() -> raylib.Vector2 {
	fruitPosX := f32(
		raylib.GetRandomValue(
			0,
			i32(
				((screenWidth / SQUARE_SIZE) - 1) * SQUARE_SIZE +
				int(offset.x / 2),
			),
		),
	)
	fruitPosY := f32(
		raylib.GetRandomValue(
			0,
			i32(
				((screenHeight / SQUARE_SIZE) - 1) * SQUARE_SIZE +
				int(offset.y / 2),
			),
		),
	)
	return raylib.Vector2{fruitPosX, fruitPosY}
}

PositionFruits :: proc() {
	if !fruit.active {
		fmt.println(fruit.active)
		fruit.active = true
		fmt.println(fruit.active)
		fruit.position = GenerateFruitPosition()

		for i := 0; i < counterTail; i += 1 {
			isSnakeOverFruitX: bool = fruit.position.x == snake[i].position.x
			isSnakeOverFruitY: bool = fruit.position.y == snake[i].position.y
			isSnakeOverFruit: bool = isSnakeOverFruitX && isSnakeOverFruitY
			for isSnakeOverFruit {
				fruit.position = GenerateFruitPosition()
				i = 0
			}
		}
	}
}

SelfCollision :: proc() {
	for i := 1; i < counterTail; i += 1 {
		isHeadOverBodyX := snake[0].position.x == snake[i].position.x
		isHeadOverBodyY := snake[0].position.y == snake[i].position.y
		isHeadOverBody := isHeadOverBodyX && isHeadOverBodyY
		if isHeadOverBody {
			gameOver = true
		}
	}
}

Collision :: proc() {
	snkOverFruitX := snake[0].position.x < (fruit.position.x + fruit.size.x)
	snkOverFruitX2 :=
		(snake[0].position.x + snake[0].size.x) > fruit.position.x
	snkOverFruitY := snake[0].position.y < (fruit.position.y + fruit.size.y)
	snkOverFruitY2 :=
		(snake[0].position.y + snake[0].size.y) > fruit.position.y
	snkOX := snkOverFruitX && snkOverFruitX2
	snkOY := snkOverFruitY && snkOverFruitY2
	if snkOX && snkOY {
		snake[counterTail].position = snakePos[counterTail - 1]
		counterTail += 1
		fruit.active = false
	}
}

UpdateGame :: proc() {
	if !gameOver {
		if raylib.IsKeyPressed(raylib.KeyboardKey.P) {pause = !pause}
		if !pause {
			KeyboardControls()
			SnakeMovement()
			SelfCollision()
			PositionFruits()
			Collision()
			framesCounter += 1
		}
	}

}
DrawGame :: proc() {
	raylib.BeginDrawing()
	raylib.DrawFPS(10, 10)
	raylib.ClearBackground(raylib.RAYWHITE)
	if !gameOver {
		for i := 0; i < counterTail; i += 1 {
			raylib.DrawRectangleV(
				snake[i].position,
				snake[i].size,
				snake[i].color,
			)
		}
		raylib.DrawRectangleV(fruit.position, fruit.size, fruit.color)
	}
	raylib.EndDrawing()
}

UnloadGame :: proc() {}

UpdateDrawFrame :: proc() {
	UpdateGame()
	DrawGame()
}


main :: proc() {
	raylib.InitWindow(1920, 1080, "Snake")
	raylib.ToggleFullscreen()
	InitGame()

	raylib.SetTargetFPS(60)

	for !raylib.WindowShouldClose() {
		UpdateDrawFrame()
	}

	UnloadGame()
	raylib.CloseWindow()
}
