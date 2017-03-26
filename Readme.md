Searches twitter for a certain topic and tweets a random quote as a response to the latest tweet of the account with the greatest number of followers.

### PLEASE READ


After you clone the repository, please run the following command before anything else to un-track your API keys and other parameters as you do not want to commit these to a publicly hosted git remote.

```
git update-index --skip-worktree ./.env
```

#### Build

To build a development docker image, run:

```
docker build -t botwhytho/lua-tweet-bot:dev --build-arg ENVIRONMENT_TYPE=DEV .
```
To build a production docker image, run:

```
docker build -t botwhytho/lua-tweet-bot:prod --build-arg ENVIRONMENT_TYPE=PROD .
```

If you exclude the build argument, by default a production image will be built. Please note that the image will not have the apk package manager or even busybox so the entrypoint will have to be the lua workload directly.

#### Run

To run a development container, run:

```
docker run -it --name dev-tweet -v $(pwd):/app -w /app --env-file ./.env botwhytho/lua-tweet-bot:dev /bin/sh
```

To run a production container, run:

```
docker run --name prod-tweet -v $(pwd):/app -w /app --env-file ./.env botwhytho/lua-tweet-bot:prod luajit main.lua
```
