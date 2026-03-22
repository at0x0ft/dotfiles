# User customizations for powerlevel10k
# This file overrides settings from p10k-base.zsh
# Source order: p10k.zsh → p10k-base.zsh → THIS FILE
#
# Maintenance: Only include variables that differ from base theme.
# When upgrading p10k, review base changes and update overrides as needed.

# ===== Prompt Structure =====

# Add context and os_icon to left prompt (base has them commented/in right prompt)
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  # =========================[ Line #1 ]=========================
  context                 # user@hostname
  os_icon                 # os identifier
  dir                     # current directory
  vcs                     # git status
  # =========================[ Line #2 ]=========================
  newline                 # \n
  prompt_char             # prompt symbol
)

# ===== Font and Visual Settings =====

# Use awesome-fontconfig instead of nerdfont-complete
typeset -g POWERLEVEL9K_MODE=awesome-fontconfig

# Disable extra newline before prompt (more compact)
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

# Gap character and color (dotted line style)
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='·'
typeset -g POWERLEVEL9K_RULER_FOREGROUND=244

# ===== Git/VCS Customizations =====

# Show branch icon in git prompt
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

# ===== Status Display Preferences =====

# Show status even when successful (not just on error)
typeset -g POWERLEVEL9K_STATUS_OK=true
typeset -g POWERLEVEL9K_STATUS_ERROR=true

# Show verbose signal names (e.g., SIGINT instead of just INT)
typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=true
