import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result

pub type Type {
  A
  I
  U
  E
  O
  Ka
  Ki
  Ku
  Ke
  Ko
  Sa
  Si
  Su
  Se
  So
  Ta
  Ti
  Tu
  Te
  To
  Na
  Ni
  Nu
  Ne
  No
  Ha
  Hi
  Fu
  He
  Ho
  Ma
  Mi
  Mu
  Me
  Mo
  Ya
  Yu
  Yo
  Ra
  Ri
  Ru
  Re
  Ro
  Wa
  Wo
  Nn
}

pub const kana_list = [
  A,
  I,
  U,
  E,
  O,
  Ka,
  Ki,
  Ku,
  Ke,
  Ko,
  Sa,
  Si,
  Su,
  Se,
  So,
  Ta,
  Ti,
  Tu,
  Te,
  To,
  Na,
  Ni,
  Nu,
  Ne,
  No,
  Ha,
  Hi,
  Fu,
  He,
  Ho,
  Ma,
  Mi,
  Mu,
  Me,
  Mo,
  Ya,
  Yu,
  Yo,
  Ra,
  Ri,
  Ru,
  Re,
  Ro,
  Wa,
  Wo,
  Nn,
]

pub fn move(kana: Type, step: Int) -> Type {
  let index_dict =
    kana_list
    |> list.index_map(fn(a, i) { #(a, i) })
    |> dict.from_list
  let kana_dict =
    kana_list
    |> list.index_map(fn(a, i) { #(i, a) })
    |> dict.from_list
  let length = kana_list |> list.length
  let result = {
    use current_index <- result.try(index_dict |> dict.get(kana))
    use remainder <- result.try(int.remainder(current_index + step, length))
    let new_index = case remainder < 0 {
      True -> remainder + length
      False -> remainder
    }
    use new_kana <- result.try(kana_dict |> dict.get(new_index))
    Ok(new_kana)
  }

  case result {
    Ok(new_kana) -> new_kana
    Error(_) -> kana
  }
}

pub fn to_hiragana(kana: Type) -> String {
  case kana {
    A -> "あ"
    I -> "い"
    U -> "う"
    E -> "え"
    O -> "お"
    Ka -> "か"
    Ki -> "き"
    Ku -> "く"
    Ke -> "け"
    Ko -> "こ"
    Sa -> "さ"
    Si -> "し"
    Su -> "す"
    Se -> "せ"
    So -> "そ"
    Ta -> "た"
    Ti -> "ち"
    Tu -> "つ"
    Te -> "て"
    To -> "と"
    Na -> "な"
    Ni -> "に"
    Nu -> "ぬ"
    Ne -> "ね"
    No -> "の"
    Ha -> "は"
    Hi -> "ひ"
    Fu -> "ふ"
    He -> "へ"
    Ho -> "ほ"
    Ma -> "ま"
    Mi -> "み"
    Mu -> "む"
    Me -> "め"
    Mo -> "も"
    Ya -> "や"
    Yu -> "ゆ"
    Yo -> "よ"
    Ra -> "ら"
    Ri -> "り"
    Ru -> "る"
    Re -> "れ"
    Ro -> "ろ"
    Wa -> "わ"
    Wo -> "を"
    Nn -> "ん"
  }
}

pub const layout = [
  [
    Some(A),
    Some(I),
    Some(U),
    Some(E),
    Some(O),
  ],
  [
    Some(Ka),
    Some(Ki),
    Some(Ku),
    Some(Ke),
    Some(Ko),
  ],
  [
    Some(Sa),
    Some(Si),
    Some(Su),
    Some(Se),
    Some(So),
  ],
  [
    Some(Ta),
    Some(Ti),
    Some(Tu),
    Some(Te),
    Some(To),
  ],
  [
    Some(Na),
    Some(Ni),
    Some(Nu),
    Some(Ne),
    Some(No),
  ],
  [
    Some(Ha),
    Some(Hi),
    Some(Fu),
    Some(He),
    Some(Ho),
  ],
  [
    Some(Ma),
    Some(Mi),
    Some(Mu),
    Some(Me),
    Some(Mo),
  ],
  [
    Some(Ya),
    None,
    Some(Yu),
    None,
    Some(Yo),
  ],
  [
    Some(Ra),
    Some(Ri),
    Some(Ru),
    Some(Re),
    Some(Ro),
  ],
  [
    Some(Wa),
    None,
    None,
    None,
    Some(Wo),
  ],
  [
    Some(Nn),
    None,
    None,
    None,
    None,
  ],
]
