/// This module contains the second stage of the lexer for the BKM language.
/// It's not meant to be used directly, but only as a dependency
/// for the third stage lexer.
/// It splits the input into lines, extracting escape sequences and
/// checks if the line is empty or contains only whitespace.
import baukasten_markup/lexer/first_stage
import baukasten_markup/lexer/model.{
  type Grapheme, type Text, type TextLine, EmptyLine, Grapheme, LineHasText,
  LineWithTrailingWhitespace, Text, TextLine,
}
import gleam/list
import gleam/option.{None, Some}

fn text_from_grapheme(grapheme: Grapheme) -> Text {
  Text(graphemes: [grapheme], is_escaped: grapheme.is_escaped)
}

fn line_from_grapheme(grapheme: Grapheme) -> TextLine {
  TextLine(text: [text_from_grapheme(grapheme)], properties: case
    first_stage.is_whitespace(grapheme) || first_stage.is_new_line(grapheme)
  {
    True -> EmptyLine
    False -> LineHasText
  })
}

pub fn to_lines(graphemes: List(Grapheme)) -> List(TextLine) {
  let #(lines, last_line) =
    list.fold(graphemes, #([], None), fn(state, grapheme) {
      let #(acc, last_line) = state

      let last_line = case last_line {
        None -> line_from_grapheme(grapheme)
        Some(last_line) -> {
          let last_line: TextLine = last_line

          case last_line.text {
            [] -> line_from_grapheme(grapheme)
            [current, ..rest] ->
              case current.is_escaped == grapheme.is_escaped {
                True ->
                  TextLine(..last_line, text: [
                    Text(..current, graphemes: [grapheme, ..current.graphemes]),
                    ..rest
                  ])
                False ->
                  TextLine(..last_line, text: [
                    text_from_grapheme(grapheme),
                    ..last_line.text
                  ])
              }
          }
        }
      }

      let last_line = case
        last_line.properties == EmptyLine
        && !first_stage.is_whitespace(grapheme)
        && !first_stage.is_new_line(grapheme)
      {
        True -> TextLine(..last_line, properties: LineHasText)
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
      LineHasText ->
        case line.text {
          [text, ..] if !text.is_escaped ->
            case text.graphemes {
              [Grapheme("\n", _, _), a, b, ..]
                if a.grapheme == " "
                && b.grapheme == " "
                || a.grapheme == "\t"
                || b.grapheme == "\t"
              -> TextLine(..line, properties: LineWithTrailingWhitespace)
              [Grapheme("\n", _, _), a, ..] if a.grapheme == "\t" ->
                TextLine(..line, properties: LineWithTrailingWhitespace)
              _ -> line
            }

          [text, ..] if text.is_escaped ->
            case text.graphemes {
              [Grapheme("\n", _, _), ..] ->
                TextLine(..line, properties: LineWithTrailingWhitespace)
              _ -> line
            }

          _ -> line
        }
      _ -> line
    }

    TextLine(
      ..line,
      text: list.map(line.text, fn(text) {
          Text(..text, graphemes: list.reverse(text.graphemes))
        })
        |> list.reverse,
    )
  })
  |> list.reverse
}
