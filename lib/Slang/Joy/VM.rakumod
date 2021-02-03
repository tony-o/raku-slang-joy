unit module Slang::Joy::VM;

sub err($msg, $match = %*STATE<match>) is export {
  my $pos   = $match.from;
  my $lines = $match.orig.substr(0, ($match.orig.index("\n", $pos)) // $match.orig.chars).lines;
  my $line  = +$lines;

  $pos -= [+] $lines[0..^$line-1].map(*.chars + $?NL.chars);
  $*ERR.say: sprintf("#error: %s", $msg);
  for max($line - 3, 0) ..^ $line -> $idx {
    $*ERR.say: "#  {$lines[$idx]}";
    $*ERR.say: "#  {'-' x $pos}^" if $idx == $line - 1;
  }
  exit 255;
}

sub eval(@rstack) is export {
  my @stack;
  for 0..^@rstack -> $idx {
    if @rstack[$idx]<type> eq 'ident' {
      err "{@rstack[$idx]<value>} not defined" unless $*ENV.get(@rstack[$idx]<value>);
      $*ENV.get(@rstack[$idx]<value>)(@stack);
    } else {
      @stack.push(@rstack[$idx]);
    }
  }
  @stack;
}
