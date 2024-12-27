import gleam/list
import gleam/string_tree

pub type Processor(a, b) =
  fn(b, List(a), a, List(a)) -> #(b, List(a))

pub fn process(elements: List(a), state: b, processor: Processor(a, b)) -> b {
  process_loop([], elements, state, processor).0
}

fn process_loop(
  processed: List(a),
  remaining: List(a),
  state: b,
  processor: Processor(a, b),
) -> #(b, List(a)) {
  case remaining {
    [] -> #(state, [])
    [head, ..rest] -> {
      let #(state, remaining) = processor(state, processed, head, rest)
      process_loop([head, ..processed], remaining, state, processor)
    }
  }
}

pub fn process_next(
  processed: List(a),
  remaining: List(a),
  state: b,
  processor: Processor(a, b),
) -> #(b, List(a)) {
  case remaining {
    [] -> #(state, [])
    [head, ..rest] -> {
      processor(state, processed, head, rest)
    }
  }
}

pub fn is_uppercase(grapheme: String) -> Bool {
  case grapheme {
    "A"
    | "B"
    | "C"
    | "D"
    | "E"
    | "F"
    | "G"
    | "H"
    | "I"
    | "J"
    | "K"
    | "L"
    | "M"
    | "N"
    | "O"
    | "P"
    | "Q"
    | "R"
    | "S"
    | "T"
    | "U"
    | "V"
    | "W"
    | "X"
    | "Y"
    | "Z" -> True
    _ -> False
  }
}

pub fn is_lowercase(grapheme: String) -> Bool {
  case grapheme {
    "a"
    | "b"
    | "c"
    | "d"
    | "e"
    | "f"
    | "g"
    | "h"
    | "i"
    | "j"
    | "k"
    | "l"
    | "m"
    | "n"
    | "o"
    | "p"
    | "q"
    | "r"
    | "s"
    | "t"
    | "u"
    | "v"
    | "w"
    | "x"
    | "y"
    | "z" -> True
    _ -> False
  }
}

pub fn is_letter(grapheme: String) -> Bool {
  is_uppercase(grapheme) || is_lowercase(grapheme)
}

pub fn is_digit(grapheme: String) -> Bool {
  case grapheme {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

pub fn is_alphanumeric(grapheme: String) -> Bool {
  is_digit(grapheme) || is_letter(grapheme)
}

pub fn extract(
  items: List(a),
  keep: fn(List(a), a) -> Bool,
) -> Result(#(List(a), List(a)), Nil) {
  let #(acc, rest) = extract_loop(items, [], keep)
  case acc {
    [] -> Error(Nil)
    _ -> Ok(#(list.reverse(acc), rest))
  }
}

fn extract_loop(
  items: List(a),
  acc: List(a),
  keep: fn(List(a), a) -> Bool,
) -> #(List(a), List(a)) {
  case items {
    [] -> #(acc, items)
    [head, ..tail] ->
      case keep(acc, head) {
        True -> extract_loop(tail, [head, ..acc], keep)
        False -> #(acc, items)
      }
  }
}

pub fn extract_function_name(
  graphemes: List(String),
) -> Result(#(List(String), List(String)), Nil) {
  extract(graphemes, fn(acc, grapheme) {
    case acc {
      [] -> is_uppercase(grapheme)
      _ -> is_alphanumeric(grapheme)
    }
  })
}

pub fn graphemes_to_string(graphemes: List(String)) -> String {
  list.fold(graphemes, string_tree.new(), string_tree.append)
  |> string_tree.to_string
}
