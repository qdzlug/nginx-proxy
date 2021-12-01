## Purpose
Deploying a webserver on the internet means that usually within minutes of the deployment you will immediately start
being probed and scanned by malicious actors. This can be mitigated in a number of ways, but they all require a level
of time and knowledge. 

This project started because I wanted to have an easy way to register a domain, stand up a webserver for that domain, 
automatically have certificates generated and deployed, and have some level of comfort regarding potential attacks
on the site.

This project started with [nginx-proxy](https://www.github.com/nginx-proxy/nginx-proxy) along with the 
[ACME Companion](https://github.com/nginx-proxy/acme-companion) as a way to use [Docker](https://docker.io) to create
a simple deployment where I could add/remove websites as desired.

This was great, and my deployment process consisted of setting up the "core" of three containers:
- [nginx-proxy/nginx-proxy](https://www.github.com/nginx-proxy/nginx-proxy)
- [nginx-proxy/acme-companion](https://www.github.com/nginx-proxy/acme-companion)
- [jwilder/whoami](https://www.github.com/jwilder/whoami)

These provided the basic functionality required to stand up the infrastructure necessary to allow me to easily deploy
using a shared network and a handful of key variables. For example, the following compose file will stand up a 
ghost blog. Assuming you've setup DNS appropriately, then the core deployment (this project) will then get certificates,
and update the nginx proxy appropriately.

```angular2html
version: '3.7'
services:

    ghost01:
        image: "ghost"
        user: "1000"
        environment:
            - url=https://test01.example.com
            - VIRTUAL_HOST=test01.example.com
            - VIRTUAL_HOST_ALIAS=test01.example.com
            - LETSENCRYPT_HOST=test01.example.com
            - LETSENCRYPT_EMAIL=me@example.com
        networks:
            - webproxy
networks:
    webproxy:
        external: true

```

## Getting Opinionated
This was good, but not exactly what I needed, so I forked the repository and made some pretty significant changes to 
extend the project. This new version has the following features:

* Includes a deployment of [NGINX App Protect](https://www.nginx.com/products/nginx-app-protect/) configured to use
the default WAF signature files.
* All persistent data, including the NGINX App Protect logs, are stored under the [data](./data) directory.
* Includes [NGINX Plus](https://www.nginx.com/products/nginx/).
* Includes the [NGINX Plus Dashboard](https://www.nginx.com/products/nginx/live-activity-monitoring/) pre-configured
and wired to automatically update when new services are added.
* Includes the [ACME Companion](https://github.com/nginx-proxy/acme-companion) baked in as part of the deployment.
* Includes a simple [Makefile](./Makefile) to build the images required.
* Includes a [Docker Compose](./docker-compose.yml) file that stands up the core functionality once it's been edited
to include the proper variables.

This is a side project, and as such there are a number of rough edges and areas that need some work. In no particular
order this includes:
* Unit test functionality is not working.
* Only Debian-based images are supported.
* Some code is not as clean as I would like it.

## Requirements
* GNUMake.
* A version of Docker that supports BuildKit.
* An ability to setup DNS records.
* Please note, this does require the paid version of NGINX Plus and NGINX App Protect; fortunately you can head over to 
the [NGINX Website](https://www.nginx.com/products/nginx-app-protect/) and get a free trial to see if you like it.

## Installation Instructions
The install process is relatively painless.
* Create the required DNS names for your site; it doesn't matter how you do this (A record, CNAME) as long as it
resolves to the host you are installing on. I tend to create a name for the host, and then use CNAMES for the sites
that I am hosting.
* Clone this repository.
* Create a `webproxy` network using Docker (you can name it whatever you want, but then you have to edit files to use
the new name): `docker network create webproxy`
* Add your NGINX Docker Certificate and Key into the [nplus](./nplus) directory following these naming conventions:
  * `nplus/nginx-repo.crt` 
  * `nplus/nginx-repo.key`
* Build the docker images via `make`
* Stand up the environment with `docker-compose up -d`
* Observe the startup with `docker-compose logs -f`
* Deploy your application, ensuring you set the following variables (sample data included for clarity)
  * url=https://test01.example.com
  * VIRTUAL_HOST=test01.example.com
  * VIRTUAL_HOST_PORT=80
  * VIRTUAL_HOST_ALIAS=test01.example.com
  * LETSENCRYPT_HOST=test01.example.com
  * LETSENCRYPT_EMAIL=me@example.com
* As your application deploys you should see the necessary certificates being generated and the configuration files 
being updated if you tail the core logs.
* Test your application

## Troubleshooting
Occasionally, things get a bit confused. When this happens there are a few things to try:
* The IT Crowd solution of bringing everything down and back up has been known to fix things. Pretty sure that this is 
some sort of race condition, but I have not had the time to delve too deep.
* If things are really hosed, it is possible to stop the deployment and remove the contents of the `data/acme.sh` 
directory which will force the application to pull new certificates. Just be careful you don't do this too often or you
will run into the rate limit or daily limit

## Knobs to Turn
If you want to play around there are a few places you can do so.
* The `nginx.conf` file gets copied to the container at build time; this is where I have defined the dashboard logic. 
* The various containers are added to the `conf.d` directory and are built by the `dockergen` process that runs within
the `nginx-proxy` container. This uses the `nginx.tmpl` file as a template. You can edit this file; this is the way
I update for the NGINX Plus Dashboard. Word of warning however, the template can be a bit fiddly so proceed slowly.