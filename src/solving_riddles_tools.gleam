import gleam/io
import hiragana_chart
import lustre
import lustre/element.{map}

pub fn main() -> Nil {
  io.println("Hello from solving_riddles_tools!")

  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(hiragana_chart_model: hiragana_chart.Model)
}

fn init(_args) -> Model {
  Model(hiragana_chart.init())
}

type Msg {
  HcMsg(hiragana_chart.Msg)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    HcMsg(msg) ->
      Model(hiragana_chart_model: hiragana_chart.update(
        model.hiragana_chart_model,
        msg,
      ))
  }
}

fn view(model: Model) {
  map(hiragana_chart.view(model.hiragana_chart_model), HcMsg)
}
