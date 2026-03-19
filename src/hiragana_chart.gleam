import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import hiragana_chart/kana
import lustre/attribute
import lustre/element/html
import lustre/event

type Number =
  Int

type SelectedKana =
  dict.Dict(kana.Type, Number)

type MovedKana =
  dict.Dict(#(kana.Type, Number), Int)

pub opaque type Direction {
  Up
  Down
}

pub type Model {
  Model(
    selected_kana: SelectedKana,
    moved_kana: MovedKana,
    remaining_numbers: List(Number),
  )
}

pub fn init() -> Model {
  Model(dict.from_list([]), dict.from_list([]), list.range(1, 10))
}

pub type Msg {
  UserSelectedCell(kana.Type)
  UserDeselectedCell(kana.Type)
  UserMovedSelectedCharacter(#(kana.Type, Number), Direction)
  UserMovedAllSelectedCharacters(Direction)
}

const default_moving_step = 0

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectedCell(kana) -> {
      case model.remaining_numbers {
        [] -> model
        [first, ..rest] -> {
          Model(
            ..model,
            selected_kana: model.selected_kana |> dict.insert(kana, first),
            remaining_numbers: rest,
          )
        }
      }
    }
    UserDeselectedCell(kana) -> {
      case dict.get(model.selected_kana, kana) {
        Ok(number) -> {
          Model(
            selected_kana: dict.delete(model.selected_kana, kana),
            moved_kana: dict.delete(model.moved_kana, #(kana, number)),
            remaining_numbers: list.prepend(model.remaining_numbers, number),
          )
        }
        Error(_) -> model
      }
    }
    UserMovedAllSelectedCharacters(direction) -> {
      let step = 1
      let moved_kana =
        model.selected_kana
        |> dict.to_list
        |> list.fold(model.moved_kana, fn(acc, entry) {
          let #(k, number) = entry
          let key = #(k, number)
          let current = acc |> dict.get(key) |> result.unwrap(default_moving_step)
          let new_offset = case direction {
            Up -> current - step
            Down -> current + step
          }
          dict.insert(acc, key, new_offset)
        })
      Model(..model, moved_kana:)
    }
    UserMovedSelectedCharacter(numbered_character, direction) -> {
      let step = 1
      let current =
        model.moved_kana
        |> dict.get(numbered_character)
        |> result.unwrap(default_moving_step)
      let new_offset = case direction {
        Up -> current - step
        Down -> current + step
      }
      let moved_kana =
        model.moved_kana
        |> dict.insert(numbered_character, new_offset)
      Model(..model, moved_kana:)
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
    [
      view_selected_text(model.selected_kana, model.moved_kana),
      view_chart(
        list.map(
          kana.layout,
          list.map(_, determine_cell_status(
            _,
            model.selected_kana,
            model.moved_kana,
          )),
        ),
      ),
    ],
  )
}

fn view_selected_text(selected, moved_kana) {
  let sorted =
    selected
    |> dict.to_list
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })

  html.div(
    [
      attribute.class(
        "flex justify-center items-center w-[calc(var(--cell-size)*11)] mb-[calc(var(--cell-size)*0.2)] text-[calc(var(--cell-size)*0.4)]",
      ),
    ],
    [
      html.div(
        [attribute.class("flex flex-col items-center text-[calc(var(--cell-size)*0.3)]")],
        [
          html.button(
            [
              attribute.class("leading-none hover:opacity-70 cursor-pointer"),
              event.on_click(UserMovedAllSelectedCharacters(Up)),
            ],
            [html.text("↑")],
          ),
          html.span(
            [attribute.class("text-[calc(var(--cell-size)*0.4)] leading-none")],
            [html.text("選択中：")],
          ),
          html.button(
            [
              attribute.class("leading-none hover:opacity-70 cursor-pointer"),
              event.on_click(UserMovedAllSelectedCharacters(Down)),
            ],
            [html.text("↓")],
          ),
        ],
      ),
      html.div(
        [
          attribute.class(
            "w-[calc(var(--cell-size)*4.5)] tracking-widest whitespace-nowrap overflow-hidden",
          ),
          attribute.styles([#("display", "flex")]),
        ],
        sorted |> list.map(view_selected_character(_, moved_kana)),
      ),
    ],
  )
}

fn view_selected_character(numbered_character: #(kana.Type, Number), moved_kana) {
  let offset =
    moved_kana
    |> dict.get(numbered_character)
    |> result.unwrap(default_moving_step)
  let display_kana = kana.move(numbered_character.0, offset)
  html.div(
    [
      attribute.class(
        "flex flex-col items-center w-[var(--cell-size)] text-[calc(var(--cell-size)*0.3)]",
      ),
    ],
    [
      html.button(
        [
          attribute.class("leading-none hover:opacity-70 cursor-pointer"),
          event.on_click(UserMovedSelectedCharacter(numbered_character, Up)),
        ],
        [html.text("↑")],
      ),
      html.span(
        [attribute.class("text-[calc(var(--cell-size)*0.5)] leading-none")],
        [html.text(kana.to_hiragana(display_kana))],
      ),
      html.button(
        [
          attribute.class("leading-none hover:opacity-70 cursor-pointer"),
          event.on_click(UserMovedSelectedCharacter(numbered_character, Down)),
        ],
        [html.text("↓")],
      ),
    ],
  )
}

fn determine_cell_status(
  maybe_kana: option.Option(kana.Type),
  selected_kana: SelectedKana,
  moved_kana: MovedKana,
) -> CellStatus {
  case maybe_kana {
    None -> Empty
    Some(cell_kana) ->
      case dict.get(selected_kana, cell_kana) {
        Ok(number) -> Selected(cell_kana, number)
        Error(_) -> {
          let moved_here =
            moved_kana
            |> dict.to_list
            |> list.find(fn(entry) {
              let #(#(orig_kana, _), offset) = entry
              kana.move(orig_kana, offset) == cell_kana
            })
          case moved_here {
            Ok(#(#(_, number), _)) -> Moved(cell_kana, number)
            Error(_) -> Default(cell_kana)
          }
        }
      }
  }
}

fn view_chart(cell_status_layout) {
  html.div([attribute.class("flex justify-center")], [
    html.div(
      [
        attribute.class(
          "flex flex-row-reverse border-t border-l border-gray-200 dark:border-gray-700",
        ),
      ],
      cell_status_layout |> list.map(view_column),
    ),
  ])
}

fn view_column(column) {
  html.div([attribute.class("flex flex-col")], list.map(column, view_cell))
}

type CellStatus {
  Default(kana.Type)
  Empty
  Selected(kana.Type, Number)
  Moved(kana.Type, Number)
}

fn view_cell(cell_status) {
  case cell_status {
    Default(kana) -> view_default_cell(kana)
    Empty -> view_empty_cell()
    Selected(kana, number) -> view_selected_cell(kana, number)
    Moved(kana, number) -> view_moved_cell(kana, number)
  }
}

fn view_default_cell(kana: kana.Type) {
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

fn view_moved_cell(kana, moved_position) {
  html.button(
    [
      attribute.class(
        "w-[var(--cell-size)] h-[var(--cell-size)] text-[calc(var(--cell-size)*0.5)] border-r border-b border-amber-600 dark:border-amber-500 bg-amber-500 dark:bg-amber-400 text-white cursor-pointer",
      ),
      event.on_click(UserDeselectedCell(kana)),
    ],
    [html.text(moved_position |> int.to_string)],
  )
}
