
use strict;

# parse an input line from the table and return
# its fields as a list

sub clean_and_split_line {
  my $line = shift;
  chomp $line;
  $line =~ s/^\s*// if $CONF{strip_leading_space};
  return undef unless $line;
  my @tok = map {clean_field($_)} split_line($line);
  return @tok;
}

sub split_line {
  my $str = shift;
  if($CONF{field_delim}) {
    return split(/[$CONF{field_delim}]/,$str);
  } else {
    return split(/[\s\t]/,$str);
  }
}

sub clean_field {
  my $str = shift;
  $str =~ s/[\Q$CONF{remove_cell_rx}\E]//g;
  return $str;
}

sub shorten_text {
  my $string = shift;
  if($CONF{shorten_text}) {
    for my $word (sort {length($b) <=> length($a)} keys %{$CONF{string_replace}}) {
      $string =~ s/$word/$CONF{string_replace}{$word}/i;
    }
  }
  return $string;
}

sub parse_label {
  my $string = shift;
  if($CONF{segment_remap}) {
  LABEL:
    for my $new_label (keys %{$CONF{segment_remap}}) {
      my @old_labels = split(/\s*,\s*/, $CONF{segment_remap}{$new_label});
      if(grep($_ eq $string, @old_labels)) {
	$string = $new_label;
	last LABEL;
      }
    }
  }
  return shorten_text($string);
}
sub shorten_text {
  my $string = shift;
  if($CONF{shorten_text}) {
    for my $word (sort {length($b) <=> length($a)} keys %{$CONF{string_replace}}) {
      $string =~ s/$word/$CONF{string_replace}{$word}/i;
    }
  }
  return $string;
}

sub clean_value {
  my $val = shift;
  (my $new_val = $val) =~ s/[^\w.\-+$CONF{missing_cell_value}]*//g;
  report_error("Cell value ($val) is malformed.") unless $new_val ne "";
  if($CONF{use_cell_remap}) {
    my $expr = $CONF{cell_remap_formula};
    $expr =~ s/X/$new_val/g;
    my $expr_value = eval $expr;
    if($@) {
      report_error("Remapping the cell value ($new_val) using the expression ($expr) failed - the expression could not be parsed.");
    } else {
      printdebug("remapped cell",$new_val,$expr,$expr_value);
    }
    $new_val = $expr_value;
  }
  return $new_val;
}


return 1;
