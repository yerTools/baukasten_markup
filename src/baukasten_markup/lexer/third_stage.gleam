import baukasten_markup/lexer/second_stage
import gleam/list

pub type Segments {
  Segments(text: List(Paragraph), code: List(CodeSegment))
}

pub type Position {
  Position(line: Int, index: Int)
}

pub type Span {
  Span(start: Int, end: Int)
}

pub type LineSpan {
  LineSpan(index: Span, offset: Span)
}

pub type Paragraph {
  Paragraph(lines: List(TextLine))
}

pub type TextLine {
  TextLine(position: Position, content: List(Text), has_linebreak: Bool)
}

pub type Text {
  Text(graphemes: List(String), is_escaped: Bool, position: LineSpan)
}

pub type CodeSegment {
  CodeSegment(lines: List(TextLine))
}

type EitherOr(a, b) {
  Either(a)
  Or(b)
}

type State {
  State(segments: Segments, current: EitherOr(Paragraph, CodeSegment))
}

fn convert_line_to_text_line(line: second_stage.Line) -> TextLine {
  TextLine(
    position: Position(line: line.position.line, index: line.position.index),
    content: list.map(line.text, fn(text) {
      Text(
        graphemes: text.graphemes,
        is_escaped: text.is_escaped,
        position: LineSpan(
          index: Span(text.index.start, text.index.end),
          offset: Span(text.offset.start, text.offset.end),
        ),
      )
    }),
    has_linebreak: case line.properties {
      second_stage.EmptyLine | second_stage.LineWithTrailingWhitespace -> True
      second_stage.TextLine -> False
    },
  )
}

fn line_first_unescaped_graphemes(line: second_stage.Line) -> List(String) {
  case line.text {
    [] -> []
    [text, ..] if !text.is_escaped -> text.graphemes
    _ -> []
  }
}

pub fn to_segments(lines: List(second_stage.Line)) -> Segments {
  let state = State(Segments([], []), Either(Paragraph([])))
  let state =
    list.fold(lines, state, fn(state, line) {
      case state.current {
        Either(paragraph) ->
          case line.properties == second_stage.EmptyLine {
            True ->
              State(
                segments: Segments(
                  ..state.segments,
                  text: [paragraph, ..state.segments.text],
                ),
                current: Either(Paragraph([])),
              )
            False ->
              case line_first_unescaped_graphemes(line) {
                ["#", "f", "n", " ", ..] ->
                  State(
                    segments: Segments(
                      ..state.segments,
                      text: [paragraph, ..state.segments.text],
                    ),
                    current: Or(
                      CodeSegment(lines: [convert_line_to_text_line(line)]),
                    ),
                  )
                _ ->
                  State(
                    ..state,
                    current: Either(
                      Paragraph(lines: [
                        convert_line_to_text_line(line),
                        ..paragraph.lines
                      ]),
                    ),
                  )
              }
          }
        Or(code_segment) -> {
          let code_segment =
            CodeSegment(lines: [
              convert_line_to_text_line(line),
              ..code_segment.lines
            ])

          case line_first_unescaped_graphemes(line) {
            ["e", "n", "d", ..] ->
              State(
                segments: Segments(
                  ..state.segments,
                  code: [code_segment, ..state.segments.code],
                ),
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

  let #(graphemes, drop_count, _) =
    list.fold(graphemes, #([], 0, True), fn(state, grapheme) {
      let #(acc, drop_count, is_start) = state
      case is_start {
        True ->
          case grapheme {
            "\n" | "\t" | " " -> #(acc, drop_count + 1, True)
            _ -> #([grapheme, ..acc], drop_count, False)
          }
        False -> #([grapheme, ..acc], drop_count, False)
      }
    })

  let offset = case text.is_escaped {
    False -> drop_count
    True -> 2 * drop_count
  }

  let #(start_offset, end_offset) = case from_end {
    False -> #(offset, 0)
    True -> #(0, -offset)
  }

  Text(
    ..text,
    graphemes: case from_end {
      False -> list.reverse(graphemes)
      True -> graphemes
    },
    position: LineSpan(
      index: Span(
        text.position.index.start + start_offset,
        text.position.index.end + end_offset,
      ),
      offset: Span(
        text.position.offset.start + start_offset,
        text.position.offset.end + end_offset,
      ),
    ),
  )
}

fn clean_paragraph_text_line(text_line: TextLine) -> TextLine {
  let content = case text_line.content {
    [head, ..tail] if !head.is_escaped -> [drop_whitespace(head, False), ..tail]
    _ -> text_line.content
  }

  let content = list.reverse(content)
  let content = case content {
    [head, ..tail] if !head.is_escaped -> [drop_whitespace(head, True), ..tail]
    _ -> content
  }

  TextLine(..text_line, content: list.reverse(content))
}
