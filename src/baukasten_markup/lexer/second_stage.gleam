/// This module contains the second stage of the lexer for the BKM language.
/// It's not meant to be used directly, but only as a dependency
/// for the third stage lexer.
/// It splits the input into lines, extracting escape sequences and
/// checks if the line is empty or contains only whitespace.
import baukasten_markup/lexer/first_stage.{type Grapheme, Grapheme}
import gleam/list
import gleam/option.{None, Some}

pub type Position {
  Position(line: Int, index: Int)
}

pub type Span {
  Span(start: Int, end: Int)
}

pub type LineProperties {
  EmptyLine
  LineWithTrailingWhitespace
  TextLine
}

pub type Line {
  Line(text: List(Text), properties: LineProperties, position: Position)
}

pub type Text {
  Text(graphemes: List(String), is_escaped: Bool, index: Span, offset: Span)
}

fn text_from_grapheme(grapheme: Grapheme) -> Text {
  Text(
    graphemes: [grapheme.grapheme],
    is_escaped: grapheme.is_escaped,
    index: Span(
      case grapheme.is_escaped {
        True -> grapheme.position.index - 1
        False -> grapheme.position.index
      },
      grapheme.position.index,
    ),
    offset: Span(
      case grapheme.is_escaped {
        True -> grapheme.position.offset - 1
        False -> grapheme.position.offset
      },
      grapheme.position.offset,
    ),
  )
}

fn line_from_grapheme(grapheme: Grapheme) -> Line {
  Line(
    text: [text_from_grapheme(grapheme)],
    properties: case
      first_stage.is_whitespace(grapheme) || first_stage.is_new_line(grapheme)
    {
      True -> EmptyLine
      False -> TextLine
    },
    position: Position(
      line: grapheme.position.line,
      index: grapheme.position.index,
    ),
  )
}

pub fn to_lines(graphemes: List(Grapheme)) -> List(Line) {
  let #(lines, last_line) =
    list.fold(graphemes, #([], None), fn(state, grapheme) {
      let #(acc, last_line) = state

      let last_line = case last_line {
        None -> line_from_grapheme(grapheme)
        Some(last_line) -> {
          let last_line: Line = last_line

          case last_line.text {
            [] -> line_from_grapheme(grapheme)
            [current, ..rest] ->
              case current.is_escaped == grapheme.is_escaped {
                True ->
                  Line(
                    ..last_line,
                    text: [
                      Text(
                        ..current,
                        graphemes: [grapheme.grapheme, ..current.graphemes],
                        offset: Span(
                          ..current.offset,
                          end: grapheme.position.offset,
                        ),
                        index: Span(
                          ..current.offset,
                          end: grapheme.position.index,
                        ),
                      ),
                      ..rest
                    ],
                  )
                False ->
                  Line(
                    ..last_line,
                    text: [text_from_grapheme(grapheme), ..last_line.text],
                  )
              }
          }
        }
      }

      let last_line = case
        last_line.properties == EmptyLine
        && !first_stage.is_whitespace(grapheme)
        && !first_stage.is_new_line(grapheme)
      {
        True -> Line(..last_line, properties: TextLine)
        False -> last_line
      }

      case grapheme.grapheme == "\n" {
        True -> #([last_line, ..acc], None)
        False -> #(acc, Some(last_line))
      }
    })

  let lines = case last_line {
    None -> lines
    Some(last_line) -> [last_line, ..lines]
  }

  list.map(lines, fn(line) {
    let line = case line.properties {
      TextLine ->
        case line.text {
          [text, ..] if !text.is_escaped -> {
            case text.graphemes {
              ["\n", a, b, ..]
                if a == " " && b == " " || a == "\t" || b == "\t"
              -> Line(..line, properties: LineWithTrailingWhitespace)
              ["\n", a, ..] if a == "\t" ->
                Line(..line, properties: LineWithTrailingWhitespace)
              _ -> line
            }
          }
          _ -> line
        }
      _ -> line
    }

    Line(
      ..line,
      text: list.map(line.text, fn(text) {
          Text(..text, graphemes: list.reverse(text.graphemes))
        })
        |> list.reverse,
    )
  })
  |> list.reverse
}
