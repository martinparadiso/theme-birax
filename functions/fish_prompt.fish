# Theme based on Bira theme from oh-my-zsh: https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/bira.zsh-theme
# Some code stolen from oh-my-fish clearance theme: https://github.com/bpinto/oh-my-fish/blob/master/themes/clearance/

set __birax_home_icon (set --query birax_home_icon; or echo ' ')
set __birax_git_icon (set --query birax_git_icon; or echo '')
set __birax_shell_icon (set --query birax_shell_icon; or echo '❭ ')
set __birax_private_icon (set --query birax_private_icon; or echo '󰗹')
set current_mode_color normal

function __birax_print_userhost 
  if [ (id -u) = "0" ];
    echo -n (set_color --bold red)
  else
    echo -n (set_color --bold green)
  end
  if [ -n "$SSH_CONNECTION" ]
    set _hostname @(hostname|cut -d . -f 1)
  else
    set _hostname ""
  end
  echo -n $USER$_hostname (set color normal)
end

function __birax_print_incognito
  if [ -n "$fish_private_mode" ]
    echo -n " $__birax_private_icon "
  end
end

function __current_path
  set -l currpath
  if set --query birax_nice_path
    set currpath (pwd)
    set currpath (string replace --regex "^$HOME" "$__birax_home_icon" "$currpath")
    set currpath (string replace --all "/" '  ' "$currpath")
    set currpath (string replace --regex "^  " '/  ' "$currpath")
  else
    set currpath (prompt_pwd -d 1 -D 1)
  end
  echo -n (set_color --bold blue) $currpath (set_color normal) 
end

function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _git_is_dirty
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end


function __birax_print_git_status
  if [ (_git_branch_name) ]
    set --local git_branch (_git_branch_name)

    if [ (_git_is_dirty) ]
      set git_color yellow
    else
      set git_color green
    end
    echo -n (set_color $git_color) $__birax_git_icon $git_branch (set_color normal)
  end
end

function __birax_print_venv
  set venv ''
  if [ -n "$VIRTUAL_ENV" ]
    set venv (python --version)
    set __venv_icon 
  end

  [ -n "$venv" ] && echo -n (set_color red) $__venv_icon $venv (set_color normal)
end


set -q color_vi_mode_normal; or set color_vi_mode_normal blue
set -q color_vi_mode_insert; or set color_vi_mode_insert green
set -q color_vi_mode_visual; or set color_vi_mode_visual magenta
set -q color_vi_mode_replace; or set color_vi_mode_replanormalce red

function __mode
  switch $fish_bind_mode
      case default
        set -g current_mode_color $color_vi_mode_normal 
        set -g current_mode_text "N"
      case insert
        set -g current_mode_color $color_vi_mode_insert
        set -g current_mode_text "I"
      case visual
        set -g current_mode_color $color_vi_mode_visual
        set -g current_mode_text "V"
      case replace
        set -g current_mode_color $color_vi_mode_replace
        set -g current_mode_text "R"
    end
  echo -n (set_color --bold $current_mode_color)$current_mode_text (set_color normal)
end

function fish_prompt
  set --query birax_no_pipes; or echo -n (set_color white)"╭─"(set_color normal)
  if not test "$fish_key_bindings" = "fish_default_key_bindings"
    set cursor_color $current_mode_color
    __mode
  end
  __birax_print_userhost
  __birax_print_incognito
  __current_path
  __birax_print_venv
  __birax_print_git_status
  echo -e ''
  set -q birax_no_pipes; or echo -n (set_color white)"╰─"
  echo -n (set_color $current_mode_color)$__birax_shell_icon(set_color normal)
end

function fish_right_prompt
  set -l st $status
  if [ $st != 0 ];
    echo (set_color red) ↵ $st(set_color normal)
  end
end
