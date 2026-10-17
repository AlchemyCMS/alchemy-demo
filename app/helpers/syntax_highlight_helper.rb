module SyntaxHighlightHelper
  # Server-side syntax highlighting via Rouge (no client JS). Returns HTML with
  # token spans styled by the `.highlight` theme in the Tailwind stylesheet.
  # Unknown languages fall back to plain, escaped text.
  def highlight_code(source, language)
    lexer = Rouge::Lexer.find(language.to_s) || Rouge::Lexers::PlainText
    Rouge::Formatters::HTML.new.format(lexer.lex(source.to_s)).html_safe
  end
end
