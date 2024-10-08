load utils/startup.bash

@test "Check typescript in devDependencies" {
    run jq <package.json "(.dependencies.typescript | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # Typescript should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.typescript | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # Typescript in package.json
}

@test "Check tsconfig" {
    if [ ! -f "./tsconfig.json" ]; then
        fatal "tsconfig.json required" # Check tsconfig.json in project directory
    fi

    run jq <tsconfig.json "."
    [ "$status" -eq 0 ] || fatal "$output" "$(cat tsconfig.json)" # Validate json file: tsconfig.json

    run jq <tsconfig.json "(.compilerOptions.noImplicitAny | contains(true))"
    [ "$output" == "true" ] || fatal "$output" "$(cat tsconfig.json)" # Check "noImplicitAny": true option in tsconfig.json

    run jq <tsconfig.json "(.compilerOptions.noUnusedLocals | contains(true))"
    [ "$output" == "true" ] || fatal "$output" "$(cat tsconfig.json)" # Check "noUnusedLocals": true option in tsconfig.json

    run jq <tsconfig.json "(.compilerOptions.noUnusedParameters | contains(true))"
    [ "$output" == "true" ] || fatal "$output" "$(cat tsconfig.json)" # Check "noUnusedParameters": true option in tsconfig.json

    run jq <tsconfig.json "(.compilerOptions.sourceMap | contains(true))"
    [ "$output" == "true" ] || fatal "$output" "$(cat tsconfig.json)" # Check "sourceMap": true option in tsconfig.json

    run jq <tsconfig.json "(.compilerOptions.strictNullChecks | contains(true))"
    [ "$output" == "true" ] || fatal "$output" "$(cat tsconfig.json)" # Check "strictNullChecks": true option in tsconfig.json
}

@test "Check eslint in devDependencies" {
    run jq <package.json "(.dependencies.eslint | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # eslint should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.eslint | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # eslint in package.json
}

@test "Check stylelint in devDependencies" {
    run jq <package.json "(.dependencies.stylelint | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # stylelint should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.stylelint | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # stylelint in package.json
}

@test "Ensure all style files have the same extension" {
    local tempfile="${BATS_RUN_TMPDIR}/style-extensions.txt"

    find . -mindepth 1 -type f -regextype posix-extended -regex ".*\.(css|scss|sass|styl|less|pcss)" \
    | sed "s/.*\.//" \
    | sort \
    | uniq \
    > "$tempfile"

    local extensions=$(cat "$tempfile")
    local count="$(wc -l < $tempfile)"

    [[ $count -eq 1 ]] || fatal "Found extensions:" $extensions # Check that all files in the project have the same extension
}
