@echo off
REM ============================================================================
REM Pre-commit Hook para Windows - Control Horario
REM ============================================================================
REM Este script se ejecuta automáticamente antes de cada commit en Windows
REM Verifica calidad del código y previene commits con errores
REM ============================================================================

echo.
echo [92m============================================[0m
echo [92m  Pre-commit Hook - Control Horario[0m
echo [92m============================================[0m
echo.

REM ============================================================================
REM 1. VERIFICAR QUE FLUTTER ESTÉ DISPONIBLE
REM ============================================================================
where flutter >nul 2>&1
if errorlevel 1 (
    echo [91mERROR: Flutter no esta instalado o no esta en el PATH[0m
    exit /b 1
)

echo [32m✓ Flutter detectado[0m

REM ============================================================================
REM 2. FORMATEAR CÓDIGO
REM ============================================================================
echo.
echo [93mFormateando codigo Dart...[0m
dart format lib\ --set-exit-if-changed

if errorlevel 1 (
    echo [93m⚠ Archivos formateados automaticamente[0m
    echo [93m  Agregalo al stage: git add .[0m
    exit /b 1
)

echo [32m✓ Formato correcto[0m

REM ============================================================================
REM 3. ANALIZAR CÓDIGO (Linter)
REM ============================================================================
echo.
echo [93mAnalizando codigo con linter...[0m
flutter analyze --fatal-infos

if errorlevel 1 (
    echo.
    echo [91m❌ Errores de linter detectados[0m
    echo [91m   Corrige los errores antes de hacer commit[0m
    echo.
    echo    Comandos utiles:
    echo    - Ver errores: flutter analyze
    echo    - Formatear: flutter format lib\
    echo.
    exit /b 1
)

echo [32m✓ Analisis pasado sin errores[0m

REM ============================================================================
REM TODO CORRECTO - PERMITIR COMMIT
REM ============================================================================
echo.
echo [92m============================================[0m
echo [92m✅ Todas las verificaciones pasaron[0m
echo [92m   Procediendo con el commit...[0m
echo [92m============================================[0m
echo.

exit /b 0

