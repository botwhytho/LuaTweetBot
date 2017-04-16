<a href='http://www.recurse.com' title='Made with love at the Recurse Center'><img src='https://cloud.githubusercontent.com/assets/2883345/11325206/336ea5f4-9150-11e5-9e90-d86ad31993d8.png' height='20px'/></a>

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
docker run -it --name dev-tweet -v $(pwd):/app --env-file ./.env --entrypoint /bin/sh botwhytho/lua-tweet-bot:dev
```

To run a production container, run:

```
docker run --name prod-tweet -v $(pwd):/app --env-file ./.env botwhytho/lua-tweet-bot:prod
```
