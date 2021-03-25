# Example Web-App

This repository contains a simple Guestbook web-app, allowing visitors to record their name on entry.

## Components

| Location | Description |
| --- | --- |
| [dist](/dist) | A pre-compiled Go binary for Linux or MacOS |
| [public](/public) | Static files rendered as a Javascript front-end |

This branch will represent the default state of the assignment, and will not launch correctly.

## Running the web-app locally

1. Clone this repository
1. Ensure a redis cluster is available on localhost
1. Run `./dist/example-webapp-{linux|osx}` depending on your operating system
1. Open a browser, and point to localhost:3000
