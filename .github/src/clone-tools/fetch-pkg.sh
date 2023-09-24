#!/bin/bash
# Clone a repository

remaining_args=()
opt_branch=""
opt_sparse=""
repo=""
dest=""
mv_opt="-f"
mv_overwrite=true
sparsing_args=()

function usage() {
    echo "Usage: $0 [options] <repository> [destination]"
    echo "Options:"
    echo "    -b, --branch <branch>           Specify branch to clone"
    echo "    --sparse [...sparsing paths]    Enable sparse clone"
    echo "    -n, --no-clobber                Do not overwrite existing files"
    echo "                                    Only works when --sparse is chosen"
    echo "    -h, --help                      Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h |\
        --help)
            usage
            exit 0
            ;;
        -b |\
        --branch)
            [ -z "$2" ] || [[ "$2" =~ ^- ]] && echo "Missing argument for $1" && exit 1
            opt_branch=" -b $2"
            shift 2
            ;;
        --sparse)
            opt_sparse=" --filter=blob:none --sparse"
            shift
            while [[ $# -gt 0 ]]; do
                [[ "$1" =~ ^- ]] && break
                sparsing_args+=("$1")
                shift
            done
            [ ${#sparsing_args[@]} -eq 0 ] && echo "Missing argument for sparsing paths" && exit 1
            ;;
        -n |\
        --non-clobber)
            mv_opt="-n"
            mv_overwrite=false
            shift
            ;;
        -* |\
        --*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            if [ -z "$repo" ]; then repo="$1"
            elif [ -z "$dest" ]; then dest="$1"
            else
                remaining_args+=("$1")
            fi
            shift
            ;;
    esac
done

# check repository
[ -z "$repo" ] && echo "Missing argument for repository" && exit 1

# check destination
[ -n "$dest" ] && {
    if [ -f "$dest" ]; then
        echo "Destination \"$dest\" is a file"
        exit 1
    fi
    [ ! -d "$dest" ] || mkdir -p "$dest"
}

# fromat repo
repo_msg="$repo"
if [[ ! "$repo" =~ :// ]]; then
    repo_url_base="https://github.com/"
    [ -n "$FETCH_PKG_BASE" ] && repo_url_base="$FETCH_PKG_BASE"
    repo_msg="$repo ($repo_url_base$repo)"
    repo="$repo_url_base$repo"
fi

blacklist=(.git .github .vscode .idea .DS_Store .gitignore .gitattributes .gitmodules)
function escape_regex() {
    echo "$1" | sed 's/[]\/$*.^|[]/\\&/g'
}
function is_blacklisted() {
    local t="$1"
    local black
    for black in "${blacklist[@]}"; do
        black="$(escape_regex "$black")"
        [[ "$t" =~ ^$black$ ]] && return 0
    done
    return 1
}

if [ -z "$opt_sparse" ]; then # normal clone
    echo "Fetching $repo_msg..."
    git clone$opt_branch --depth 1 $repo $dest 2>&1
else # sparse clone
    curdir="$(pwd)"
    [ -n "$dest" ] && dest_dir="$(realpath "$dest")" || dest_dir="$curdir"
    hash=$(echo "$(date +%s%N).$repo" | md5sum | sed 's/[^0-9a-zA-Z]//g' | cut -c 1-8)
    tmpdir="/tmp/fetch-sparse-$hash"
    echo "Fetching $repo_msg..."
    git clone$opt_branch --depth 1$opt_sparse $repo $tmpdir 2>&1
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set ${sparsing_args[@]}
    for ii in "${sparsing_args[@]}"; do
        is_blacklisted "$ii" && continue
        [ ! -e "$ii" ] && continue
        echo "Sparsing Checking out \"$ii\"..."
        [ $mv_overwrite == true ] && [ -d "$dest_dir/$(basename "$ii")" ] && \
        find "$dest_dir/$(basename "$ii")/" -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
        mv $mv_opt "$ii" "$dest_dir/"
    done
    cd "$curdir"
    rm -rf "$tmpdir"
fi