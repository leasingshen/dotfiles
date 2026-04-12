[[ -o interactive ]] || return

dotfile_auto_sync() {
    local repo="${DOTFILE_REPO:-$HOME/dotfiles}"
    local upstream remote local_ref remote_ref base_ref

    command -v git >/dev/null 2>&1 || return
    git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    upstream=$(git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) || return

    if [[ -n $(git -C "$repo" status --porcelain 2>/dev/null) ]]; then
        print -P "%F{yellow}[dotfile]%f 跳过自动同步：仓库有未提交改动"
        return
    fi

    remote=${upstream%%/*}
    git -C "$repo" fetch --quiet "$remote" || {
        print -P "%F{red}[dotfile]%f 自动同步失败：fetch 失败"
        return 1
    }

    local_ref=$(git -C "$repo" rev-parse @ 2>/dev/null) || return
    remote_ref=$(git -C "$repo" rev-parse '@{upstream}' 2>/dev/null) || return
    base_ref=$(git -C "$repo" merge-base @ '@{upstream}' 2>/dev/null) || return

    if [[ "$local_ref" == "$remote_ref" ]]; then
        return
    fi

    if [[ "$local_ref" == "$base_ref" ]]; then
        if git -C "$repo" merge --ff-only --quiet '@{upstream}' >/dev/null 2>&1; then
            print -P "%F{green}[dotfile]%f 已同步最新提交，正在重新 stow..."
            make -C "$repo" stow --quiet 2>/dev/null \
                && print -P "%F{green}[dotfile]%f stow 完成" \
                || print -P "%F{yellow}[dotfile]%f stow 失败，请手动运行 make stow"
        else
            print -P "%F{red}[dotfile]%f 自动同步失败：无法 fast-forward"
        fi
        return
    fi

    print -P "%F{yellow}[dotfile]%f 跳过自动同步：本地分支领先或已分叉"
}

dotfile_auto_sync
