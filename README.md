# DNSUpdater

<p align="center">
    <a href="https://hub.docker.com/r/ffittschen/dns-updater">
        <img alt="Docker Cloud Build Status" src="https://img.shields.io/docker/cloud/build/ffittschen/dns-updater.svg">
    </a>
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
    </a>
</p>


This package allows you to set up a service that updates DNS records using the DigitalOcean API. Its main purpose is being a target for other clients that only allow GET requests to send updates to DDNS services, e.g., routers like  Fritz!Box.

## Usage

You can either use the [ffittschen/dns-updater](https://hub.docker.com/r/ffittschen/dns-updater) image on DockerHub, or build the image on your own using the instructions below.

### DockerHub

```bash
docker  run -it -d \
    -p 8080:80 \
    -e USERNAME=john_doe \
    -e PASSWORD=change_this_to_some_secure_password \
    -e API_KEY=your_digitalocean_api_key \
    --name dns-updater \
    ffittschen/dns-updater:latest
```

Alternatively, you can also create a `.env` file:
```
USERNAME=john_doe
PASSWORD=change_this_to_some_secure_password
API_KEY=your_digitalocean_api_key
```

And then change the command to the following to use the `.env` file:
```bash
docker  run -it -d \
    -p 8080:80 \
    --env-file .env \
    --name dns-updater \
    ffittschen/dns-updater:latest
```

### Build from Source / GitHub

```bash
git clone https://github.com/ffittschen/DNSUpdater
git checkout master
cd DNSUpdater
cp .env.sample .env
$EDITOR .env
docker build -t ffittschen/dns-updater:latest .
docker run -it -d -p 8080:80 --env-file .env --name=dns-updater ffittschen/dns-updater:latest
```

## Ports

|  Port  | Description               |
|:------:|---------------------------|
| 80/TCP | API to update DNS records |

## API

DNSUpdater provides a very simple interface, it only has one path: `/api/v1/domains/updateRecord`. To update a DNS record of a domain, you need to execute a `GET` request targeting the mentioned path and provide a few query parameters:

|Parameter | Type |Description |
|----------|:----:|------------|
|domain    |string|The name of the domain as it is managed by DigitalOcean, e.g., `example.com`|
|recordName|string|The name of the A record of the domain. If your subdomain is `foo.example.com`, the record name is `foo`.|
|ip        |string|The dynamic IP address to which the A record should point, e.g., `1.2.3.4`|

In addition to the query parameters, you need to authenticate the request using basic auth with the username and password provided as environment variables to the docker container:

| Header Name   | Header Value |
|---------------|--------------|
| Authorization | Basic am9obl9kb2U6c29tZV9zZWN1cmVfcGFzc3dvcmQ= |

The header value is the username and password concatenated with a colon as separator and then encoded to base64. You can create the string by calling this command in your terminal:

```bash
echo -n john_doe:some_secure_password | base64
```

## Prerequisites
Since this is a DNS _Updater_, you need to make sure that a record with the name that you pass as a query parameter already exists in your DigitalOcean account.