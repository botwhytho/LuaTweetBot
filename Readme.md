Searches twitter for a certain topic and tweets a random quote as a response to the latest tweet of the account with the greatest number of followers.

### PLEASE READ


After you clone the repository, please run the following command before anything else to un-track your API keys and other parameters as you do not want to commit these to a publicly hosted git remote.

```
git update-index --skip-worktree ./.env
```

#### Build

To build a development docker image, run:

```
docker build -t botwhytho/lua-tweet-bot:latest --build-arg ENVIRONMENT_TYPE=DEV .
```
If you exclude the build argument or define 'ENVIRONMENT_TYPE' as 'PROD' the image will not have the apk package manager or even busybox.

#### Run

To run a development container, run:

```
docker run -it --name lua-tweet-bot -v $(pwd):/app -w /app botwhytho/lua-tweet-bot:latest /bin/sh
```

To run a production container, run:

```
docker run --name lua-tweet-bot -v $(pwd):/app -w /app botwhytho/lua-tweet-bot:latest luajit main.lua
```
