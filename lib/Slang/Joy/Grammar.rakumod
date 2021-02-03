#use Grammar::Tracer::Compact;
use Slang::Joy::Env;
unit grammar Slang::Joy::Grammar;

token TOP(@*STACK = [], $*ENV = Slang::Joy::Env.new, %*STATE = {parr=>[]}) {
  ^ \s* <cmd>* \s* $
}

token cmd {
  ||<tokens>* % \s* <exec> \s*
}

token exec { '.' }

token tokens {
  ||<array>
  ||<set>
  ||<number>
  ||<char>
  ||<string>
  ||<definition>
  ||<ident>
  ||<comment>
}

token comment {
  '(*' ~ '*)' .+?
}

token definition {
  <define> \s+
  <ident> \s* '==' \s*
  <tokens>* % \s+
}

token define {
  'DEFINE'
}

token ident {
  <+[a..zA..Z0..9_\-\+\/\%\*]>+
}

token array {
  <s-array> ~ <e-array> <tokens>* % \s+
}

token s-array { '[' \s* }
token e-array { \s* ']' }

token set {
  <s-set> ~ <e-set> <tokens>* % \s+
}
token s-set { '{' }
token e-set { '}' }

token number {
  \d+ $<dec> = ('.' \d+)?
}

token char {
  "'" $<val> = .
}

token string {
  '"' ~ '"' .*?
}
