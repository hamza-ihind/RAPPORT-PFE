# Latexmk configuration for optimized XeLaTeX builds.

# Use XeLaTeX as the engine.
$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape %O %S';
$pdf_mode = 5; # Use xelatex to produce PDF.

# Output auxiliary files to 'build/' directory.
$aux_dir = 'build';
$out_dir = '.';

# Glossary support.
add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
add_cus_dep('slo', 'sls', 0, 'makeglossaries');
sub makeglossaries {
    my ($base_name, $path) = fileparse( $$Psource );
    my @args = ( "--dir=$path", $base_name );
    if ($silent) { unshift @args, "-q"; }
    return system "makeglossaries", "-d", $path, $base_name;
}

# Extra files to clean.
$clean_ext .= ' acn acr alg glo gls glg ist slo sls slg run.xml bbl bcf fdb_latexmk fls synctex.gz minted';
