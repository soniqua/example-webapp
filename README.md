# Example Web-App

This repository contains a simple Guestbook web-app, allowing visitors to record their name on entry.

## Components

| Location | Description |
| --- | --- |
| [dist](/dist) | A pre-compiled Go binary for Linux or MacOS |
| [public](/public) | Static files rendered as a Javascript front-end |
| Dockerfile | A Dockerfile used to create an image with both the Web-App and Redis installed |
| start.sh | A helper script used within the Docker image |

## Changes

- A Dockerfile is added to simplify running the Web-App on a local machine

### Positives
- Pre-packaged with a Redis server to allow the Web-App to work correctly
- A single command will launch the Web-App
- A container may be presented as an immutable, versioned instance of the application

### Negatives
- Not built for scalable architecture - typically the Web-App (if scaled) should share a single Redis backend
- Highly coupled - if either service in the container fails, both will be restarted
- Ephemeral - data is lost if either service in the container fails

## Running the web-app locally

1. Clone this repository
1. Ensure a redis cluster is available on localhost
1. Run `./dist/example-webapp-{linux|osx}` depending on your operating system
1. Open a browser, and point to localhost:3000

