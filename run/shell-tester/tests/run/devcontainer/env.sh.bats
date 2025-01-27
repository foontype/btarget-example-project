#!/usr/bin/env bats

@test ".env.example.*" {
    local expected_string="COMPOSE_PROJECT_NAME=btarget-example-project"
    
    run grep "${expected_string}" $(find . -type f -name .env.example.*)

    [ "$status" -eq 0 ]
}
