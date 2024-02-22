#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USAGE: $0 host port"
    exit 0
fi

source tests/test_lib.sh

HOST=$1
PORT=$2

test_auth_00()
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

test_auth_01()
{
  local test_name="Authentication with wrong username"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER invalid" 331
  launch_test "$test_name" "PASS" 530

  print_succeeded "$test_name"
  return
}

test_auth_02()
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

test_auth_03()
{
  local test_name="Authentication with password first"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "PASS invalid" 503

  print_succeeded "$test_name"
  return
}

test_auth_04()
{
  local test_name="Can't authenticate another time"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER Anonymous" 331
  launch_test "$test_name" "PASS" 230
  launch_test "$test_name" "USER other" 530

  print_succeeded "$test_name"
  return
}

test_auth_05()
{
  local test_name="Pass after authentication"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER Anonymous" 331
  launch_test "$test_name" "PASS" 230
  launch_test "$test_name" "PASS" 230

  print_succeeded "$test_name"
  return

}

test_invalid_00()
{
  local test_name="Invalid command before authentication"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "INVALID" 530

  print_succeeded "$test_name"
  return
}

test_invalid_01()
{
  local test_name="Invalid command after authentication"

  launch_client $HOST $PORT
  if [[ ! $? -eq 1 ]]; then
    echo "KO"
    kill_client
    return
  fi

  launch_test "$test_name" "USER Anonymous" 331
  launch_test "$test_name" "PASS" 230
  launch_test "$test_name" "INVALID" 500

  print_succeeded "$test_name"
  return
}

test_auth_00; clean
test_auth_01; clean
test_auth_02; clean
test_auth_03; clean
test_auth_04; clean
test_auth_05; clean
test_invalid_00; clean
test_invalid_01; clean
