$violations = @(
  rg --pcre2 -n --glob '*.dart' 'Color\(0x|(?<!App)Colors\.(white|black|grey|red|green|blue|yellow|orange|purple|pink|teal|indigo|cyan|amber|lime|brown|deepOrange|deepPurple|lightBlue|lightGreen|blueGrey)(?![.\[])' lib
)

$violations = $violations | Where-Object {
  $_ -notmatch 'lib[\\/]core[\\/]theming[\\/]app_colors\.dart:' -and
  $_ -notmatch '\.g\.dart:' -and
  $_ -notmatch '\.freezed\.dart:'
}

if ($violations.Count -gt 0) {
  $violations | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Output 'No hardcoded color violations found outside AppColors.'
