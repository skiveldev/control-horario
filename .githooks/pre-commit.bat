@echo off
REM ============================================================================
REM Pre-commit Hook for Windows - Control Horario
REM ============================================================================
REM Verifies staged Dart formatting (check-only, no mutation) and runs the
REM static analyzer.  Cancels the commit if either check fails.
REM ============================================================================

REM ---------------------------------------------------------------------------
REM 1. Check-only staged Dart formatting (no mutation)
REM ---------------------------------------------------------------------------
echo.
echo [93mChecking staged Dart formatting...[0m

call dart run tool\check_staged_dart_format.dart
if errorlevel 1 (
    echo.
    echo [91mStaged Dart formatting check failed.[0m
    echo [91m  Format the files listed above, stage them, and try again.[0m
    exit /b %errorlevel%
)

echo [32m✓ Staged formatting OK[0m

REM ---------------------------------------------------------------------------
REM 2. Static analysis (full project, check-only)
REM ---------------------------------------------------------------------------
echo.
echo [93mRunning static analysis...[0m

flutter analyze --no-pub --fatal-infos --fatal-warnings
if errorlevel 1 (
    echo.
    echo [91mStatic analysis failed.[0m
    echo [91m  Fix the issues above before committing.[0m
    exit /b 1
)

echo [32m✓ Analysis passed[0m

REM ---------------------------------------------------------------------------
REM All checks passed
REM ---------------------------------------------------------------------------
echo.
echo [92m==============================[0m
echo [92m  All pre-commit checks passed[0m
echo [92m==============================[0m
echo.

exit /b 0
