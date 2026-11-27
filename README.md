# Dotfiles

Configuração pessoal para Linux (Arch/CachyOS) e macOS, instalada com GNU Stow.

## Instalar

```bash
./install.sh
```

O instalador mostra primeiro os pacotes, backups e links que vai alterar. Depois da confirmação, instala apenas dependências ausentes, guarda conflitos em `~/.local/state/dotfiles/backups/` e aplica os packages Stow. `./install.sh --yes` salta esta confirmação, mas mudar a login shell para Fish continua a exigir confirmação própria.

No macOS, instala primeiro o Homebrew. Rex não é instalado automaticamente.

As paletas Yonux são geradas pelo matugen diretamente em `~/.config`; não são geridas pelo Stow para que mudar de wallpaper não altere o repositório.

## Projetos do sessionizer

Edita o ficheiro da plataforma e volta a correr `./install.sh`:

- Linux: `profiles/linux/.local/scripts/session-roots`
- macOS: `profiles/macos/.local/scripts/session-roots`

Cada linha tem um caminho e uma profundidade separados por tab:

```text
~/dev	1
```

`F2` abre o seletor de diretórios. No Rex, `Cmd+K` abre o sessionizer.

## Atuin

`Ctrl+R` pesquisa o histórico, `Ctrl+G` abre Threads e a seta para cima mantém o histórico normal do Fish. Dentro do Atuin, `Enter` devolve o comando para edição e `Tab` executa-o.

A sincronização é manual:

```bash
atuin sync
```

Imports opcionais, executados uma única vez quando fizer sentido:

```bash
atuin import fish
atuin threads import
```

`atuin import fish` não deve ser repetido: cria entradas duplicadas.
