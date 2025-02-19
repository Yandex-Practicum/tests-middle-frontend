load utils/startup.bash

teardown_file() {
    shutdown_node
}

@test "Run npm install" {
    run npm install
    [ "$status" -eq 0 ] || fatal "$output"
}

@test "Check pre-commit hook installed" {
    if [[ "$SPRINT" != "sprint_4" ]]; then
        skip
    fi

    # Check if .husky directory exists
    [ -d ".husky" ] || fatal "No .husky directory found"

    # List contents of .husky directory
    run ls -1 .husky
    [ "$status" -eq 0 ] || fatal "$output" # list hooks

    # Check for pre-commit file
    [[ "$output" =~ (pre-commit$) ]] || fatal "$output" # Check pre-commit hook exists
}

@test "Run stylelint" {
    local count=`ls -1a .stylelintrc* | wc -l`
    if [ $count != 0 ]; then
        run npx stylelint "**/*.{css,scss,sass,styl,less,pcss}"
        [ "$status" -eq 0 ] || fatal "$output" # Lint styles
    else
        skip
    fi
}

@test "Run eslint" {
    local count=`ls -1a .eslintrc* | wc -l`
    if [ $count != 0 ]; then
        run npx eslint "**/*.{js,ts}" \
        --plugin @typescript-eslint \
        --rule "@typescript-eslint/ban-ts-comment: error"

        [ "$status" -eq 0 ] || fatal "$output" # Lint js
    else
        skip
    fi
}

@test "Run typescript checks" {
    local count=`ls -1a tsconfig.json | wc -l`
    if [ $count != 0 ]; then
        run npx tsc --noEmit
        [ "$status" -eq 0 ] || fatal "$output" # Lint types
    else
        skip
    fi
}

@test "Run npm test" {
    if [[ "$SPRINT" != "sprint_4" ]]; then
        skip
    fi

    run npm test
    [ "$status" -eq 0 ] || fatal "$output" # npm test
}

@test "Run npm run start and wait for port 3000" {
    start_node
}

@test "Check routing" {
    run curl -I http://localhost:3000/
    [ "$status" -eq 0 ] || fatal "$output" # Check status of curl http://localhost:3000/
    [[ "$output" =~ (HTTP[^ \t]*[ \t]200) ]] || fatal "$output" # Check response of curl http://localhost:3000/
}

@test "Check pages routing" {
    if [[ "$SPRINT" != "sprint_3" && "$SPRINT" != "sprint_4" ]]; then
        skip
    fi

    run curl -I http://localhost:3000/sign-up
    [ "$status" -eq 0 ] || fatal "$output" # Check status of curl http://localhost:3000/sign-up
    [[ "$output" =~ (HTTP[^ \t]*[ \t]200) ]] || fatal "$output" # Check response of curl http://localhost:3000/sign-up

    run curl -I http://localhost:3000/settings
    [ "$status" -eq 0 ] || fatal "$output" # Check status of curl http://localhost:3000/settings
    [[ "$output" =~ (HTTP[^ \t]*[ \t]200) ]] || fatal "$output" # Check response of curl http://localhost:3000/settings

    run curl -I http://localhost:3000/messenger
    [ "$status" -eq 0 ] || fatal "$output" # Check status of curl http://localhost:3000/messenger
    [[ "$output" =~ (HTTP[^ \t]*[ \t]200) ]] || fatal "$output" # Check response of curl http://localhost:3000/messenger
}
