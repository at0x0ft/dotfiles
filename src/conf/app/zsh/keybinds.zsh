# Reverse completion with Shift+Tab
bindkey "^[[Z" reverse-menu-complete

# Word forward/backword
bindkey "^[[1;5C" vi-forward-word
bindkey "^[[1;5D" vi-backward-word

# Home/End, delete button
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char
