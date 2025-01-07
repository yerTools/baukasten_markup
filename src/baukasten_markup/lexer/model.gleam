pub type Position {
  Position(index: Int, line: Int, offset: Int)
}

pub type Grapheme {
  Grapheme(grapheme: String, is_escaped: Bool, position: Position)
}

pub type LineProperties {
  EmptyLine
  LineWithTrailingWhitespace
  LineHasText
}

pub type TextLine {
  TextLine(text: List(Text), properties: LineProperties)
}

pub type Text {
  Text(graphemes: List(Grapheme), is_escaped: Bool)
}

pub type Segments {
  Segments(text: List(Paragraph), code: List(CodeSegment))
}

pub type Paragraph {
  Paragraph(lines: List(TextLine))
}

pub type CodeSegment {
  CodeSegment(lines: List(TextLine))
}
