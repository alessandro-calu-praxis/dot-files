git_info() {
	[ -x "$(which git)" ] || return    # git not found

	local git_branch_symbol='⑂ '
	local git_branch_changed_symbol='+'
	local git_need_push_symbol='⇡'
	local git_need_pull_symbol='⇣'
	local git_eng="env LANG=C git"	 # force git output in English to make our work easier
	# get current branch name or short SHA1 hash for detached head
	local branch="$($git_eng symbolic-ref --short HEAD 2>/dev/null || $git_eng describe --tags --always 2>/dev/null)"
	[ -n "$branch" ] || return	# git branch not found

	local marks

	# branch is modified?
	[ -n "$($git_eng status --porcelain)" ] && marks+=" $git_branch_changed_symbol"

	# how many commits local branch is ahead/behind of remote?
	local stat="$($git_eng status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
	local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
	local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
	[ -n "$aheadN" ] && marks+=" $git_need_push_symbol$aheadN"
	[ -n "$behindN" ] && marks+=" $git_need_pull_symbol$behindN"

	# print the git branch segment without a trailing newline
	printf " $git_branch_symbol$branch$marks "
}

delete_broken_links() {
	for i in $(file * | grep broken | cut -d : -f 1); do rm $i; done
}
