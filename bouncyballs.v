import gg
import gx
import rand
import math

struct Ball {
mut:
	radius f32
	color  gx.Color
	xpos   f32
	ypos   f32
	xvel   f32
	yvel   f32
}

struct App {
mut:
	gg    &gg.Context = 0
	balls []Ball
}

fn make_balls(count int) []Ball {
	mut ball_arr := []Ball{cap: count}
	for _ in 0 .. count {
		ball_arr << {
			radius: rand.f32_in_range(5, 10)
			color: gx.white
			xpos: rand.f32_in_range(0, 800)
			ypos: rand.f32_in_range(0, 800)
			xvel: rand.f32_in_range(-0.5, 0.5)
			yvel: rand.f32_in_range(-0.5, 0.5)
		}
	}
	return ball_arr
}

fn in_bounds(mut ball Ball) {
	if ball.xpos + ball.radius > 800 {
		ball.xpos = 800 - ball.radius
		ball.xvel = -ball.xvel
	}
	if ball.xpos - ball.radius < 0 {
		ball.xpos = 0 + ball.radius
		ball.xvel = -ball.xvel
	}
	if ball.ypos + ball.radius > 800 {
		ball.ypos = 800 - ball.radius
		ball.yvel = -ball.yvel
	}
	if ball.ypos - ball.radius < 0 {
		ball.ypos = 0 + ball.radius
		ball.yvel = -ball.yvel
	}
}

fn aabb(ball_one Ball, ball_two Ball) bool {
	mut count := 0
	if ball_one.xpos < ball_one.xpos + ball_one.radius * 2 {
		count++
	}
	if ball_one.xpos + ball_one.radius * 2 > ball_one.xpos {
		count++
	}
	if ball_one.ypos < ball_one.ypos + ball_one.radius * 2 {
		count++
	}
	if ball_one.ypos + ball_one.radius * 2 > ball_one.ypos {
		count++
	}
	if count == 4 {
		return true
	}
	return false
}

fn collision(ball_one Ball, ball_two Ball) bool {
	dist_x := ball_one.xpos - ball_two.xpos
	dist_y := ball_one.ypos - ball_two.ypos
	dist := math.hypot(dist_x, dist_y)

	min_dist := ball_one.radius + ball_two.radius
	if dist < min_dist {
		if dist != 0 {
			return true
		}
	}
	return false
}

fn rectify_collision(mut ball_one Ball, mut ball_two Ball) {
	new_x1 := (ball_one.xvel * (ball_one.radius - ball_two.radius) +
		(2 * ball_two.radius * ball_two.xvel)) / (ball_one.radius + ball_two.radius)
	new_y1 := (ball_one.yvel * (ball_one.radius - ball_two.radius) +
		(2 * ball_two.radius * ball_two.yvel)) / (ball_one.radius + ball_two.radius)
	new_x2 := (ball_two.xvel * (ball_two.radius - ball_one.radius) +
		(2 * ball_one.radius * ball_one.xvel)) / (ball_one.radius + ball_two.radius)
	new_y2 := (ball_two.yvel * (ball_two.radius - ball_one.radius) +
		(2 * ball_one.radius * ball_one.yvel)) / (ball_one.radius + ball_two.radius)

	ball_one.xvel = new_x1
	ball_one.yvel = new_y1
	ball_two.xvel = new_x2
	ball_two.yvel = new_y2

	// ball_one.xpos += ball_one.xvel
	// ball_one.ypos += ball_one.yvel
	// ball_two.xpos += ball_two.xvel
	// ball_two.ypos += ball_two.yvel

	for collision(ball_one, ball_two) {
		ball_one.xpos += ball_one.xvel
		ball_one.ypos += ball_one.yvel
		ball_two.xpos += ball_two.xvel
		ball_two.ypos += ball_two.yvel
	}

	ball_one.color = gx.rgb(byte(rand.i64_in_range(0, 255)), byte(rand.i64_in_range(0,
		255)), byte(rand.i64_in_range(0, 255)))
	ball_two.color = gx.rgb(byte(rand.i64_in_range(0, 255)), byte(rand.i64_in_range(0,
		255)), byte(rand.i64_in_range(0, 255)))
}

fn on_frame(mut app App) {
	for mut ball in app.balls {
		ball.xpos += ball.xvel
		ball.ypos += ball.yvel
		in_bounds(mut ball)
		// ball.color = gx.white
	}

	for mut ball_one in app.balls {
		for mut ball_two in app.balls {
			if aabb(ball_one, ball_two) {
				if collision(ball_one, ball_two) {
					rectify_collision(mut ball_one, mut ball_two)
				}
			}
		}
	}

	app.gg.begin()

	for mut ball in app.balls {
		app.gg.draw_circle(ball.xpos, ball.ypos, ball.radius, ball.color)
	}
	app.gg.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		else {}
	}
}

fn main() {
	mut app := &App{}

	app.balls = make_balls(int(rand.i64_in_range(200, 1000)))

	app.gg = gg.new_context(
		width: 800
		height: 800
		window_title: 'bouncy balls'
		bg_color: gx.black
		use_ortho: true
		user_data: app
		frame_fn: on_frame
		event_fn: on_event
	)

	app.gg.run()
}
