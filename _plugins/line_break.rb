# -*- coding: utf-8 -*-
#
# Redefines the line break parser to accept a single slash at the end of
# a line as a line break.

module Kramdown
  module Parser
    class Kramdown

      # Use a different constant name to stop the redefinition warning.
      MY_LINE_BREAK = /(  |\\)(?=\n)/

      # Need to remove the existing parser method before adding our own.
      @@parsers.delete(:line_break)
      define_parser(:line_break, MY_LINE_BREAK, MY_LINE_BREAK)

    end
  end
end
