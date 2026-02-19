###############################
# Variables
###############################
SHELL := C:\Windows\System32\cmd.exe

PYTHON := py -3

CURRENT_DIR := .
SOURCE_DIR := .\src
RELEASE_DIR := .\Release
PACKAGE_DIR := .\artifacts

PROJECT_NAME := TradeSkillReagents

###############################
# Utility functions
###############################
# Deletes directory if it exists
# $1 Directory to delete
define delete_dir
	@if EXIST $1 rmdir $1 /s /q;
endef

# Creates a directory if it does not exist
# $! Directory to create
define make_dir
	@if NOT EXIST $1 mkdir $1;
endef

###############################
# Make rules
###############################
.DEFAULT_GOAL := build

.PHONY: clean
clean:
	$(call delete_dir,$(RELEASE_DIR))

.PHONY: build
build: clean
	$(call make_dir,$(RELEASE_DIR))
	$(PYTHON) .\scripts\build.py $(CURRENT_DIR) $(PROJECT_NAME)

.PHONY: test-classic
test-classic: build
	$(PYTHON) .\scripts\deploy-classic.py $(RELEASE_DIR) $(PROJECT_NAME)

.PHONY: test-bcc
test-bcc: build
	$(PYTHON) .\scripts\deploy-bcc.py $(RELEASE_DIR) $(PROJECT_NAME)

# .PHONY: test-retail
# test-retail: build
# 	$(PYTHON) .\scripts\deploy-retail.py $(RELEASE_DIR) $(PROJECT_NAME)
	
