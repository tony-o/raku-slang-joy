use Slang::Joy::Grammar;
use Slang::Joy::Action;
use Slang::Joy::Env;

sub joy-run(Str $src, :$ENV = Slang::Joy::Env.new, :@STACK=[], :%STATE={parr=>[]}) is export {
  try {
    CATCH { default { $*ERR.printf("error: %s\n", $_.message); } };
    Slang::Joy::Grammar.parse($src, :actions(Slang::Joy::Action), :args(@STACK, $ENV, %STATE));
  };
}
