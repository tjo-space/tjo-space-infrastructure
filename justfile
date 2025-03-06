# Always use devbox environment to run commands.
set shell := ["devbox", "run"]
# Load dotenv
set dotenv-load

mod id 'id.tjo.space'

default:
  @just --list
