unit role Slang::Joy::Action;
use Slang::Joy::Env;
use Slang::Joy::VM;

sub line-pos(Match $match) {
  my $pos  = $match.pos.raku;
  my $line = $match.orig.substr(0, $pos).lines;
  $pos  = $line[*-1].chars;
  $line = +$line;
  [$line, $pos];
}

method tokens ($/) {
  return if $/<array definition set>.grep(*.defined);
  my $match = $/<number char string ident>.grep(*.defined).first;
  my $tok = $match.made;
  if +%*STATE<parr> > 0 {
    %*STATE<parr>[*-1]<value>.push($tok);
  } elsif $tok<type> eq 'ident' {
    (%*STATE<line>, %*STATE<pos>) = line-pos($/);
    if ($_ = $*ENV.get($tok<value>)) !~~ Callable && ($_//{type=>''})<type> ne 'define' {
      die "{$tok<value>} is not a function (line %*STATE<line>, pos %*STATE<pos>)."
    }
    if $_ ~~ Callable {
      $_();
    } else {
      @*STACK.push: |$_<value>;
      @*STACK = eval(@*STACK);
    }
  } else { 
    @*STACK.push: $tok;
  }
}

method definition ($/) {
  if $/<ident>.made<type> ne 'ident' {

    die 'must define ident'
  }
  $*ENV.set($/<ident>.made<value>, %*STATE<parr>.pop);
  %*STATE<parr> = [];
}

method define($/) {
  %*STATE<parr>.push: {type=>'define', value=>[]};
}

method s-set($/) {
  %*STATE<parr>.push: {type=>'set', value=>[]};
}

method e-set($/) {
  die 'closing set instead of array' if +%*STATE<parr> && %*STATE<parr>[*-1]<type> ne 'set';
  +%*STATE<parr> > 1
    ?? %*STATE<parr>[*-2]<value>.push(%*STATE<parr>.pop)
    !! +%*STATE<parr> < 1
      ?? die 'erroneous end of set found.'
      !! (@*STACK.push(%*STATE<parr>.pop) and %*STATE<parr> = []);
}

method s-array($/) {
  %*STATE<parr>.push: {type=>'list', value=>[]};
}

method char($/) { make {type=>'char', value => $/.Str.substr(1,1)}; }

method e-array($/) {
  die 'closing set instead of array' if +%*STATE<parr> && %*STATE<parr>[*-1]<type> ne 'list';
  +%*STATE<parr> > 1
    ?? %*STATE<parr>[*-2]<value>.push(%*STATE<parr>.pop)
    !! +%*STATE<parr> < 1
      ?? die 'erroneous end of array found.'
      !! (@*STACK.push(%*STATE<parr>.pop) and %*STATE<parr> = []);
}

method ident ($/) { make {type=>'ident', value=>$/.Str}; }
method number ($/) {
  make {type=>'number', value=>$/.Str};
}
method string($/) {
  make {type=>'string', value=>$/.Str};
}
method exec ($/) {
  if %*STATE<repl-out> {
    say stringy(@*STACK);
  }
  @*STACK = [];
}
