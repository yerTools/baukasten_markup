import baukasten_markup/lexer/first_stage
import baukasten_markup/lexer/second_stage
import birdie
import gleam/list
import gleeunit
import gleeunit/should
import pprint
import simplifile

/// Run `gleam run -m birdie` for snapshot reviews.
pub fn main() {
  gleeunit.main()
}

pub fn lexer_test() {
  lexer_test_dir("./bkm")
}

fn lexer_test_dir(dir: String) -> Nil {
  let entries = simplifile.read_directory(dir) |> should.be_ok
  list.map(entries, fn(entry) {
    let path = dir <> "/" <> entry
    let is_directory = simplifile.is_directory(path) |> should.be_ok
    let is_file = simplifile.is_file(path) |> should.be_ok

    case is_directory, is_file {
      True, _ -> lexer_test_dir(path)
      _, True -> lexer_test_file(path)
      _, _ -> Nil
    }
  })

  Nil
}

fn lexer_test_file(path: String) -> Nil {
  let content = simplifile.read(path) |> should.be_ok

  let lexer_first_stage = first_stage.to_graphemes(content)

  pprint.styled(lexer_first_stage)
  |> birdie.snap("lexer_first_stage/" <> path)

  let lexer_second_stage = second_stage.to_lines(lexer_first_stage)
  pprint.styled(lexer_second_stage)
  |> birdie.snap("lexer_second_stage/" <> path)
}
