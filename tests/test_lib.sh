#!/bin/bash

MKFIFO=`which mkfifo`
PIPE=fifo
OUT=outfile
TAIL=`which tail`
NC="`which nc` -C"
TIMEOUT=1 # Change this value if you're are using ftp.dlptest.com (to 3) or with slow remote FTP servers for example

print_info()
{
    echo -e "\e[0;34m[INFO] $1\e[0m"
}

print_success()
{
    echo -e "\e[0;32m[SUCCESS] $1\e[0m"
}

print_error()
{
    echo -e "\e[0;31m[ERROR] $1\e[0m"
}

print_failed()
{
    print_error "$1 test failed"
    print_error "Expected reply-code: $2"
    print_error "Received : ["`$TAIL -n 1 $OUT| cat -e`"]"
    print_error "KO"
}

print_succeeded()
{
  print_success "$1 test succeeded"
  print_success "OK"
  kill_client 2>&1 >/dev/null
}

getcode()
{
  sleep $TIMEOUT
  local code=$1
  print_info "Waiting for $code reply-code"
  local data=`$TAIL -n 1 $OUT |cat -e |grep "^$code.*[$]$" |wc -l`
  return $data
}

launch_client()
{
  local host=$1
  local port=$2

  $MKFIFO $PIPE
  ($TAIL -f $PIPE 2>/dev/null | $NC $host $port &> $OUT &) >/dev/null 2>/dev/null

  print_info "Connecting to $host:$port..."
  sleep $TIMEOUT
  getcode 220
  if [[ $? -eq 1 ]]; then
    print_success "Reply-code OK"
    return 1
  else
    print_error "Connection to $host:$port failed"
    print_error "Expected reply-code: 220"
    print_error "Received : ["`tail -n 1 $OUT |cat -e`"]"
    return 0
  fi
}

launch_test()
{
  local test_name=$1
  local cmd=$2
  local code=$3

  print_info "Sending [$cmd^M$]"
  echo "$cmd" >$PIPE
  getcode $code
  if [[ ! $? -eq 1 ]]; then
    print_failed "$test_name" "$code"
    kill_client
    clean
  fi
  print_success "Reply-code OK"
}

kill_client()
{
  local nc=`which nc`

  if [ `pidof $TAIL | wc -l` -ne 0 ]
  then
    killall $TAIL &>/dev/null
  fi
  if [ `pidof $nc | wc -l` -ne 0 ]
  then
    killall $nc &>/dev/null
  fi
  rm -f $PIPE $OUT &> /dev/null
}

clean()
{
  rm -f $PIPE $OUT log &>/dev/null
}
