#!/usr/bin/env nu

source scripts/kubernetes.nu
source scripts/common.nu
source scripts/crossplane.nu
source scripts/ingress.nu
source scripts/mcp.nu
source scripts/github.nu
source scripts/anthropic.nu

def main [] {}

def "main setup" [] {
    
    rm --force .env

    let github_data = main get github --enable-org false

    let anthropic_data = main get anthropic

    main create kubernetes kind

    cp kubeconfig-dot.yaml kubeconfig.yaml

    main apply ingress nginx --provider kind

    main apply crossplane --preview true --app-config true

    kubectl create namespace a-team

    kubectl create namespace b-team

    (
        main apply mcp
            --enable-git true
            --enable-github true
            --github-token $github_data.token
    )

    rm --recursive --force .git

    main print source

}

def "main setup-dot-ai" [] {

    (
        main apply mcp
            --enable-dot-ai true
            --anthropic-api-key $env.ANTHROPIC_API_KEY
            --kubeconfig "kubeconfig-dot.yaml"
    )

}

def "main destroy" [] {

    main destroy kubernetes kind

}
