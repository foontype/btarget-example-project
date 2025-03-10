@echo off
cd /d "%~dp0"
type Dockerfile.base Dockerfile.workspace Dockerfile.user-workspace > Dockerfile
