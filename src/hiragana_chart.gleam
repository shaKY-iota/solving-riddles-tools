import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import hiragana_chart/kana
import lustre/attribute
import lustre/element/html
import lustre/event

type Number =
  Int

type SelectedKana =
  dict.Dict(kana.Type, Number)

pub type Model {
  Model(selected_kana: SelectedKana, remaining_numbers: List(Number))
}

pub fn init() -> Model {
  Model(dict.from_list([]), list.range(1, 10))
}

pub type Msg {
  UserSelectedCell(kana.Type)
  UserDeselectedCell(kana.Type)
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectedCell(kana) -> {
      case model.remaining_numbers {
        [] -> model
        [first, ..rest] -> {
          Model(
            selected_kana: model.selected_kana |> dict.insert(kana, first),
            remaining_numbers: rest,
          )
        }
      }
    }
    UserDeselectedCell(kana) -> {
      case dict.get(model.selected_kana, kana) {
        Ok(number) -> {
          let updated = dict.delete(model.selected_kana, kana)
          Model(
            selected_kana: updated,
            remaining_numbers: list.prepend(model.remaining_numbers, number),
          )
        }
        Error(_) -> model
      }
    }
  }
}

pub fn view(model: Model) {
  html.div([], [
    view_selected(model.selected_kana),
    view_chart(model.selected_kana),
  ])
}

fn view_selected(selected) {
  html.p([], [
    html.text(
      "選択中："
      <> selected
      |> dict.to_list
      |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
      |> list.map(fn(a) { kana.to_hiragana(a.0) })
      |> string.join(""),
    ),
  ])
}

fn view_chart(selected_kana) {
  html.div(
    [
      attribute.style("display", "flex"),
      attribute.style("flex-direction", "row-reverse"),
    ],
    list.map(kana.layout, view_column(_, selected_kana)),
  )
}

fn view_column(column, selected_kana) {
  html.div(
    [
      attribute.style("display", "flex"),
      attribute.style("flex-direction", "column"),
    ],
    list.map(column, view_cell(_, selected_kana)),
  )
}

fn view_cell(maybe_kana, selected_kana) {
  case maybe_kana, maybe_kana |> option.map(dict.get(selected_kana, _)) {
    None, _ -> view_empty_cell()
    Some(kana), Some(Ok(number)) -> view_selected_cell(kana, number)
    Some(kana), _ -> view_not_selected_cell(kana)
  }
}

fn view_not_selected_cell(kana: kana.Type) {
  html.button(
    [
      attribute.style("width", "40px"),
      attribute.style("height", "40px"),
      event.on_click(UserSelectedCell(kana)),
    ],
    [html.text(kana.to_hiragana(kana))],
  )
}

fn view_selected_cell(kana, remaining_numbers) {
  html.button(
    [
      attribute.style("width", "40px"),
      attribute.style("height", "40px"),
      attribute.style("background-color", "blue"),
      attribute.style("color", "white"),
      event.on_click(UserDeselectedCell(kana)),
    ],
    [html.text(remaining_numbers |> int.to_string)],
  )
}

fn view_empty_cell() {
  html.div(
    [
      attribute.style("width", "40px"),
      attribute.style("height", "40px"),
      attribute.style("background-color", "black"),
    ],
    [],
  )
}
