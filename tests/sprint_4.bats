load utils/startup.bash

@test "Check mocha or jest in devDependencies" {
    run jq <package.json "(.dependencies.mocha + .dependencies.jest | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # mocha should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.mocha + .dependencies.jest | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # mocha in package.json
}

@test "Check chai in devDependencies if using mocha" {
    # First check if mocha is present in devDependencies
    run jq <package.json ".devDependencies.mocha"
    if [ "$output" != "null" ]; then
        # If using mocha, check chai is not in dependencies
        run jq <package.json "(.dependencies.chai | length)"
        [ "$output" -eq 0 ] || fatal "$(cat package.json)" # chai should be only in devDependencies
        
        # And chai must be in devDependencies
        run jq <package.json "(.devDependencies.chai | length)"
        [ "$output" -ne 0 ] || fatal "$(cat package.json)" # chai must be in devDependencies when using mocha
    else
        # If not using mocha (presumably using jest), skip chai checks
        echo "Using Jest - skipping chai dependency check"
    fi
}

@test "Check npm run test existence" {
    [[ "$(npm run)" =~ (test) ]] # Check presence of `npm run test`
}
