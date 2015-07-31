
class Jekyll::Converters::Markdown::XhtmlKramdown
  def initialize(config)
    @config = config
#    puts Jekyll::Utils.symbolize_hash_keys(@config['kramdown'])
#    puts Jekyll::Converters::Markdown.output_ext('')
  rescue LoadError
    STDERR.puts 'You are missing a library required for Markdown. Please run:'
    STDERR.puts '  $ [sudo] gem install xhtml_kramdown'
    raise FatalException.new("Missing dependency: xhtml_kramdown")
  end

  def convert(content)
    Kramdown::Document.new(content, Jekyll::Utils.symbolize_hash_keys(@config['kramdown'])).to_xhtml
  end
end
