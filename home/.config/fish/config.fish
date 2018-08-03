set -x PATH /usr/java/jre/bin ~/.npm-packages/bin ~/bin ~/.local/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/games /usr/local/games /usr/local/go/bin
set -x GOPATH ~/go
set -x TERM xterm-256color
eval (perl -I ~/perl5/lib/perl5/ -Mlocal::lib)

# Fish completions for cht.sh
complete -c cht.sh -xa '(curl -s cheat.sh/:list)'
