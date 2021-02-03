unit role Slang::Joy::Action;
use Slang::Joy::Env;
use Slang::Joy::VM;

method tokens ($/) {
  return if $/<array comment definition set>.grep(*.defined);
  my $match = $/<number char string ident>.grep(*.defined).first;
  my $tok = $match.made;
  %*STATE<match> = $match;
  if +%*STATE<parr> > 0 {
    if %*STATE<parr>[*-1]<type> eq 'set' {
      err "{$tok<value>} is not set worthy."
        unless $tok<type> ~~ ('char'|'number');
      %*STATE<parr>[*-1]<value> +|=
        1 +< (($tok<type> eq 'number'
                ?? $tok<value>.Int
                !! $tok<value>.ord) mod 32),
    } else {
      %*STATE<parr>[*-1]<value>.push($tok);
    }
  } elsif $tok<type> eq 'ident' {
    if ($_ = $*ENV.get($tok<value>)) !~~ Callable && ($_//{type=>''})<type> ne 'define' {
      err "{$tok<value>} is not a function."
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
    err 'must define ident'
  }
  $*ENV.set($/<ident>.made<value>, %*STATE<parr>.pop);
  %*STATE<parr> = [];
}

method define($/) {
  %*STATE<parr>.push: {type=>'define', value=>[]};
}

method s-set($/) {
  %*STATE<parr>.push: {type=>'set', value=>0};
}

method e-set($/) {
  %*STATE<match> = $/;
  err 'closing set instead of array.' if +%*STATE<parr> && %*STATE<parr>[*-1]<type> ne 'set';
  +%*STATE<parr> > 1
    ?? %*STATE<parr>[*-2]<value>.push(%*STATE<parr>.pop)
    !! +%*STATE<parr> < 1
      ?? err 'erroneous end of set found.'
      !! (@*STACK.push(%*STATE<parr>.pop) and %*STATE<parr> = []);
}

method s-array($/) {
  %*STATE<parr>.push: {type=>'list', value=>[]};
}

method char($/) { make {type=>'char', value => $/.Str.substr(1,1)}; }

method e-array($/) {
  %*STATE<match> = $/;
  err 'closing set instead of array' if +%*STATE<parr> && %*STATE<parr>[*-1]<type> ne 'list';
  +%*STATE<parr> > 1
    ?? %*STATE<parr>[*-2]<value>.push(%*STATE<parr>.pop)
    !! +%*STATE<parr> < 1
      ?? err 'erroneous end of array found.'
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
