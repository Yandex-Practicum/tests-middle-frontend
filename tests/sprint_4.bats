load utils/startup.bash

@test "Check mocha in devDependencies" {
    run jq <package.json "(.dependencies.mocha | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # mocha should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.mocha | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # mocha in package.json
}

@test "Check chai in devDependencies" {
    run jq <package.json "(.dependencies.chai | length)"
    [ "$output" -eq 0 ] || fatal "$(cat package.json)" # chai should be only in devDependencies, not in dependencies

    run jq <package.json "(.devDependencies.chai | length)"
    [ "$output" -ne 0 ] || fatal "$(cat package.json)" # chai in package.json
}

@test "Check npm run test existence" {
    [[ "$(npm run)" =~ (test) ]] # Check presence of `npm run test`
}
