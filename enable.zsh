# Source this file in your zshrc to set everything up for term-alert

function term-alert-precmd()
{
    print '\033TeRmCmD term-alert-done'
}

if [[ "${TERM}" =~ 'eterm' ]]; then
    precmd_functions=($precmd_functions term-alert-precmd)
fi
