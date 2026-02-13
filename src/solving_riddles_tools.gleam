import gleam/io
import lustre
import lustre/element/html

pub fn main() -> Nil {
  io.println("Hello from solving_riddles_tools!")

  let app = lustre.element(html.text("Hello, world!"))
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
