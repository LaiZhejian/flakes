{
  pkgs,
  coreutils,
  ls ? "${coreutils}/bin/ls",
  cat ? "${coreutils}/bin/cat",
  ...
}:

pkgs.writeShellScriptBin "ls-or-cat" ''
  FLAGS=()
  FILES=()

  # collect flags (stop at --)
  while [ $# -gt 0 ]; do
    arg="$1"
    shift
    if [ "$arg" = "--" ]; then
      FILES+=("''$@")
      break
    fi
    case "$arg" in
      -*) FLAGS+=("$arg") ;;
      *) FILES+=("$arg") ;;
    esac
  done

  # if no files are given, list the current directory
  if [ ''${#FILES[@]} -eq 0 ]; then
    ${ls} "''${FLAGS[@]}"
    exit $?
  fi

  # process each file argument
  for arg in "''${FILES[@]}"; do
    if [ -d "$arg" ]; then
      ${ls} "''${FLAGS[@]}" -- "$arg"
    elif [ -f "$arg" ]; then
      ${cat} "''${FLAGS[@]}" -- "$arg"
    else
      echo "error: '$arg' is neither a file nor a directory" >&2
    fi
  done
''
