#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: $0 host port"
    exit 0
fi

source tests/test_lib.sh

HOST=$1
PORT=$2

test00()
{
  local test_name="Authentication as Anonymous"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER Anonymous" 331 # Replace this line if you're trying on ftp.dlptest.com
  launch_test "$test_name" "PASS" 230 # Replace this line if you're trying on ftp.dlptest.com

  print_succeeded "$test_name"
  return
}

test01()
{
  local test_name="Authentication with wrong username"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER invalid" 331

  print_succeeded "$test_name"
  return
}

test02()
{
  local test_name="Authentication with wrong password"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER Anonymous" 331
  launch_test "$test_name" "PASS invalid" 530

  print_succeeded "$test_name"
  return
}

test00; clean
test01; clean
test02; clean
