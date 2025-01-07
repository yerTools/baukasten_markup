import baukasten_markup/lexer/model.{
  type CodeSegment, type Grapheme, type Paragraph, type Segments, type Text,
  type TextLine, CodeSegment, EmptyLine, Grapheme, Paragraph, Segments, Text,
  TextLine,
}
import gleam/list

type EitherOr(a, b) {
  Either(a)
  Or(b)
}

type State {
  State(segments: Segments, current: EitherOr(Paragraph, CodeSegment))
}

fn line_first_unescaped_graphemes(line: TextLine) -> List(String) {
  case line.text {
    [] -> []
    [text, ..] if !text.is_escaped ->
      text.graphemes |> list.map(fn(grapheme) { grapheme.grapheme })
    _ -> []
  }
}

pub fn to_segments(lines: List(TextLine)) -> Segments {
  let state = State(Segments([], []), Either(Paragraph([])))
  let state =
    list.fold(lines, state, fn(state, line) {
      case state.current {
        Either(paragraph) ->
          case line.properties == EmptyLine {
            True ->
              State(
                segments: Segments(..state.segments, text: [
                  paragraph,
                  ..state.segments.text
                ]),
                current: Either(Paragraph([])),
              )
            False ->
              case line_first_unescaped_graphemes(line) {
                ["#", "f", "n", " ", ..] ->
                  State(
                    segments: Segments(..state.segments, text: [
                      paragraph,
                      ..state.segments.text
                    ]),
                    current: Or(CodeSegment(lines: [line])),
                  )
                _ ->
                  State(
                    ..state,
                    current: Either(Paragraph(lines: [line, ..paragraph.lines])),
                  )
              }
          }
        Or(code_segment) -> {
          let code_segment = CodeSegment(lines: [line, ..code_segment.lines])

          case line_first_unescaped_graphemes(line) {
            ["e", "n", "d", ..] ->
              State(
                segments: Segments(..state.segments, code: [
                  code_segment,
                  ..state.segments.code
                ]),
                current: Either(Paragraph([])),
              )
            _ -> State(..state, current: Or(code_segment))
          }
        }
      }
    })

  let segments = case state.current {
    Either(paragraph) ->
      Segments(..state.segments, text: [paragraph, ..state.segments.text])
    Or(code_segment) ->
      Segments(..state.segments, code: [code_segment, ..state.segments.code])
  }

  Segments(
    text: list.filter(segments.text, fn(paragraph) { paragraph.lines != [] })
      |> list.map(fn(paragraph) {
        Paragraph(
          lines: list.reverse(paragraph.lines)
          |> list.map(clean_paragraph_text_line),
        )
      })
      |> list.reverse,
    code: list.filter(segments.code, fn(code_segment) {
      code_segment.lines != []
    })
      |> list.map(fn(code_segment) {
        CodeSegment(lines: list.reverse(code_segment.lines))
      })
      |> list.reverse,
  )
}

fn drop_whitespace(text: Text, from_end: Bool) -> Text {
  let graphemes = case from_end {
    False -> text.graphemes
    True -> list.reverse(text.graphemes)
  }

  let #(graphemes, _) =
    list.fold(graphemes, #([], True), fn(state, grapheme) {
      let #(acc, is_start) = state
      case is_start {
        True ->
          case grapheme {
            Grapheme("\n", _, _) | Grapheme("\t", _, _) | Grapheme(" ", _, _) -> #(
              acc,
              True,
            )
            _ -> #([grapheme, ..acc], False)
          }
        False -> #([grapheme, ..acc], False)
      }
    })

  Text(..text, graphemes: case from_end {
    False -> list.reverse(graphemes)
    True -> graphemes
  })
}

fn clean_paragraph_text_line(text_line: TextLine) -> TextLine {
  let content = case text_line.text {
    [head, ..tail] if !head.is_escaped -> [drop_whitespace(head, False), ..tail]
    _ -> text_line.text
  }

  let content = list.reverse(content)
  let content = case content {
    [head, ..tail] if !head.is_escaped -> [drop_whitespace(head, True), ..tail]
    _ -> content
  }

  TextLine(..text_line, text: list.reverse(content))
}
