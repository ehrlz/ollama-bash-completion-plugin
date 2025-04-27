#!/bin/bash

# Bash completion for Ollama CLI
# by @ehrlz https://github.com/ehrlz

_ollama_complete() {
    local cur prev words cword
    _init_completion -n : || return

    # Check if we're in a help context
    local help_context=false
    if [[ ${words[1]} == "help" ]]; then
        help_context=true
        # If we're completing an argument after "help", adjust what we consider as the previous word
        if [[ $cword -ge 3 ]]; then
            # No completions after the command in help context
            COMPREPLY=()
            return 0
        fi
    fi
    
    case $prev in
        'ollama')
            # Get commands dynamically from ollama -h
            local commands=$(ollama -h 2>/dev/null | sed -n '/^Available Commands:/,/^$/p' | grep -v "^Available Commands:" | grep -v "^$" | awk '{print $1}')
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            return 0
            ;;
        'run'|'rm'|'show'|'push')
            # Get list of local models
            local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"                         # <---- IMPORTANT: colon remover to handle properly model names
            return 0
            ;;
        'cp')
            # Only complete the SOURCE parameter (first argument) with model names
            # For cp command, we need to determine if we're on the first or second parameter
            if [[ ${#words[@]} -eq 3 ]]; then  # Only 'ollama cp' entered so far, need SOURCE
                # Get list of local models for SOURCE
                local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                __ltrim_colon_completions "$cur"
                return 0
            fi
            # If we're completing the DESTINATION, return empty to allow free text input
            return 0
            ;;
        'help')
            # Get commands dynamically for help completion - same as above
            # Include "help" itself since it's valid to do "ollama help help", 
            # but we'll block further completions with the special case handler above
            local commands=$(ollama -h 2>/dev/null | sed -n '/^Available Commands:/,/^$/p' | grep -v "^Available Commands:" | grep -v "^$" | awk '{print $1}')
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            return 0
            ;;
        'create')
            # For 'create' command, provide file completion with -f flag
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "-f" -- "$cur"))
            fi
            return 0
            ;;
        '-f')
            # Provide file completion for Modelfiles
            _filedir
            return 0
            ;;
        'stop')
            # Get list of running models using 'ollama ps'
            local running_models=$(ollama ps 2>/dev/null | awk 'NR>1 {print $1}')
            COMPREPLY=($(compgen -W "$running_models" -- "$cur"))
            return 0
            ;;
    esac
}

# Register the completion function
complete -F _ollama_complete ollama