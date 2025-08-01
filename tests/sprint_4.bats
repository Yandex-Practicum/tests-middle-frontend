load utils/startup.bash

@test "Check testing libraries are in devDependencies only" {
    # Ensure mocha, jest, and chai are NOT in regular dependencies
    run jq <package.json "(.dependencies.mocha // null, .dependencies.jest // null, .dependencies.chai // null) | select(. != null)"
    [ "$output" = "" ] || fatal "Testing libraries should not be in dependencies: $(cat package.json)"
}

@test "Check either mocha+chai or jest setup exists" {
    # Check if mocha is in devDependencies
    run jq <package.json ".devDependencies.mocha // null"
    mocha_present=$([[ "$output" != "null" ]] && echo "yes" || echo "no")
    
    # Check if jest is in devDependencies  
    run jq <package.json ".devDependencies.jest // null"
    jest_present=$([[ "$output" != "null" ]] && echo "yes" || echo "no")
    
    # Check if chai is in devDependencies
    run jq <package.json ".devDependencies.chai // null"
    chai_present=$([[ "$output" != "null" ]] && echo "yes" || echo "no")
    
    # Validate scenarios
    if [[ "$mocha_present" == "yes" && "$jest_present" == "yes" ]]; then
        fatal "Both mocha and jest found. Please use only one testing framework: $(cat package.json)"
    elif [[ "$mocha_present" == "yes" ]]; then
        # Using mocha - chai must be present
        [[ "$chai_present" == "yes" ]] || fatal "When using mocha, chai must be in devDependencies: $(cat package.json)"
        echo "✓ Using mocha + chai setup"
    elif [[ "$jest_present" == "yes" ]]; then
        # Using jest - chai should not be present (jest has built-in assertions)
        [[ "$chai_present" == "no" ]] || echo "⚠ Warning: Using jest with chai is unusual but allowed"
        echo "✓ Using jest setup"
    else
        fatal "No testing framework found. Please install either 'mocha + chai' or 'jest' in devDependencies: $(cat package.json)"
    fi
}

@test "Check npm run test existence" {
    [[ "$(npm run)" =~ (test) ]] # Check presence of `npm run test`
}
