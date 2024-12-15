#!/bin/sh

function convert_ipV4_to_hex {
  printf "${1:-192.168.1.100}" | tr '.' '\0' | xargs -0 -n1 printf '%02X'
}

function convert_hex_to_decimal {
  printf "ibase=16; %s\n" "${1:-FF}" | bc
}

function convert_ipV4_to_decimal {
  convert_hex_to_decimal $(convert_ipV4_to_hex "${1:-192.168.10.100}");
}

# Ex.: `convert_decimal_to_ipV4 3232238180` -> 192.168.10.100
function convert_decimal_to_ipV4 {
  local a=$((($1 & 4278190080) >> 24)) # echo $((255 << 24))
  local b=$((($1 & 16711680) >> 16)) # echo $((255 << 16))
  local c=$((($1 & 65280) >> 8)) # echo $((255 << 8))
  local d=$(($1 & 255)) # the first 8 bit to 1 is 255
  printf "%s.%s.%s.%s\n" $a $b $c $d
}