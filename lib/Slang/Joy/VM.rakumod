unit module Slang::Joy::VM;

sub eval(@rstack) is export {
  my @stack;
  for 0..^@rstack -> $idx {
    if @rstack[$idx]<type> eq 'ident' {
      die "{@rstack[$idx]<value>} not defined" unless $*ENV.get(@rstack[$idx]<value>);
      $*ENV.get(@rstack[$idx]<value>)(@stack);
    } else {
      @stack.push(@rstack[$idx]);
    }
  }
  @stack;
}
