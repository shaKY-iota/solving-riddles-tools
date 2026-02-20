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
  html.div(
    [
      attribute.class(
        "flex flex-col items-center min-h-screen p-2 bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100 portrait:fixed portrait:min-h-0 portrait:-rotate-90 portrait:w-[100svh] portrait:h-[100svw] portrait:top-[calc((100svh_-_100svw)_/_2)] portrait:left-[calc((100svw_-_100svh)_/_2)]",
      ),
    ],
    [view_selected(model.selected_kana), view_chart(model.selected_kana)],
  )
}

fn view_selected(selected) {
  let kana_text =
    selected
    |> dict.to_list
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
    |> list.map(fn(a) { kana.to_hiragana(a.0) })
    |> string.join("")

  html.div(
    [
      attribute.class(
        "flex justify-center items-center w-[calc(var(--cell-size)*11)] mb-[calc(var(--cell-size)*0.2)] text-[calc(var(--cell-size)*0.4)]",
      ),
    ],
    [
      html.span([], [html.text("選択中：")]),
      html.span(
        [
          attribute.class(
            "w-[calc(var(--cell-size)*4.5)] tracking-widest whitespace-nowrap overflow-hidden",
          ),
        ],
        [html.text(kana_text)],
      ),
    ],
  )
}

fn view_chart(selected_kana) {
  html.div([attribute.class("flex justify-center")], [
    html.div(
      [
        attribute.class(
          "flex flex-row-reverse border-t border-l border-gray-200 dark:border-gray-700",
        ),
      ],
      list.map(kana.layout, view_column(_, selected_kana)),
    ),
  ])
}

fn view_column(column, selected_kana) {
  html.div(
    [attribute.class("flex flex-col")],
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
      attribute.class(
        "w-[var(--cell-size)] h-[var(--cell-size)] text-[calc(var(--cell-size)*0.5)] border-r border-b border-gray-200 dark:border-gray-700 hover:bg-gray-100 dark:hover:bg-gray-800 dark:text-white cursor-pointer",
      ),
      event.on_click(UserSelectedCell(kana)),
    ],
    [html.text(kana.to_hiragana(kana))],
  )
}

fn view_selected_cell(kana, remaining_numbers) {
  html.button(
    [
      attribute.class(
        "w-[var(--cell-size)] h-[var(--cell-size)] text-[calc(var(--cell-size)*0.5)] border-r border-b border-blue-700 dark:border-blue-700 bg-blue-600 dark:bg-blue-500 text-white cursor-pointer",
      ),
      event.on_click(UserDeselectedCell(kana)),
    ],
    [html.text(remaining_numbers |> int.to_string)],
  )
}

fn view_empty_cell() {
  html.div(
    [
      attribute.class(
        "w-[var(--cell-size)] h-[var(--cell-size)] border-r border-b border-gray-200 dark:border-gray-700 bg-black dark:bg-gray-800",
      ),
    ],
    [],
  )
}
