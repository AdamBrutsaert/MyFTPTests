##
## EPITECH PROJECT, 2024
## Makefile
## File description:
## Makefile
##

tests_run:
	@./myftp 8080 & \
		server_pid=$$!; \
		./tests/test_ftp.sh 0.0.0.0 8080; \
		kill $$server_pid 2>/dev/null;

.PHONY: tests_run
