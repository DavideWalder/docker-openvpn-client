#!/bin/bash

probeURL=""
proxyIP=127.0.0.1
httpProxy=true
socksProxy=true
useHttps=true

# Parse arguments
for arg in "$@"; do
    case "$arg" in
    --probeURL=*) probeURL="${arg#*=}" ;;
    --proxyIP=*) proxyIP="${arg#*=}" ;;
    --httpProxy=*)
        httpProxy="${arg#*=}"
        if [[ "$httpProxy" != "true" && "$httpProxy" != "false" ]]; then
            echo "Error: httpProxy argument must be 'true' or 'false'."
            exit 1
        fi
        ;;
    --socksProxy=*)
        socksProxy="${arg#*=}"
        if [[ "$socksProxy" != "true" && "$socksProxy" != "false" ]]; then
            echo "Error: socksProxy argument must be 'true' or 'false'."
            exit 1
        fi
        ;;
    --useHttps=*)
        useHttps="${arg#*=}"
        if [[ "$useHttps" != "true" && "$useHttps" != "false" ]]; then
            echo "Error: useHttps argument must be 'true' or 'false'."
            exit 1
        fi
        ;;
    *)
        echo "Unknown option: $arg"
        exit 1
        ;;
    esac
done

if [[ -z "$probeURL" ]]; then
    echo "Error: probeURL argument is required."
    exit 1
fi

if [[ -z "$proxyIP" ]]; then
    echo "Error: proxyIP argument is required."
    exit 1
fi

insecureFlag="--no-insecure"
if [[ "$useHttps" == "false" ]]; then
    insecureFlag="--insecure"
fi

if [[ "$httpProxy" == "true" ]]; then
    curl -s -o /dev/null "$insecureFlag" --proxy "$PROXY_USERNAME:$PROXY_PASSWORD@$proxyIP:8080" "$probeURL"

    if [[ $? != 0 ]]; then
        echo "HTTP Proxy failed (exit code: $?)"
        exit 1
    fi
fi

if [[ "$socksProxy" == "true" ]]; then
    curl -s -o /dev/null "$insecureFlag" --proxy "socks5://$PROXY_USERNAME:$PROXY_PASSWORD@$proxyIP:1080" "$probeURL"

    if [[ $? != 0 ]]; then
        echo "SOCKS Proxy failed (exit code: $?)"
        exit 1
    fi
fi
