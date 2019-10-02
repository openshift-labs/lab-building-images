If you were to use something like `warpdrive`, or develop your own set of scripts for building and deploying your application, to ensure that it was used as the first choice for all Python applications in your organisation, there is no reason why you couldn't bundle it with the common Python base image. This way you avoid everyone doing their own thing and every different application being a snowflake that doesn't resemble any others. This will make it easier to support and maintain everything as all will use the same deployer.

To do this, it is just a matter of pushing the `assemble-image` and `start-container` script into the common Python base image and the application image `Dockerfile` executes them from the base image.

```execute
cd ~/python-base-v3
```

```execute
podman build --no-cache -t python-base .
```

```execute
cd ~/flask-app-v7
```

```execute
podman build --no-cache -t flask-app .
```

```execute
podman run --rm -p 8080:8080 flask-app
```

```execute-2
curl http://localhost:8080
```

```execute-2
podman kill -s TERM `podman ps -ql`
```
