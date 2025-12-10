# 🚀 Instalación Rápida de Git Hooks

## Windows (Ejecuta en PowerShell o CMD en la raíz del proyecto):

```bash
git config core.hooksPath .githooks
```

## Mac/Linux (Ejecuta en Terminal en la raíz del proyecto):

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

## ✅ Verificar instalación:

```bash
git config core.hooksPath
```

Debe mostrar: `.githooks`

## 🎯 Listo!

Ahora cada vez que hagas `git commit`, se ejecutarán las verificaciones automáticamente.

**Ver más detalles:** [.githooks/README.md](.githooks/README.md)

