import gleam/option.{type Option}

pub type Position {
  Position(index: Int, line: Int, offset: Int)
}

pub type LexerError {
  LexerError(
    input: Option(String),
    start: Position,
    end: Option(Position),
    input_content: Option(String),
    message: Message,
  )
}

pub type Message {
  UnknownKeywordInText(keyword: String)
}
