function ddiff() {
  diff -u "${1}" "${2}" | delta --side-by-side
}
