@echo off

ECHO.
ECHO Adicionando todos os arquivos a staging area.
ECHO.

git add .

ECHO.
ECHO Comitando os arquivos no repositorio local.
ECHO.

git commit -m "Efetuado commit via facilitador git (git-recebe-envia-tudo.bat)"

ECHO.
ECHO Iniciando comando pull - Atualizando repositorio local com dados do servidor remoto.
ECHO.

git pull --no-edit

ECHO.
ECHO Enviando arquivos para repositorio servidor remoto.
ECHO.

git push

ECHO.
ECHO Concluido!
ECHO.

timeout 5  