unit class Slang::Joy::Env;
use Slang::Joy::VM;

multi sub stringy($stack) is export {
  if $stack<type> eq 'number' {
    $stack<value>.Str;
  } elsif $stack<type> eq 'char' {
    "'$stack<value>";
  } elsif $stack<type> eq 'list' {
    '[' ~ $stack<value>.map({stringy($_)}) ~ ']';
  } elsif $stack<type> eq 'set' {
    '{' ~ $stack<value>.map({stringy($_)}) ~ '}';
  } elsif $stack<type> eq 'str' {
    "\"$stack<value>\"";
  }
}

multi sub stringy(@stack) is export {
  @stack.map({stringy($_)});
}

has $!environment = {
  dup => sub (@stack = @*STACK) {
    @stack.push: @stack[*-1];
  },
  map => sub (@stack = @*STACK) {
    my $to-do   = @stack.pop;
    my $against = @stack.pop;
    @stack.push({type=>'list',value=>[]});
    for |$against<value> -> $arg {
      @stack[*-1]<value>.push: eval([$arg, |$to-do<value>])[*-1];
    }
  },
  '*' => sub (@stack = @*STACK) {
    my ($a, $b) = @stack.pop, @stack.pop;
    die "* expects two numbers"
      unless $a<type> eq 'number'
      && $b<type> eq 'number';
    @stack.push: {type => 'number', value => $a<value> * $b<value>};
  },
  'dumps' => sub (@stack = @*STACK) {
    say stringy(@stack);
  },
  'first' => sub (@stack = @*STACK) {
    my $xs = @stack.pop;
    $xs = $xs<type> eq 'set' ?? $xs<value>.sort({$^a<value> cmp $^b<value>}).Slip !! $xs<value>;
    @stack.push: $xs[0];
  },
  'rem' => sub (@stack = @*STACK){
    my $x = @stack.pop;
    my $y = @stack.pop;
    die 'rem requires two integers' unless $x<type> eq 'number'
                                        && $y<type> eq 'number';
    @stack.push: {type=>'number', value=> $y<value>.Int mod $x<value>.Int};
  },
  'concat' => sub (@stack = @*STACK) {
    my $b = @stack.pop;
    my $a = @stack.pop;
    @stack.push: |$a<values value>.grep(*.defined).first, |$b<values value>.grep(*.defined).first;
  },
  'succ' => sub (@stack = @*STACK) {
    die "succ expected num or char (got: {@stack[*-1].raku})"
       if Nil ~~ try { @stack[*-1].Int } && @stack[*-1].chars != 1;
    if @stack[*-1]<type> eq 'number' {
      @stack[*-1]<value>++;
    } elsif @stack[*-1]<type> eq 'char' {
      @stack[*-1]<value> = (1+@stack[*-1]<value>.substr(0,1).ord).chr;
    } else {
      die 'numeric required for succ.';
    }
  },
};

method get($key){
  $!environment{$key};
}

method set($key, $x) {
  $!environment{$key} = $x;
}
