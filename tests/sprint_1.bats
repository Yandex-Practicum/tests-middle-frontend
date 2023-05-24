load utils/startup.bash

@test "Check node_modules in .gitignore" {
    [[ "$(cat .gitignore)" =~ (node_modules) ]] # node_modules should be gitignored
}

@test "Check dist|build in .gitignore" {
    [[ "$(cat .gitignore)" =~ (dist|build) ]] # dist|build directory should be gitignored
}

@test "Check npm run start existence" {
    [[ "$(npm run)" =~ (start) ]] # `npm run start` missed
}

@test "Check Vite presence" {
    run jq <package.json "(.dependencies.vite | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # Vite should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.vite | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # Vite in devDependencies section of package.json
}

@test "Check newline at end of files" {
    for FILE in $(\
        find . -mindepth 1 -type f -regextype posix-extended \
        -regex ".*\.(js|ts|txt|md|html|css|scss|sass|styl|less|pcss|json)" \
        ! -path "*/.*" \
        ! -path '*/node_modules/*' \
    ); do

        if ! [[ -s "$FILE" && -z "$(tail -c 1 "$FILE")" ]]
        then
            echo "No newline at end of file $FILE"
            echo "Each line should be terminated in a newline character, including the last one."
            echo "https://stackoverflow.com/questions/5813311/whats-the-significance-of-the-no-newline-at-end-of-file-log"
            exit 1
        fi
    done
}

@test "Netlify link in README.md" {
    [[ "$(cat *.md)" =~ ([Nn]etlify\.app|onrender\.com) ]] # netlify.app or onrender.com link in README.md
}

@test "Check NodeJS version" {
    if [ -f ".nvmrc" ]; then
        run cat .nvmrc
    else
        run jq <package.json "(.engines.node)"
        [[ "$output" = "null" ]] && fatal "$output" # "node" in "engines" section in package.json
    fi
    [[ "$output" =~ ([0-9]+) ]] || fatal "$output" # Numeric Node version
    (( "${BASH_REMATCH[1]}" >= 12 )) || fatal "Version: ${BASH_REMATCH[1]}" # Check minimal Node version
}
