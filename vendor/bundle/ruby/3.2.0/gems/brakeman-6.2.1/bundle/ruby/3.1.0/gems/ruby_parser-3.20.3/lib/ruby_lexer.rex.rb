# frozen_string_literal: true
# encoding: UTF-8
#--
# This file is automatically generated. Do not modify it.
# Generated by: oedipus_lex version 2.6.1.
# Source: lib/ruby_lexer.rex
#++

#
# lexical scanner definition for ruby


##
# The generated lexer RubyLexer

class RubyLexer
  require 'strscan'

  # :stopdoc:
  IDENT_CHAR    = /[a-zA-Z0-9_[:^ascii:]]/
  ESC           = /\\((?>[0-7]{1,3}|x\h{1,2}|M-[^\\]|(C-|c)[^\\]|u\h{1,4}|u\{\h+(?:\s+\h+)*\}|[^0-7xMCc]))/
  SIMPLE_STRING = /((#{ESC}|\#(#{ESC}|[^\{\#\@\$\"\\])|[^\"\\\#])*)/o
  SSTRING       = /((\\.|[^\'])*)/
  INT_DEC       = /[+]?(?:(?:[1-9][\d_]*|0)(?!\.\d)(ri|r|i)?\b|0d[0-9_]+)(ri|r|i)?/i
  INT_HEX       = /[+]?0x[a-f0-9_]+(ri|r|i)?/i
  INT_BIN       = /[+]?0b[01_]+(ri|r|i)?/i
  INT_OCT       = /[+]?0o?[0-7_]+(ri|r|i)?|0o(ri|r|i)?/i
  FLOAT         = /[+]?\d[\d_]*\.[\d_]+(e[+-]?[\d_]+)?(?:(ri|r|i)\b)?|[+]?[\d_]+e[+-]?[\d_]+(?:(ri|r|i)\b)?/i
  INT_DEC2      = /[+]?\d[0-9_]*(?![e])((ri|r|i)\b)?/i
  NUM_BAD       = /[+]?0[xbd]\b/i
  INT_OCT_BAD   = /[+]?0o?[0-7_]*[89]/i
  FLOAT_BAD     = /[+]?\d[\d_]*_(e|\.)/i
  # :startdoc:
  # :stopdoc:
  class LexerError < StandardError ; end
  class ScanError < LexerError ; end
  # :startdoc:

  ##
  # The current line number.

  attr_accessor :lineno
  ##
  # The file name / path

  attr_accessor :filename

  ##
  # The StringScanner for this lexer.

  attr_accessor :ss

  ##
  # The current lexical state.

  attr_accessor :state

  alias :match :ss

  ##
  # The match groups for the current scan.

  def matches
    m = (1..9).map { |i| ss[i] }
    m.pop until m[-1] or m.empty?
    m
  end

  ##
  # Yields on the current action.

  def action
    yield
  end

  ##
  # The previous position. Only available if the :column option is on.

  attr_accessor :old_pos

  ##
  # The position of the start of the current line. Only available if the
  # :column option is on.

  attr_accessor :start_of_current_line_pos

  ##
  # The current column, starting at 0. Only available if the
  # :column option is on.
  def column
    old_pos - start_of_current_line_pos
  end


  ##
  # The current scanner class. Must be overridden in subclasses.

  def scanner_class
    StringScanner
  end unless instance_methods(false).map(&:to_s).include?("scanner_class")

  ##
  # Parse the given string.

  def parse str
    self.ss     = scanner_class.new str
    self.lineno = 1
    self.start_of_current_line_pos = 0
    self.state  ||= nil

    do_parse
  end

  ##
  # Read in and parse the file at +path+.

  def parse_file path
    self.filename = path
    open path do |f|
      parse f.read
    end
  end

  ##
  # The current location in the parse.

  def location
    [
      (filename || "<input>"),
      lineno,
      column,
    ].compact.join(":")
  end

  ##
  # Lex the next token.

  def next_token
    maybe_pop_stack
    return process_string_or_heredoc if lex_strterm
    self.cmd_state = self.command_start
    self.command_start = false
    self.space_seen    = false # TODO: rename token_seen?
    self.last_state    = lex_state

    token = nil

    until ss.eos? or token do
      if ss.check(/\n/) then
        self.lineno += 1
        # line starts 1 position after the newline
        self.start_of_current_line_pos = ss.pos + 1
      end
      self.old_pos = ss.pos
      token =
        case state
        when nil then
          case
          when ss.skip(/[\ \t\r\f\v]+/) then
            action { self.space_seen = true; next }
          when text = ss.scan(/\n|\#/) then
            process_newline_or_comment text
          when text = ss.scan(/[\]\)\}]/) then
            process_brace_close text
          when ss.match?(/\!/) then
            case
            when is_after_operator? && (text = ss.scan(/\!\@/)) then
              action { result EXPR_ARG,   TOKENS[text], text }
            when text = ss.scan(/\![=~]?/) then
              action { result :arg_state, TOKENS[text], text }
            end # group /\!/
          when ss.match?(/\./) then
            case
            when text = ss.scan(/\.\.\.?/) then
              process_dots text
            when ss.skip(/\.\d/) then
              action { rb_compile_error "no .<digit> floating literal anymore put 0 before dot" }
            when ss.skip(/\./) then
              action { self.lex_state = EXPR_BEG; result EXPR_DOT, :tDOT, "." }
            end # group /\./
          when text = ss.scan(/\(/) then
            process_paren text
          when text = ss.scan(/\,/) then
            action { result EXPR_PAR, TOKENS[text], text }
          when ss.match?(/=/) then
            case
            when text = ss.scan(/\=\=\=|\=\=|\=~|\=>|\=(?!begin\b)/) then
              action { result arg_state, TOKENS[text], text }
            when bol? && (text = ss.scan(/\=begin(?=\s)/)) then
              process_begin text
            when text = ss.scan(/\=(?=begin\b)/) then
              action { result arg_state, TOKENS[text], text }
            end # group /=/
          when ruby22_label? && (text = ss.scan(/\"#{SIMPLE_STRING}\":/o)) then
            process_label text
          when text = ss.scan(/\"(#{SIMPLE_STRING})\"/o) then
            process_simple_string text
          when text = ss.scan(/\"/) then
            action { string STR_DQUOTE, '"'; result nil, :tSTRING_BEG, text }
          when text = ss.scan(/\@\@?\d/) then
            action { rb_compile_error "`#{text}` is not allowed as a variable name" }
          when text = ss.scan(/\@\@?#{IDENT_CHAR}+/o) then
            process_ivar text
          when ss.match?(/:/) then
            case
            when not_end? && (text = ss.scan(/:([a-zA-Z_]#{IDENT_CHAR}*(?:[?]|[!](?!=)|=(?==>)|=(?![=>]))?)/o)) then
              process_symbol text
            when not_end? && (text = ss.scan(/\:\"(#{SIMPLE_STRING})\"/o)) then
              process_symbol text
            when not_end? && (text = ss.scan(/\:\'(#{SSTRING})\'/o)) then
              process_symbol text
            when text = ss.scan(/\:\:/) then
              process_colon2 text
            when text = ss.scan(/\:/) then
              process_colon1 text
            end # group /:/
          when text = ss.scan(/->/) then
            action { result EXPR_ENDFN, :tLAMBDA, text }
          when text = ss.scan(/[+-]/) then
            process_plus_minus text
          when ss.match?(/[+\d]/) then
            case
            when ss.skip(/#{NUM_BAD}/o) then
              action { rb_compile_error "Invalid numeric format"  }
            when ss.skip(/#{INT_DEC}/o) then
              action { int_with_base 10                           }
            when ss.skip(/#{INT_HEX}/o) then
              action { int_with_base 16                           }
            when ss.skip(/#{INT_BIN}/o) then
              action { int_with_base 2                            }
            when ss.skip(/#{INT_OCT_BAD}/o) then
              action { rb_compile_error "Illegal octal digit."    }
            when ss.skip(/#{INT_OCT}/o) then
              action { int_with_base 8                            }
            when ss.skip(/#{FLOAT_BAD}/o) then
              action { rb_compile_error "Trailing '_' in number." }
            when text = ss.scan(/#{FLOAT}/o) then
              process_float text
            when ss.skip(/#{INT_DEC2}/o) then
              action { int_with_base 10                           }
            when ss.skip(/[0-9]/) then
              action { rb_compile_error "Bad number format" }
            end # group /[+\d]/
          when text = ss.scan(/\[/) then
            process_square_bracket text
          when was_label? && (text = ss.scan(/\'#{SSTRING}\':?/o)) then
            process_label_or_string text
          when text = ss.scan(/\'/) then
            action { string STR_SQUOTE, "'"; result nil, :tSTRING_BEG, text }
          when ss.match?(/\|/) then
            case
            when ss.skip(/\|\|\=/) then
              action { result EXPR_BEG, :tOP_ASGN, "||" }
            when ss.skip(/\|\|/) then
              action { result EXPR_BEG, :tOROP,    "||" }
            when ss.skip(/\|\=/) then
              action { result EXPR_BEG, :tOP_ASGN, "|" }
            when ss.skip(/\|/) then
              action { state = is_after_operator? ? EXPR_ARG : EXPR_PAR; result state, :tPIPE, "|" }
            end # group /\|/
          when text = ss.scan(/\{/) then
            process_brace_open text
          when ss.match?(/\*/) then
            case
            when ss.skip(/\*\*=/) then
              action { result EXPR_BEG, :tOP_ASGN, "**" }
            when ss.skip(/\*\*/) then
              action { result :arg_state, space_vs_beginning(:tDSTAR, :tDSTAR, :tPOW), "**" }
            when ss.skip(/\*\=/) then
              action { result EXPR_BEG, :tOP_ASGN, "*" }
            when ss.skip(/\*/) then
              action { result :arg_state, space_vs_beginning(:tSTAR, :tSTAR, :tSTAR2), "*" }
            end # group /\*/
          when ss.match?(/</) then
            case
            when ss.skip(/\<\=\>/) then
              action { result :arg_state, :tCMP, "<=>"    }
            when ss.skip(/\<\=/) then
              action { result :arg_state, :tLEQ, "<="     }
            when ss.skip(/\<\<\=/) then
              action { result EXPR_BEG,  :tOP_ASGN, "<<" }
            when text = ss.scan(/\<\</) then
              process_lchevron text
            when ss.skip(/\</) then
              action { result :arg_state, :tLT, "<"       }
            end # group /</
          when ss.match?(/>/) then
            case
            when ss.skip(/\>\=/) then
              action { result :arg_state, :tGEQ, ">="     }
            when ss.skip(/\>\>=/) then
              action { result EXPR_BEG,  :tOP_ASGN, ">>" }
            when ss.skip(/\>\>/) then
              action { result :arg_state, :tRSHFT, ">>"   }
            when ss.skip(/\>/) then
              action { result :arg_state, :tGT, ">"       }
            end # group />/
          when ss.match?(/\`/) then
            case
            when expr_fname? && (ss.skip(/\`/)) then
              action { result EXPR_END, :tBACK_REF2, "`" }
            when expr_dot? && (ss.skip(/\`/)) then
              action { result((cmd_state ? EXPR_CMDARG : EXPR_ARG), :tBACK_REF2, "`") }
            when ss.skip(/\`/) then
              action { string STR_XQUOTE, '`'; result nil, :tXSTRING_BEG, "`" }
            end # group /\`/
          when text = ss.scan(/\?/) then
            process_questionmark text
          when ss.match?(/&/) then
            case
            when ss.skip(/\&\&\=/) then
              action { result EXPR_BEG, :tOP_ASGN, "&&" }
            when ss.skip(/\&\&/) then
              action { result EXPR_BEG, :tANDOP,   "&&" }
            when ss.skip(/\&\=/) then
              action { result EXPR_BEG, :tOP_ASGN, "&"  }
            when ss.skip(/\&\./) then
              action { result EXPR_DOT, :tLONELY,  "&." }
            when text = ss.scan(/\&/) then
              process_amper text
            end # group /&/
          when text = ss.scan(/\//) then
            process_slash text
          when ss.match?(/\^/) then
            case
            when ss.skip(/\^=/) then
              action { result EXPR_BEG, :tOP_ASGN, "^" }
            when ss.skip(/\^/) then
              action { result :arg_state, :tCARET, "^" }
            end # group /\^/
          when ss.skip(/\;/) then
            action { self.command_start = true; result EXPR_BEG, :tSEMI, ";" }
          when ss.match?(/~/) then
            case
            when is_after_operator? && (ss.skip(/\~@/)) then
              action { result :arg_state, :tTILDE, "~" }
            when ss.skip(/\~/) then
              action { result :arg_state, :tTILDE, "~" }
            end # group /~/
          when ss.match?(/\\/) then
            case
            when ss.skip(/\\\r?\n/) then
              action { self.lineno += 1; self.space_seen = true; next }
            when ss.skip(/\\/) then
              action { rb_compile_error "bare backslash only allowed before newline" }
            end # group /\\/
          when text = ss.scan(/\%/) then
            process_percent text
          when ss.match?(/\$/) then
            case
            when text = ss.scan(/\$_\w+/) then
              process_gvar text
            when text = ss.scan(/\$_/) then
              process_gvar text
            when text = ss.scan(/\$[~*$?!@\/\\;,.=:<>\"]|\$-\w?/) then
              process_gvar text
            when in_fname? && (text = ss.scan(/\$([\&\`\'\+])/)) then
              process_gvar text
            when text = ss.scan(/\$([\&\`\'\+])/) then
              process_backref text
            when in_fname? && (text = ss.scan(/\$([1-9]\d*)/)) then
              process_gvar text
            when text = ss.scan(/\$([1-9]\d*)/) then
              process_nthref text
            when text = ss.scan(/\$0/) then
              process_gvar text
            when text = ss.scan(/\$#{IDENT_CHAR}+/) then
              process_gvar text
            when text = ss.scan(/\$\W/) then
              process_gvar_oddity text
            end # group /\$/
          when text = ss.scan(/\_/) then
            process_underscore text
          when text = ss.scan(/#{IDENT_CHAR}+/o) then
            process_token text
          when ss.skip(/\004|\032|\000|\Z/) then
            action { [RubyLexer::EOF, RubyLexer::EOF] }
          when text = ss.scan(/./) then
            action { rb_compile_error "Invalid char #{text.inspect} in expression" }
          else
            text = ss.string[ss.pos .. -1]
            raise ScanError, "can not match (#{state.inspect}) at #{location}: '#{text}'"
          end
        else
          raise ScanError, "undefined state at #{location}: '#{state}'"
        end # token = case state

      next unless token # allow functions to trigger redo w/ nil
    end # while

    raise LexerError, "bad lexical result at #{location}: #{token.inspect}" unless
      token.nil? || (Array === token && token.size >= 2)

    # auto-switch state
    self.state = token.last if token && token.first == :state

    token
  end # def next_token
end # class
