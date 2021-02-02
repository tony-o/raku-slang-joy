use Slang::Joy::Grammar;
use Slang::Joy::Action;

sub joy-run(Str $src, :$ENV, :@STACK, :%STATE) is export {
  try {
    CATCH { default { $*ERR.printf("error: %s\n", $_.message); } };
    Slang::Joy::Grammar.parse($src, :actions(Slang::Joy::Action), :args(@STACK, $ENV, %STATE));
  };
}
