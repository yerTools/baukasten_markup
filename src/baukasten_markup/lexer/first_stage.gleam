/// This module is a first stage lexer for the BKM language.
/// It's not meant to be used directly, but only as a dependency for the
/// second stage lexer.
/// It splits the input into graphemes, handles escaping and 
/// normalizes whitespace and new lines. 
import gleam/list
import gleam/regexp
import gleam/string

pub type Position {
  Position(index: Int, line: Int, offset: Int)
}

pub type Grapheme {
  Grapheme(grapheme: String, is_escaped: Bool, position: Position)
}

pub fn is_whitespace(grapheme: Grapheme) -> Bool {
  case grapheme.is_escaped, grapheme.grapheme {
    False, " " | False, "\t" -> True
    _, _ -> False
  }
}

pub fn is_new_line(grapheme: Grapheme) -> Bool {
  case grapheme.is_escaped, grapheme.grapheme {
    False, "\n" -> True
    _, _ -> False
  }
}

pub fn to_graphemes(input: String) -> List(Grapheme) {
  let #(accumulator, _, _) =
    string.to_graphemes(input)
    |> list.fold(#([], False, Position(0, 1, 0)), fn(state, grapheme) {
      let #(accumulator, is_escaped, position) = state

      case grapheme, accumulator {
        "\n", [Grapheme("\r", grapheme_is_escaped, grapheme_position), ..rest] -> #(
          [Grapheme("\n", grapheme_is_escaped, grapheme_position), ..rest],
          is_escaped,
          Position(..position, index: position.index + 1),
        )
        _, _ -> {
          let next_position = case grapheme {
            "\r" | "\n" ->
              Position(
                index: position.index + 1,
                line: position.line + 1,
                offset: 0,
              )
            _ ->
              Position(
                ..position,
                index: position.index + 1,
                offset: position.offset + 1,
              )
          }

          case is_escaped {
            True -> #(
              [Grapheme(grapheme, True, position), ..accumulator],
              False,
              next_position,
            )
            False ->
              case grapheme {
                "\\" -> #(accumulator, True, next_position)
                _ -> #(
                  [Grapheme(grapheme, False, position), ..accumulator],
                  False,
                  next_position,
                )
              }
          }
        }
      }
    })

  let assert Ok(whitespace_regex) = regexp.from_string("\\s")
  let is_whitespace_or_new_line = fn(grapheme: Grapheme) -> Bool {
    is_whitespace(grapheme) || is_new_line(grapheme)
  }

  list.map(accumulator, fn(grapheme) {
    let Grapheme(grapheme, is_escaped, position) = grapheme

    case grapheme {
      "\r" | "\n" -> Grapheme("\n", is_escaped, position)
      " " -> Grapheme(" ", is_escaped, position)
      "\t" -> Grapheme("\t", is_escaped, position)
      _ ->
        case is_escaped {
          True -> Grapheme(grapheme, is_escaped, position)
          False ->
            case regexp.check(whitespace_regex, grapheme) {
              False -> Grapheme(grapheme, is_escaped, position)
              True -> Grapheme(" ", is_escaped, position)
            }
        }
    }
  })
  |> list.drop_while(is_whitespace_or_new_line)
  |> list.reverse
  |> list.drop_while(is_whitespace_or_new_line)
}
